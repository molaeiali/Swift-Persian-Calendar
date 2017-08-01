//
//  CVCalendarRenderer.swift
//  CVCalendar
//


import UIKit

class CVCalendarRenderer: NSObject {
    private(set) static var instance = CVCalendarRenderer()
//    private lazy var __once: () = { () -> Void in
//            _self = CVCalendarRenderer()
//        }()
    
    // MARK: Initialization 
    
    fileprivate override init() {
        super.init()
    }
    
    // MARK: - Public properties
    
    lazy var appearance: CVCalendarViewAppearance = {
        return CVCalendarViewAppearance.sharedCalendarViewAppearance
        }()
    
    class func sharedRenderer() -> CVCalendarRenderer {
//        var _self: CVCalendarRenderer?
//        
//        var t: Int = 0
//        _ = self.__once
//        
        return instance
    }
    
    // MARK: - Rendering 
    
    func renderWeekFrameForMonthView(_ monthView: CVCalendarMonthView, weekIndex: Int) -> CGRect {
        let width = monthView.frame.width
        let space = self.appearance.spaceBetweenWeekViews!
        let height = CGFloat((monthView.frame.height / CGFloat(monthView.numberOfWeeks!)) - space) + space / 0.5
        
        let y: CGFloat = CGFloat(weekIndex) * (height + space)
        let x: CGFloat = 0

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func renderDayFrameForMonthView(_ weekView: CVCalendarWeekView, dayIndex: Int) -> CGRect {
        let space = self.appearance.spaceBetweenDayViews!
        let width = CGFloat((weekView.frame.width / 7) - space)
        let height = weekView.frame.height
        
        let x = CGFloat(dayIndex) * (width + space) + space / 2
        let y = CGFloat(0)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }

}
