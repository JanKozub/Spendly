import Foundation

class CurrencyExchangeService {
    public static func getExchangeRate(from: CurrencyName, to: CurrencyName, startDate: PaymentDate, endDate: PaymentDate) async throws -> [ExchangeRate] {
        
        if (to == .eur || from == .eur) {
            var v =  try await getExchangeRateToEur(from: .pln, to: .eur, startDate: startDate, endDate: endDate)
            
            if to == .eur {
                for i in v.indices {
                    v[i].rate = 1.0 / v[i].rate
                }
            }
            
            return v
        }
        
        var v1 = try await getExchangeRateToEur(from: from, to: .eur, startDate: startDate, endDate: endDate)
        var v2 = try await getExchangeRateToEur(from: to, to: .eur, startDate: startDate, endDate: endDate)
        
        v2 = v2.map { element in
            var modifiedElement = element
            modifiedElement.rate = 1.0 / element.rate
            return modifiedElement
        }
        
        v1 = v1.map { element in
            var fromElement = element
            let toElement = v2.first(where: { $0.date == element.date })!
            
            fromElement.to = toElement.from
            fromElement.rate = fromElement.rate * toElement.rate
            
            return fromElement
        }
        
        return v1
    }

    private static func getExchangeRateToEur(from: CurrencyName, to: CurrencyName, startDate: PaymentDate, endDate: PaymentDate) async throws -> [ExchangeRate] {
        if endDate > PaymentDate.today() {
            throw NSError(domain: "CurrencyExchangeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get exchange rates for the future."])
        }
        
        let urlString = "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.\(from.name).\(to.name).SP00.A"
        let url = try getURLWithComponents(url: urlString, startDate: startDate, endDate: endDate)
        let data = try await URLSession.shared.data(from: url).0
        let (jsonRates, jsonDates) = try extractDetails(from: data)
        var rates = convertToRatesArray(from: from, to: to, jsonRates: jsonRates, jsonDates: jsonDates)
        
        if rates.isEmpty {
            throw NSError(domain: "No rates in the given period.", code: 0)
        }
        
        rates = try fillMissingRates(rates: rates, startDate: startDate, endDate: endDate)
        
        return rates
    }
    
    private static func fillMissingRates(rates: [ExchangeRate], startDate: PaymentDate, endDate: PaymentDate) throws -> [ExchangeRate] {
        var filledRates = rates
        var currentDate = startDate
        var lastKnownRate: ExchangeRate?
        
        while currentDate <= endDate {
            if let rate = rates.first(where: { $0.date == currentDate }) {
                lastKnownRate = rate
            } else if let lastRate = lastKnownRate {
                filledRates.append(ExchangeRate(from: lastRate.from, to: lastRate.to, date: currentDate, rate: lastRate.rate))
            } else {
                var date2 = currentDate
                var rate: ExchangeRate?
                while date2 <= endDate {
                    if let temp = rates.first(where: { $0.date == date2 }) {
                        rate = temp
                        break
                    }
                    date2.addDays(1)
                }
                
                if rate == nil {
                    throw NSError(domain: "No exchange rates found", code: 0)
                } else {
                    rate?.date = currentDate
                    filledRates.append(rate!)
                }
            }
            currentDate.addDays(1)
        }
        
        return filledRates
    }
    
    private static func getURLWithComponents(url: String, startDate: PaymentDate, endDate: PaymentDate) throws -> URL {
        let start = PaymentDate.dateToStringFormatter(date: startDate, formatter: "yyyy-MM-dd")
        let end = PaymentDate.dateToStringFormatter(date: endDate, formatter: "yyyy-MM-dd")
        
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [
            URLQueryItem(name: "startPeriod", value: start),
            URLQueryItem(name: "endPeriod", value: end),
            URLQueryItem(name: "format", value: "jsondata")
        ]
        
        guard let url = urlComponents?.url else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        return url
    }
    
    private static func extractDetails(from data: Data) throws -> ([String: Any], [[String: Any]]) {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let dataSets = json["dataSets"] as? [[String: Any]],
              let seriesContainer = dataSets.first?["series"] as? [String: Any],
              let firstSeriesKey = seriesContainer.keys.first,
              let seriesDetails = seriesContainer[firstSeriesKey] as? [String: Any],
              let observations = seriesDetails["observations"] as? [String: Any],
              let structure = json["structure"] as? [String: Any],
              let dimensions = structure["dimensions"] as? [String: Any],
              let observationDimension = dimensions["observation"] as? [[String: Any]],
              let timeDimension = observationDimension.first(where: { $0["id"] as? String == "TIME_PERIOD" }),
              let timeValues = timeDimension["values"] as? [[String: Any]] else {
            throw NSError(domain: "Exchange rates not found or invalid response structure", code: -1, userInfo: nil)
        }
        
        return (observations, timeValues)
    }
    
    private static func convertToRatesArray(from: CurrencyName, to: CurrencyName, jsonRates: [String: Any], jsonDates: [[String: Any]]) -> [ExchangeRate] {
        var dateMap: [String: String] = [:]
        for (key, value) in jsonDates.enumerated() {
            if let date = value["id"] as? String {
                dateMap["\(key)"] = date
            }
        }
        
        var rates: [ExchangeRate] = []
        for (key, value) in jsonRates {
            if let observationArray = value as? [Any],
               let rate = observationArray.first as? Double,
               let date = dateMap[key] {
                rates.append(ExchangeRate(from: from, to: to, date: PaymentDate.dateFromStringFormatter(strDate: date, formatter: "yyyy-MM-dd"), rate: rate))
            }
        }
        
        return rates
    }
}
