//
//  CVDate.swift
//  CVCalendar
//

import UIKit

class CVDate: NSObject {
    fileprivate var date: Date?
    var year: Int?
    var month: Int?
    var week: Int?
    var day: Int?
    let months = ["Farvardin", "Ordibehesht", "Khordad", "Tir", "Mordad", "Shahrivar", "Mehr", "Aban", "Azar", "Day", "Bahman", "Esfand"]
    init(date: Date) {
        super.init()
        
        let calendarManager = CVCalendarManager.sharedManager
        
        self.date = date
        
        self.year = calendarManager.dateRange(date).year
        self.month = calendarManager.dateRange(date).month
        self.day = calendarManager.dateRange(date).day
    }
    
    init(day: Int, month: Int, week: Int, year: Int) {
        super.init()
        
        self.year = year
        self.month = month
        self.week = week
        self.day = day
    }
    
    func description2() -> String {

        let myMonth:Int = self.month!
        let monthStr = self.months[myMonth - 1]
        
        return "\(monthStr), \(self.year!)"
    }
    func convertToPersian() ->Date{
        let calendar = Calendar(identifier: Calendar.Identifier.persian)///
//        let components = calendar.components(NSCalendar.Unit.YearCalendarUnit | NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.DayCalendarUnit, fromDate: date!)
        let components = calendar.dateComponents([.year,.weekOfMonth,.day], from: date!)
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        let myMonth:Int = components.month!
        let myYear:Int = components.year!
        let myDay:Int = components.day!
        let str = dateFormater.date(from: "\(myYear)-\(myMonth)-\(myDay)")!
        
        return str
    }
}
