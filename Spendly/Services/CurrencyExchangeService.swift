import Foundation

class CurrencyExchangeService {
    public static func getExchangeRates(from: CurrencyName, to: CurrencyName, startDate: Date, endDate: Date) async throws -> [ExchangeRate] {
        if endDate > Date() {
            throw NSError(domain: "CurrencyExchangeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get exchange rates for the future."])
        }
        
        let urlString = "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.\(from.name).\(to.name).SP00.A"
        let df = DateFormatter()
        
        let calendar = Calendar.current
        let requestStartDate = calendar.date(byAdding: .day, value: -1, to: startDate)!
        let url = try getURLWithComponents(url: urlString, startDate: requestStartDate, endDate: endDate, formatter: df)
        let data = try await URLSession.shared.data(from: url).0
        
        let (jsonRates, jsonDates) = try extractDetails(from: data)
        var rates = convertToRatesArray(from: from, to: to, jsonRates: jsonRates, jsonDates: jsonDates, formatter: df)
        
        if rates.isEmpty {
            throw NSError(domain: "CurrencyExchangeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No exchange rates found for the given period."])
        }
        
        rates = try fillMissingRates(rates: rates, startDate: startDate, endDate: endDate)
        
        return rates
    }
    
    private static func fillMissingRates(rates: [ExchangeRate], startDate: Date, endDate: Date) throws -> [ExchangeRate] {
        var filledRates = rates
        var currentDate = startDate
        var lastKnownRate: ExchangeRate?
        
        while currentDate <= endDate {
            if let rate = rates.first(where: { $0.date == currentDate }) {
                lastKnownRate = rate
            } else if let lastRate = lastKnownRate {
                filledRates.append(ExchangeRate(from: lastRate.from, to: lastRate.to, date: currentDate, rate: lastRate.rate))
            } else {
                throw NSError(domain: "No exchange rates found", code: 0)
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return filledRates
    }
    
    private static func getURLWithComponents(url: String, startDate: Date, endDate: Date, formatter: DateFormatter) throws -> URL {
        formatter.dateFormat = "yyyy-MM-dd"
        let start = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: startDate)!)
        let end = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: endDate)!)
        
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
    
    private static func convertToRatesArray(from: CurrencyName, to: CurrencyName, jsonRates: [String: Any], jsonDates: [[String: Any]], formatter: DateFormatter) -> [ExchangeRate] {
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
                rates.append(ExchangeRate(from: from, to: to, date: formatter.date(from: date)!, rate: rate))
            }
        }
        
        return rates
    }
}
