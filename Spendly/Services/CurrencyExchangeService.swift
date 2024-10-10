import Foundation

class CurrencyExchangeService {
    static func getExchangeRates(base: CurrencyName, target: CurrencyName, startDate: Date, endDate: Date) async throws -> [Date: Double] {
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!
        
        if endDate > Date() {
            throw NSError(domain: "CurrencyExchangeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get exchange rates for the future."])
        }
        
        let urlString = "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.\(target.name).\(base.name).SP00.A"
        let df = DateFormatter()

        let url = try getURLWithComponents(url: urlString, startDate: startDate, endDate: endDate, formatter: df)
        let data = try await URLSession.shared.data(from: url).0

        let (jsonRates, jsonDates) = try extractDetails(from: data)
        var rates = convertToRatesArray(jsonRates: jsonRates, jsonDates: jsonDates, formatter: df)

        if rates.isEmpty {
            throw NSError(domain: "CurrencyExchangeService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No exchange rates found for the given period."])
        }

        rates = fillMissingRates(rates: rates, startDate: startDate, endDate: endDate)

        return rates
    }
    
    private static func fillMissingRates(rates: [Date: Double], startDate: Date, endDate: Date) -> [Date: Double] {
        var filledRates = rates
        var currentDate = startDate
        var lastKnownRate: Double?

        while currentDate <= endDate {
            if let rate = rates[currentDate] {
                lastKnownRate = rate
            } else if let lastRate = lastKnownRate {
                filledRates[currentDate] = lastRate
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
    
    private static func convertToRatesArray(jsonRates: [String: Any], jsonDates: [[String: Any]], formatter: DateFormatter) -> [Date: Double] {
        var dateMap: [String: String] = [:]
        for (key, value) in jsonDates.enumerated() {
            if let date = value["id"] as? String {
                dateMap["\(key)"] = date
            }
        }
        
        var rates: [Date: Double] = [:]
        for (key, value) in jsonRates {
            if let observationArray = value as? [Any],
               let rate = observationArray.first as? Double,
               let date = dateMap[key] {
                rates[formatter.date(from: date)!] = rate
            }
        }
        
        return rates
    }
}
