import Foundation

extension URL {
    
    // https://stackoverflow.com/a/50990443
    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        
        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems
        
        // Returns the url from new url components
        return urlComponents.url!
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}


extension Date {
    
    func friendlyFormat() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year) year ago" :
                "\(year) years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month) month ago" :
                "\(month) months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day) day ago" :
                "\(day) days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour) hour ago" :
                "\(hour) hours ago"
        } else if let min = interval.minute, min > 0 {
            return "\(min) min. ago"
        } else {
            return "a moment ago"
        }        
    }
}
