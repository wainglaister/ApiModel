import Foundation
import RealmSwift

let standardTimeZone = NSTimeZone(forSecondsFromGMT: 0)
let standardLocale = NSLocale(localeIdentifier: "en_US_POSIX")

public class NSDateTransform: Transform {
    var dateFormatters: [NSDateFormatter] = []
    
    public init() {
        // ISO 8601 dates with time and zone
        let iso8601Formatter = NSDateFormatter()
        iso8601Formatter.timeZone = standardTimeZone
        iso8601Formatter.locale = standardLocale
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatters.append(iso8601Formatter.copy() as! NSDateFormatter)
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatters.append(iso8601Formatter.copy() as! NSDateFormatter)
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatters.append(iso8601Formatter.copy() as! NSDateFormatter)
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatters.append(iso8601Formatter.copy() as! NSDateFormatter)
    }
    
    public init(dateFormat: String) {
        let userDefinedDateFormatter = NSDateFormatter()
        userDefinedDateFormatter.timeZone = standardTimeZone
        userDefinedDateFormatter.dateFormat = dateFormat
        
        dateFormatters.insert(userDefinedDateFormatter, atIndex: 0)
    }
    
    public func perform(value: AnyObject?, realm: Realm?) -> AnyObject? {
        if let dateValue = value as? NSDate {
            return dateValue
        }

        if let stringValue = value as? String {
            for formatter in dateFormatters {
                if let date = formatter.dateFromString(stringValue) {
                    return date
                }
            }
        }

        return nil
    }
}
