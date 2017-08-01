//
//  CVCalendarMonthContentView.swift
//  CVCalendar Demo
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ScrollDirection {
    case none
    case right
    case left
}

class CVCalendarMonthContentView: NSObject, CVCalendarContentDelegate {

    // MARK: - Types work
    
    typealias WeekView = CVCalendarWeekView
    typealias CalendarView = CVCalendarView
    typealias MonthView = CVCalendarMonthView
    typealias Manager = CVCalendarManager
    typealias Recovery = CVCalendarWeekContentRecovery
    typealias WeekContentView = CVCalendarWeekContentView
    typealias DayView = CVCalendarDayView
    typealias ContentController = CVCalendarContentViewController
    
    // MARK: - Public Properties
    
    var monthViews: [Int : CVCalendarMonthView]!
    
    // MARK: - Private Properties
    
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var page: Int = 1
    fileprivate var pageChanged = false
    fileprivate var pageLoadingEnabled = true
    fileprivate var direction: ScrollDirection = .none
    
    fileprivate var controller: CVCalendarContentViewController!
    fileprivate var calendarView: CVCalendarView!
    fileprivate var presentedMonthView: CVCalendarMonthView!
    fileprivate var contentController: ContentController!
    fileprivate var scrollView: UIScrollView!
    
    // MARK: - Initialization
    
    init(contentController: ContentController) {
        super.init()
        
        self.contentController = contentController
        self.calendarView = contentController.calendarView
        self.presentedMonthView = contentController.presentedMonthView
        self.scrollView = contentController.preparedScrollView()
        
        self.monthViews = [Int : CVCalendarMonthView]()
        self.initialLoad(presentedMonthView)
        
        // Add the scroll view.
        calendarView.addSubview(scrollView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Insertion & Removing
    
    func insertMonthView(_ monthView: CVCalendarMonthView, atIndex index: Int) {
        let x = scrollView.bounds.width * CGFloat(index)
        let y = CGFloat(0)
        
        monthView.frame.origin = CGPoint(x: x, y: y)
        
        monthViews.updateValue(monthView, forKey: index)
        
        scrollView.addSubview(monthView)
    }
    
    // MARK: - Motion control
    
    func _scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: true)
    }
    
    func _scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        
        let page = Int(floor((scrollView.contentOffset.x - width/2) / width) + 1)
        if page != self.page {
            self.page = page
            
            if !self.pageChanged {
                self.pageChanged = true
            } else {
                self.pageChanged = false
            }
        }
        
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
        }
        
        if self.lastContentOffset > scrollView.contentOffset.x {
            self.direction = .right
        } else if self.lastContentOffset < scrollView.contentOffset.x {
            self.direction = .left
        }
        
        self.lastContentOffset = scrollView.contentOffset.x
    }
    
    func _scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.pageChanged {
            if self.direction == .left {
                if self.monthViews![0] != nil {
                    self.scrolledLeft()
                }
            } else if self.direction == .right {
                if self.monthViews![2] != nil {
                    self.scrolledRight()
                }
            }
        }
        
        self.pageChanged = false
        self.pageLoadingEnabled = true
        self.direction = .none
        
        self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        
        self.calendarView!.presentedDate = CVDate(date: self.monthViews![1]!.date!)
    }
    
    // MARK: - Page control
    
    func initialLoad(_ presentedMonthView: CVCalendarMonthView) {
        let previousMonth = self.getPreviousMonth(presentedMonthView.date! as Date)
        let nextMonth = self.getNextMonth(presentedMonthView.date! as Date)
        
        self.monthViews!.updateValue(previousMonth, forKey: 0)
        self.monthViews!.updateValue(presentedMonthView, forKey: 1)
        self.monthViews!.updateValue(nextMonth, forKey: 2)
        
        self.insertMonthView(previousMonth, atIndex: self.page - 1)
        self.insertMonthView(presentedMonthView, atIndex: self.page)
        self.insertMonthView(nextMonth, atIndex: self.page + 1)
        
        self.calendarView!.presentedDate = CVDate(date: presentedMonthView.date!)
    }
    
    func replaceMonthView(_ monthView: CVCalendarMonthView, toPage page: Int, animatable: Bool) {
        var frame = monthView.frame
        frame.origin.x = frame.width * CGFloat(page)
        monthView.frame = frame
        if animatable {
            scrollView.scrollRectToVisible(frame, animated: false)
        }
    }
    
    // MARK: - Date preparation
    
    func getNextMonth(_ date: Date) -> CVCalendarMonthView {
        let calendar = CVCalendarManager.sharedManager.calendar
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        var components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month! += 1
        
        let _date = calendar!.date(from: components)
        
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date!)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func getPreviousMonth(_ date: Date) -> CVCalendarMonthView {
        let calendar = CVCalendarManager.sharedManager.calendar
        let calendarManager = CVCalendarManager.sharedManager
        
        let firstDate = calendarManager.monthDateRange(date).monthStartDate
        
        var components = CVCalendarManager.sharedManager.componentsForDate(firstDate)
        components.month! -= 1
        
        let _date = calendar!.date(from: components)
        
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        let monthView = CVCalendarMonthView(calendarView: self.calendarView!, date: _date!)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    // MARK: - Page loading on scrolling
    
    func scrolledLeft() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let leftMonthView = self.monthViews![1]
            let presented = self.monthViews![2]
            let date = presented!.date!
            
            self.replaceMonthView(leftMonthView!, toPage: 0, animatable: false)
            self.replaceMonthView(presented!, toPage: 1, animatable: true)
            
            var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValue(forKey: 0)
            extraMonthView!.removeFromSuperview()
            extraMonthView!.destroy()
            extraMonthView = nil
            
            let rightMonthView = self.getNextMonth(date as Date)
            
            self.monthViews!.updateValue(leftMonthView!, forKey: 0)
            self.monthViews!.updateValue(presented!, forKey: 1)
            self.monthViews!.updateValue(rightMonthView, forKey: 2)
            
            self.insertMonthView(rightMonthView, atIndex: 2)
        }
    }
    
    func scrolledRight() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let rightMonthView = self.monthViews![1]
            let presented = self.monthViews![0]
            let date = presented!.date!
            
            self.replaceMonthView(rightMonthView!, toPage: 2, animatable: false)
            self.replaceMonthView(presented!, toPage: 1, animatable: true)
            
            var extraMonthView: CVCalendarMonthView? = self.monthViews!.removeValue(forKey: 2)
            extraMonthView!.removeFromSuperview()
            extraMonthView!.destroy()
            extraMonthView = nil
            
            let leftMonthView = self.getPreviousMonth(date as Date)
            
            self.monthViews!.updateValue(leftMonthView, forKey: 0)
            self.monthViews!.updateValue(presented!, forKey: 1)
            self.monthViews!.updateValue(rightMonthView!, forKey: 2)
            
            self.insertMonthView(leftMonthView, atIndex: 0)
        }
    }
    

    
    // MARK: - Visual preparation
    
    func prepareTopMarkersOnDayViews(_ monthView: CVCalendarMonthView, hidden: Bool) {
        let weekViews = monthView.weekViews!
        
        for week in weekViews {
            let dayViews = week.dayViews!
            
            for day in dayViews {
                day.topMarker?.isHidden = hidden
            }
        }
    }
    
    func _updateDayViews(_ hidden: Bool) {
        let values = self.monthViews!.values
        for monthView in values {
            let weekViews = monthView.weekViews!
            for weekView in weekViews {
                let dayViews = weekView.dayViews!
                for dayView in dayViews {
                    if dayView.isOut {
                        if !hidden {
                            dayView.alpha = 0
                            dayView.isHidden = false
                        }
                        
                        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                            if hidden {
                                dayView.alpha = 0
                            } else {
                                dayView.alpha = 1
                            }
                            
                            }, completion: { (finished) -> Void in
                                if hidden {
                                    dayView.isHidden = true
                                    dayView.alpha = 1
                                }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Frame management
    
    func _updateFrames() {
        let frame = scrollView.frame
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        let monthViews = self.monthViews!.values
        for monthView in monthViews {
            monthView.reloadWeekViewsWithMonthFrame(frame)
        }
        
        replaceMonthViewsOnReload()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 3, height: scrollView.frame.size.height)
        
        let presentedMonthView = self.monthViews![1]!
        scrollView.scrollRectToVisible(presentedMonthView.frame, animated: false)
        
    }
    
    func replaceMonthViewsOnReload() {
        let keys = self.monthViews!.keys
        for key in keys {
            let monthView = self.monthViews![key]!
            monthView.frame.origin.x = CGFloat(key) * scrollView.frame.width
            scrollView.addSubview(monthView)
        }
    }
    
    // MARK: - Day View Out selection
    
    func dateBeforeDate(_ date: Date) -> Date {
        var components = CVCalendarManager.sharedManager.componentsForDate(date)
        let calendar = Calendar.current
        
        components.month! -= 1
        
        let dateBefore = calendar.date(from: components)!
        
        return dateBefore
    }
    
    func dateAfterDate(_ date: Date) -> Date {
        var components = CVCalendarManager.sharedManager.componentsForDate(date)
        let calendar = Calendar.current
        
        components.month! += 1
        
        let dateAfter = calendar.date(from: components)!
        
        return dateAfter
    }
    
    func selectDayViewWithDay(_ day: Int, inMonthView monthView: CVCalendarMonthView) {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        for weekView in monthView.weekViews! {
            for dayView in weekView.dayViews! {
                if dayView.date?.day == day && !dayView.isOut {
                    coordinator.performDayViewSelection(dayView)
                }
            }
        }
    }
    
    func _performedDayViewSelection(_ dayView: CVCalendarDayView) {
        if dayView.isOut {
            if dayView.date?.day > 20 {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate as Date) as (Date))
                
                self.presentPreviousMonthView(dayView)
                
            } else {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateAfterDate(presentedDate as Date) as (Date))
                self.presentNextMonthView(dayView)
            }
        }
    }
    
    func presentNextMonthView(_ dayView: CVCalendarDayView?) {
        var extraMonthView = self.monthViews![0]
        let leftMonthView = self.monthViews![1]!
        let presentedMonthView = self.monthViews![2]!
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(leftMonthView, hidden: true)
            
            extraMonthView!.frame.origin.x -= self.scrollView.frame.width
            leftMonthView.frame.origin.x -= self.scrollView.frame.width
            presentedMonthView.frame.origin.x -= self.scrollView.frame.width
            
            }, completion: { (finished) -> Void in
                extraMonthView!.removeFromSuperview()
                extraMonthView!.destroy()
                extraMonthView = nil
                
                let rightMonthView = self.getNextMonth(presentedMonthView.date! as Date)
                
                self.monthViews?.updateValue(leftMonthView, forKey: 0)
                self.monthViews?.updateValue(presentedMonthView, forKey: 1)
                self.monthViews?.updateValue(rightMonthView, forKey: 2)
                
                self.insertMonthView(rightMonthView, atIndex: 2)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                
                self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        })
    }
    
    func presentPreviousMonthView(_ dayView: CVCalendarDayView?) {
        
        var extraMonthView = self.monthViews!.removeValue(forKey: 2)
        let rightMonthView = self.monthViews![1]!
        let presentedMonthView = self.monthViews![0]!
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(rightMonthView, hidden: true)
            
            extraMonthView!.frame.origin.x += self.scrollView.frame.width
            rightMonthView.frame.origin.x += self.scrollView.frame.width
            presentedMonthView.frame.origin.x += self.scrollView.frame.width
            
            
            
            }, completion: { (finished) -> Void in
                
                extraMonthView!.removeFromSuperview()
                extraMonthView!.destroy()
                extraMonthView = nil
                
                let leftMonthView = self.getPreviousMonth(presentedMonthView.date! as Date)
                
                self.monthViews?.updateValue(leftMonthView, forKey: 0)
                self.monthViews?.updateValue(presentedMonthView, forKey: 1)
                self.monthViews?.updateValue(rightMonthView, forKey: 2)
                
                self.insertMonthView(leftMonthView, atIndex: 0)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                
                self.prepareTopMarkersOnDayViews(self.monthViews![0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.monthViews![2]!, hidden: false)
        })
    }
    
    // MARK: - Month Views' toggling
    
    fileprivate var togglingBlocked = false
    func _togglePresentedDate(_ date: Date) {
        var currentMonthView = self.monthViews![1]
        let currentDate = currentMonthView!.date!
        
        if !self.date(currentDate as Date, equalToPresentedDate: date) && !self.togglingBlocked {
            self.togglingBlocked = true
            let rightMonthView = self.getNextMonth(date)
            let leftMonthView = self.getPreviousMonth(date)
            
            var extraLeftMonthView = self.monthViews!.removeValue(forKey: 0)
            var extraRightMonthView = self.monthViews!.removeValue(forKey: 2)
            
            extraLeftMonthView?.removeFromSuperview()
            extraLeftMonthView?.destroy()
            extraLeftMonthView = nil
            
            extraRightMonthView?.removeFromSuperview()
            extraRightMonthView?.destroy()
            extraRightMonthView = nil
            
            let presentedMonthView = CVCalendarMonthView(calendarView: self.calendarView!, date: date)
            let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            presentedMonthView.updateAppearance(frame)
            presentedMonthView.alpha = 0
            
            self.insertMonthView(presentedMonthView, atIndex: 1)
            
            UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                presentedMonthView.alpha = 1
                currentMonthView?.alpha = 0
                }) { (finished) -> Void in
                    self.monthViews!.removeValue(forKey: 1)
                    currentMonthView!.removeFromSuperview()
                    currentMonthView!.destroy()
                    currentMonthView = nil
                    
                    self.monthViews!.updateValue(leftMonthView, forKey: 0)
                    self.monthViews!.updateValue(presentedMonthView, forKey: 1)
                    self.monthViews!.updateValue(rightMonthView, forKey: 2)
                    
                    self.insertMonthView(leftMonthView, atIndex: 0)
                    self.insertMonthView(rightMonthView, atIndex: 2)
                    
                    let presentedDate = CVDate(date: date)
                    self.calendarView!.presentedDate = presentedDate
                    if self.date(date, equalToPresentedDate: Date()) {
                        self.selectDayViewWithDay(presentedDate.day!, inMonthView: presentedMonthView)
                    } else {
                        let day = CVCalendarManager.sharedManager.dateRange(date).day
                        self.selectDayViewWithDay(day, inMonthView: presentedMonthView)
                    }
                    
                    
                    self.togglingBlocked = false
            }
        }
    }
    
    func date(_ currentDate: Date, equalToPresentedDate presentedDate: Date) -> Bool {
        let calendarManager = CVCalendarManager.sharedManager
        
        let currentDateMonthStartDate = calendarManager.monthDateRange(currentDate).monthStartDate
        let presentedDateMonthStartDate = calendarManager.monthDateRange(presentedDate).monthStartDate
        
        if currentDateMonthStartDate == presentedDateMonthStartDate {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Content View Delegate
    
    func updateFrames() {
        _updateFrames()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _scrollViewWillBeginDragging(scrollView)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _scrollViewDidEndDecelerating(scrollView)
    }
    
    func performedDayViewSelection(_ dayView: CVCalendarDayView) {
        _performedDayViewSelection(dayView)
    }
    
    func presentNextView(_ dayView: DayView?) {
        presentNextMonthView(dayView)
    }
    
    func presentPreviousView(_ dayView: DayView?) {
        presentPreviousMonthView(dayView)
    }
    
    func updateDayViews(_ hidden: Bool) {
        _updateDayViews(hidden)
    }
    
    func togglePresentedDate(_ date: Date) {
        _togglePresentedDate(date)
    }
}
