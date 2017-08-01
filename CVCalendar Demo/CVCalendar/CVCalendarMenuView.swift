//
//  CVCalendarMenuView.swift
//  CVCalendar
//


import UIKit
import Foundation

class CVCalendarMenuView: UIView {
    
    var starterWeekday = 1
    
    var symbols = [String]()
    var symbolViews: [UILabel]?
//    let weeks = ["Doshanbeh", "Seshhanbeh", "Chaharshanbeh", "Panjshanbeh", "Jomeh", "Shanbeh", "Yek shanbeh"]
//    let weeks = ["Sha", "Yek", "Dos", "Ses", "Cha", "Pan", "Jom"]
    let weeks = ["ش", "ی", "د", "س", "چ", "پ", "ج"]
    
//    override init() {
//        super.init()
//        
//        self.setupWeekdaySymbols()
//        self.createDaySymbols()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupWeekdaySymbols()
        self.createDaySymbols()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        

        self.setupWeekdaySymbols()
        self.createDaySymbols()
    }
    
    func setupWeekdaySymbols() {
        let propertyName = "CVCalendarStarterWeekday"
        let firstWeekday = Bundle.main.object(forInfoDictionaryKey: propertyName) as? Int
        if firstWeekday != nil {
            self.starterWeekday = firstWeekday!
        } else {
            let currentCalendar = Calendar.current
            let firstWeekday = currentCalendar.firstWeekday
            self.starterWeekday = firstWeekday
        }
        
        
        var calendar = Calendar(identifier: Calendar.Identifier.persian)
//        calendar.components(NSCalendar.Unit.MonthCalendarUnit | NSCalendar.Unit.DayCalendarUnit, fromDate: Date())///Not
        calendar.dateComponents([.month,.day], from: Date())///Not
        calendar.firstWeekday = self.starterWeekday
        
        symbols = calendar.weekdaySymbols as [String]
    }
    
    func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = DateFormatter()
//        dateFormatter.locate = NSLocate(locateIdentifier:"fa_IR")
//        let IRLocal = NSLocate(indentifier: "fa_IR")!
//        dateFormatter.locate = IRLocal
        
        var weekdays = dateFormatter.shortWeekdaySymbols as NSArray
        
        let firstWeekdayIndex = starterWeekday - 1
        if (firstWeekdayIndex > 0) {
            let copy = weekdays
            weekdays = (weekdays.subarray(with: NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)) as NSArray)
            weekdays = weekdays.addingObjects(from: copy.subarray(with: NSMakeRange(0, firstWeekdayIndex))) as NSArray
        }
        
        self.symbols = weekdays as! [String]
        
        // Add symbols.
        self.symbolViews = [UILabel]()
        let space = 0 as CGFloat
        let width = self.frame.width / 7 - space
        let height = self.frame.height
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        for i in 0..<7 {
            x = CGFloat(i) * width + space
            
            let symbol = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            symbol.textAlignment = .center
            symbol.text = (self.weeks[i]).uppercased()
            symbol.font = UIFont.boldSystemFont(ofSize: 10) // may be provided as a delegate property
            symbol.textColor = UIColor.darkGray
            
            self.symbolViews?.append(symbol)
            self.addSubview(symbol)
        }
    }
    
    func commitMenuViewUpdate() {
        let space = 0 as CGFloat
        let width = self.frame.width / 7 - space
        let height = self.frame.height
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        for i in 0..<self.symbolViews!.count {
            x = CGFloat(i) * width + space
            
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let symbol = self.symbolViews![i]
            symbol.frame = frame
        }
    }
}
