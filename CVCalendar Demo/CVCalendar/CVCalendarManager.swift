//
//  CVCalendarManager.swift
//  CVCalendar
//


import UIKit

private let sharedInstance = CVCalendarManager()

class CVCalendarManager: NSObject {
    // MARK: - Private properties
    fileprivate var components: DateComponents?
    
    var calendar: NSCalendar!
    
    // MARK: - Public properties
    var currentDate: Date!
    
    class var sharedManager: CVCalendarManager {
        return sharedInstance
    }
    
    // MARK: - Private initialization
    
    var starterWeekday: Int?
    
    fileprivate override init() {
//        self.calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        self.calendar = NSCalendar(identifier: NSCalendar.Identifier.persian)!
//        self.currentDate = NSDate()
//        self.components = self.calendar!.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self.currentDate!)
        
        let propertyName = "CVCalendarStarterWeekday"
        let firstWeekday = Bundle.main.object(forInfoDictionaryKey: propertyName) as? Int
        if firstWeekday != nil {
            self.starterWeekday = firstWeekday
            self.calendar!.firstWeekday = starterWeekday!
        } else {
            let currentCalendar = Calendar.current
            let firstWeekday = currentCalendar.firstWeekday
            self.starterWeekday = firstWeekday
            self.calendar!.firstWeekday = starterWeekday!
        }
    }
    
    // MARK: - Common date analysis
    
    func monthDateRange(_ date: Date) -> (countOfWeeks: NSInteger, monthStartDate: Date, monthEndDate: Date) {
//        let units = (NSCalendar.Unit.YearCalendarUnit | NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.WeekCalendarUnit)
        var components = self.calendar!.components([.year,.month,.weekOfMonth], from: date)
        
        // Start of the month.
        components.day = 1
        let monthStartDate = self.calendar?.date(from: components)
        
        // End of the month.
        components.month! += 1
        components.day! -= 1
        let monthEndDate = self.calendar?.date(from: components)
        
        // Range of the month.
        let range = self.calendar?.range(of: NSCalendar.Unit.weekOfMonth, in: NSCalendar.Unit.month, for: date)
        let countOfWeeks = range?.length
        
        return (countOfWeeks!, monthStartDate!, monthEndDate!)
    }
    
    func dateRange(_ date: Date) -> (year: Int, month: Int, day: Int) {
        
//        let units = NSCalendar.Unit.YearCalendarUnit | NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.WeekCalendarUnit | NSCalendar.Unit.DayCalendarUnit
        let components = self.calendar!.components([.year,.month,.weekOfMonth,.day], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        
        return (year!, month!, day!)
    }
    
    func weekdayForDate(_ date: Date) -> Int {
//        let units = NSCalendar.Unit.WeekdayCalendarUnit
        
        let components = self.calendar!.components([.weekday], from: date)
        
        //println("NSDate: \(date), Weekday: \(components.weekday)")
        
        let weekday = self.calendar!.ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: date)
        
        return Int(components.weekday!)
    }
    
    // MARK: - Analysis sorting
    
    func weeksWithWeekdaysForMonthDate(_ date: Date) -> (weeksIn: [[Int : [Int]]], weeksOut: [[Int : [Int]]]) {
        
        let countOfWeeks = self.monthDateRange(date).countOfWeeks
        let totalCountOfDays = countOfWeeks * 7
        let firstMonthDateIn = self.monthDateRange(date).monthStartDate
        let lastMonthDateIn = self.monthDateRange(date).monthEndDate
        let countOfDaysIn = self.dateRange(lastMonthDateIn).day
        let countOfDaysOut = totalCountOfDays - countOfDaysIn
        
        // Find all dates in.
        var datesIn = [Date]()
        for day in 1...countOfDaysIn {
            var components = self.componentsForDate(firstMonthDateIn)
            components.day = day
            let date = self.calendar!.date(from: components)!
            datesIn.append(date)
        }
        
        // Find all dates out.
        
        
        let firstMonthDateOut: Date? = {
            let firstMonthDateInWeekday = self.weekdayForDate(firstMonthDateIn)
            if firstMonthDateInWeekday == self.starterWeekday {
                print("here")
                return firstMonthDateIn
            }
            
            var components = self.componentsForDate(firstMonthDateIn)
            for _ in 1...7 {
                components.day! -= 1
                let updatedDate = self.calendar!.date(from: components)!
//                updatedDate
                let updatedDateWeekday = self.weekdayForDate(updatedDate)
                if updatedDateWeekday == self.starterWeekday {
//                    updatedDate
                    return updatedDate
                }
            }
            
            let diff = 7 - firstMonthDateInWeekday
            for _ in diff..<7 {
                components.day! += 1
                let updatedDate = self.calendar!.date(from: components)!
                let updatedDateWeekday = self.weekdayForDate(updatedDate)
                if updatedDateWeekday == self.starterWeekday {
//                    updatedDate
                    return updatedDate
                }
            }
            
            return nil
            }()
        
        
        // Constructing weeks.
        
        var firstWeekDates = [Date]()
        var lastWeekDates = [Date]()
        
        var firstWeekDate = (firstMonthDateOut != nil) ? firstMonthDateOut! : firstMonthDateIn
        var components = self.componentsForDate(firstWeekDate)
        components.day! += 6
        var lastWeekDate = self.calendar!.date(from: components)!
        
        func nextWeekDateFromDate(_ date: Date) -> Date {
            var components = self.componentsForDate(date)
            components.day! += 7
            let nextWeekDate = self.calendar!.date(from: components)!
            return nextWeekDate
        }
        
        for weekIndex in 1...countOfWeeks {
            firstWeekDates.append(firstWeekDate)
            lastWeekDates.append(lastWeekDate)
            
            firstWeekDate = nextWeekDateFromDate(firstWeekDate)
            lastWeekDate = nextWeekDateFromDate(lastWeekDate)
        }
        
        // Dictionaries.
        
        var weeksIn = [[Int : [Int]]]()
        var weeksOut = [[Int : [Int]]]()
        
        let count = firstWeekDates.count
        
        for i in 0..<count {
            var weekdaysIn = [Int : [Int]]()
            var weekdaysOut = [Int : [Int]]()
            
            let firstWeekDate = firstWeekDates[i]
            let lastWeekDate = lastWeekDates[i]
            
            var components = self.componentsForDate(firstWeekDate)
            for weekday in 1...7 {
                let weekdate = self.calendar!.date(from: components)!
                components.day! += 1
                let day = self.dateRange(weekdate).day
                
                func addDay(_ weekdays: inout [Int : [Int]]) {
                    var days = weekdays[weekday]
                    if days == nil {
                        days = [Int]()
                    }
                    
                    days!.append(day)
                    weekdays.updateValue(days!, forKey: weekday)
                }
                
                if i == 0 && day > 20 {
                    addDay(&weekdaysOut)
                } else if i == countOfWeeks - 1 && day < 10 {
                    addDay(&weekdaysOut)
                    
                } else {
                    addDay(&weekdaysIn)
                }
            }
            
            if weekdaysIn.count > 0 {
                weeksIn.append(weekdaysIn)
            }
            
            if weekdaysOut.count > 0 {
                weeksOut.append(weekdaysOut)
            }
        }
        
        return (weeksIn, weeksOut)
    }
    
    // MARK: - Util methods
    
    func componentsForDate(_ date: Date) -> DateComponents {
//        let units = NSCalendar.Unit.YearCalendarUnit | NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.WeekOfMonthCalendarUnit | NSCalendar.Unit.DayCalendarUnit
        let components = self.calendar!.components([.year,.month,.weekOfMonth,.day], from: date)
        return components
    }
    
    func monthSymbols() -> [AnyObject] {
        return self.calendar!.monthSymbols as [AnyObject]
    }
    
    func shortWeekdaySymbols() -> [AnyObject] {
        return self.calendar!.shortWeekdaySymbols as [AnyObject]
    }
}
