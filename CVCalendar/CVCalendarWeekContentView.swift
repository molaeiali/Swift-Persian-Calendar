//
//  CVCalendarWeekContentView.swift
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


class CVCalendarWeekContentView: NSObject, CVCalendarContentDelegate {

    // MARK: - Types work 
    
    typealias WeekView = CVCalendarWeekView
    typealias CalendarView = CVCalendarView
    typealias MonthView = CVCalendarMonthView
    typealias Manager = CVCalendarManager
    typealias Recovery = CVCalendarWeekContentRecovery
    typealias WeekContentView = CVCalendarWeekContentView
    typealias DayView = CVCalendarDayView
    typealias ContentController = CVCalendarContentViewController
    
    // MARK: Public properties
    
    // Contains 3 loaded weekViews & monthViews { Previous | Current | Next }.
    var weekViews: [Int : WeekView]!
    
    // MARK: Private properties
    
    fileprivate var page: Int! = 1 // The current one.
    fileprivate var presentedDate: Date!
    fileprivate var presentedMonthView: MonthView!
    
    fileprivate var calendarView: CalendarView!
    fileprivate var scrollView: UIScrollView!
    fileprivate var contentController: ContentController!
    
    // MARK: Initialization
    
    init(contentController: ContentController) {
        super.init()
        
        self.contentController = contentController
        self.scrollView = contentController.preparedScrollView()
        
        // Properties init.
        self.calendarView = contentController.calendarView
        self.presentedMonthView = contentController.presentedMonthView
        self.presentedDate = presentedMonthView.date! as Date!
        
        weekViews = [Int : WeekView]()
        
        // Add the scroll view.
        calendarView.addSubview(scrollView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Frames Reload 
    
    func _updateFrames() {
        let frame = scrollView.frame
        
        let countOfWeeks = CGFloat(presentedMonthView.weekViews!.count)
        let sizeConformedFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height * countOfWeeks)
        presentedMonthView.reloadWeekViewsWithMonthFrame(sizeConformedFrame)
        
        let presentedWeekView = self.presentedWeekView()
        let nextWeekView = self.nextWeekView(presentedWeekView)
        let previousWeekView = self.previousWeekView(presentedWeekView)
        
        insertWeekView(previousWeekView, atIndex: 0)
        insertWeekView(presentedWeekView, atIndex: 1)
        insertWeekView(nextWeekView, atIndex: 2)
        
        // Show the central page.
        scrollView.scrollRectToVisible(presentedWeekView.frame, animated: false)
        
        recovery.recoverMonthView(presentedMonthView)
    }
    
    // MARK: - Month Views Loading 
    
    fileprivate let calendar = Calendar.current
    fileprivate let manager = Manager.sharedManager
    
    func currentMonthView() -> MonthView {
        let countOfWeeks = CGFloat(manager.monthDateRange(presentedDate).countOfWeeks)
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height * countOfWeeks)
        let monthView = MonthView(calendarView: self.calendarView!, date: (presentedDate as! NSDate) as Date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func nextMonthView(_ date: Date) -> MonthView {
        let firstDate = manager.monthDateRange(date).monthStartDate
        
        var components = manager.componentsForDate(firstDate)
        components.month! += 1
        
        let _date = calendar.date(from: components)!
        let countOfWeeks = CGFloat(manager.monthDateRange(_date).countOfWeeks)
        
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height * countOfWeeks)
        let monthView = MonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    func previousMonthView(_ date: Date) -> MonthView {
        let firstDate = manager.monthDateRange(date).monthStartDate
        
        var components = manager.componentsForDate(firstDate)
        components.month! -= 1
        
        let _date = calendar.date(from: components)!
        let countOfWeeks = CGFloat(manager.monthDateRange(_date).countOfWeeks)
        
        let frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height * countOfWeeks)
        let monthView = MonthView(calendarView: self.calendarView!, date: _date)
        monthView.updateAppearance(frame)
        
        return monthView
    }
    
    // MARK: - Week Views Loading 
    
    func presentedWeekView() -> WeekView {
        var components = manager.componentsForDate(presentedDate)
        var index = components.weekOfMonth! - 1
        let weekView = presentedMonthView.weekViews![index]
        
        return weekView
    }
    
    func nextWeekView(_ weekView: WeekView) -> WeekView {
        let index = weekView.index! + 1
        let date = weekView.monthView!.date!
        let countOfWeeks = manager.monthDateRange(date).countOfWeeks
        
        var nextWeekView: WeekView!
        if index < countOfWeeks {
            let monthView = weekView.monthView!
            nextWeekView = monthView.weekViews![index]
        } else {
            let nextMonthView = self.nextMonthView(date as Date)
            nextWeekView = nextMonthView.weekViews!.first!
        }
        
        return nextWeekView
    }
    
    func previousWeekView(_ weekView: WeekView) -> WeekView {
        let index = weekView.index! - 1
        let date = weekView.monthView!.date!
        let countOfWeeks = manager.monthDateRange(date).countOfWeeks
        
        var previousWeekView: WeekView!
        if index >= 0 {
            let monthView = weekView.monthView!
            previousWeekView = monthView.weekViews![index]
        } else {
            let previousMonthView = self.previousMonthView(date as Date)
            previousWeekView = previousMonthView.weekViews!.last!
        }
        
        return previousWeekView
    }
    
    // MARK: Week Views Insertion 
    
    func insertWeekView(_ weekView: WeekView, atIndex index: Int) {
        let x = scrollView.bounds.width * CGFloat(index)
        let y = CGFloat(0)
        
        weekView.frame.origin = CGPoint(x: x, y: y)
        
        weekViews.updateValue(weekView, forKey: index)
        
        scrollView.addSubview(weekView)
    }
    
    func replaceWeekView(_ weekView: WeekView, toPage page: Int, animatable: Bool) {
        var frame = scrollView.frame
        frame.origin.x = frame.width * CGFloat(page)
        weekView.frame = frame
        
        if animatable {
            scrollView.scrollRectToVisible(frame, animated: false)
        }
        
        weekViews.updateValue(weekView, forKey: page)
    }
    
    // MARK: - Scroll Pages Update
    
    fileprivate var pageLoadingEnabled = true
    fileprivate lazy var recovery: Recovery = {
        let _recovery = Recovery()
        _recovery.weekContentView = self
        return _recovery
    }()
    
    func scrolledLeft() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let leftWeekView = weekViews[1]!
            let presentedWeekView = weekViews[2]!
            let rightWeekView = self.nextWeekView(presentedWeekView)
            
            // Update presented month view.
            presentedMonthView = presentedWeekView.monthView!
            presentedDate = presentedMonthView.date! as Date!
            
            let extraWeekView = weekViews.removeValue(forKey: 0)!
            extraWeekView.removeFromSuperview()
            
            presentedWeekView.utilizable = true
            recovery.recoverMonthView(presentedWeekView.monthView!)
            
            replaceWeekView(leftWeekView, toPage: 0, animatable: false)
            replaceWeekView(presentedWeekView, toPage: 1, animatable: true)
            
            insertWeekView(rightWeekView, atIndex: 2)
        }
    }
    
    func scrolledRight() {
        if self.page != 1 && self.pageLoadingEnabled {
            self.pageLoadingEnabled = false
            
            let rightWeekView = weekViews[1]!
            let presentedWeekView = weekViews[0]!
            let leftWeekView = self.previousWeekView(presentedWeekView)
            
            // Update presented month view.
            presentedMonthView = presentedWeekView.monthView!
            presentedDate = presentedMonthView.date! as Date!
            
            let extraWeekView = weekViews.removeValue(forKey: 2)!
            extraWeekView.removeFromSuperview()
            
            presentedWeekView.utilizable = true
            recovery.recoverMonthView(presentedWeekView.monthView!)
            
            replaceWeekView(rightWeekView, toPage: 2, animatable: false)
            replaceWeekView(presentedWeekView, toPage: 1, animatable: true)
            
            insertWeekView(leftWeekView, atIndex: 0)
        }
    }
    
    // MARK: - Scroll View Motion
    
    fileprivate var pageChanged = false
    fileprivate var lastContentOffset: CGFloat = 0
    fileprivate var direction: ScrollDirection = .none
    
    func _scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        prepareTopMarkersOnDayViews(weekViews[1]!, hidden: true)
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
                if self.weekViews[0] != nil {
                    self.scrolledLeft()
                }
            } else if self.direction == .right {
                if self.weekViews[2] != nil {
                    self.scrolledRight()
                }
            }
        }
        
        self.pageChanged = false
        self.pageLoadingEnabled = true
        self.direction = .none
        
        self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
        self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        
        let presentedWeekView = weekViews[1]!
        let presentedMonthView = presentedWeekView.monthView!
        if presentedMonthView != nil {
            self.calendarView.presentedDate = CVDate(date: presentedMonthView.date!)
        }
        
    }
    
    // MARK: - Day View Selection
    
    func _performedDayViewSelection(_ dayView: CVCalendarDayView) {
        if dayView.isOut {
            if dayView.date?.day > 20 {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateBeforeDate(presentedDate as Date) as (Date))
                self.presentPreviousWeekView(dayView)
            } else {
                let presentedDate = dayView.weekView!.monthView!.date!
                self.calendarView!.presentedDate = CVDate(date: self.dateAfterDate(presentedDate as Date) as (Date))
                self.presentNextWeekView(dayView)
            }
        }
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
    
    // MARK: - Week View Slide
    
    func presentNextWeekView(_ dayView: CVCalendarDayView?) {
        let extraWeekView = weekViews.removeValue(forKey: 0)!
        let leftWeekView = weekViews[1]!
        let presentWeekView = weekViews[2]!
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.prepareTopMarkersOnDayViews(leftWeekView, hidden: true)
            
            extraWeekView.frame.origin.x -= self.scrollView.bounds.width
            leftWeekView.frame.origin.x -= self.scrollView.bounds.width
            presentWeekView.frame.origin.x -= self.scrollView.bounds.width
            
            }, completion: { (finished) -> Void in
                
                extraWeekView.removeFromSuperview()
                presentWeekView.utilizable = true
                self.recovery.recoverMonthView(presentWeekView.monthView!)
                
                let rightWeekView = self.nextWeekView(presentWeekView)
                
                self.weekViews.updateValue(leftWeekView, forKey: 0)
                self.weekViews.updateValue(presentWeekView, forKey: 1)
                self.weekViews.updateValue(rightWeekView, forKey: 2)
                
                self.insertWeekView(rightWeekView, atIndex: 2)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentWeekView.monthView!)
                
                self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        })
    }
    
    func presentPreviousWeekView(_ dayView: CVCalendarDayView?) {
        
        let extraWeekView = weekViews.removeValue(forKey: 2)!
        let rightWeekView = weekViews[1]!
        let presentedWeekView = weekViews[0]!
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            presentedWeekView.utilizable = true
            self.prepareTopMarkersOnDayViews(rightWeekView, hidden: true)
            
            extraWeekView.frame.origin.x += self.scrollView.bounds.width
            rightWeekView.frame.origin.x += self.scrollView.bounds.width
            presentedWeekView.frame.origin.x += self.scrollView.bounds.width
            
            
            }, completion: { (finished) -> Void in

                extraWeekView.removeFromSuperview()
                self.recovery.recoverMonthView(presentedWeekView.monthView!)
                
                let leftWeekView = self.previousWeekView(presentedWeekView)
                
                self.weekViews.updateValue(leftWeekView, forKey: 0)
                self.weekViews.updateValue(presentedWeekView, forKey: 1)
                self.weekViews.updateValue(rightWeekView, forKey: 2)
                
                self.insertWeekView(leftWeekView, atIndex: 0)
                
                var day = 1
                if dayView != nil {
                    day = dayView!.date!.day!
                }
                
                self.selectDayViewWithDay(day, inMonthView: presentedWeekView.monthView!)
                
                self.prepareTopMarkersOnDayViews(self.weekViews[0]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[1]!, hidden: false)
                self.prepareTopMarkersOnDayViews(self.weekViews[2]!, hidden: false)
        })
    }
    
    // MARK: - Date Management 
    
    func dateBeforeDate(_ date: Date) -> Date {
        var components = manager.componentsForDate(date)
        components.month! -= 1
        
        let dateBefore = calendar.date(from: components)!
        
        return dateBefore
    }
    
    func dateAfterDate(_ date: Date) -> Date {
        var components = manager.componentsForDate(date)
        components.month! += 1
        
        let dateAfter = calendar.date(from: components)!
        
        return dateAfter
    }
    
    // MARK: - Visual Preparation 
    
    func prepareTopMarkersOnDayViews(_ weekView: WeekView, hidden: Bool) {
        if weekView.dayViews != nil {
            let dayViews = weekView.dayViews!
            
            for day in dayViews {
                day.topMarker?.isHidden = hidden
            }
        } else {
            print("Week View = \(weekView)")
            print("Month Date = \(weekView.monthView?.date)")
        }
    }
    
    /**
        Updates showing days out. Invoke if you want to hide days out or on the contrary unhide.
    
        :param: hidden A mask indicating if days out are shown or not.
    */
    func _updateDayViews(_ hidden: Bool) {
        func monthViews() -> [MonthView] {
            var monthViews = [MonthView]()
            
            func hasDuplicate(_ monthView: MonthView) -> Bool {
                for _monthView in monthViews {
                    if monthView == _monthView {
                        return true
                    }
                }
                
                return false
            }
            
            for weekView in weekViews.values {
                if let monthView = weekView.monthView {
                    if !hasDuplicate(monthView) {
                        monthViews.append(monthView)
                    }
                }
            }
            
            return monthViews
        }
        
        let presentedMonthViews = monthViews()
        for monthView in presentedMonthViews {
            if let weekViews = monthView.weekViews {
                for weekView in weekViews {
                    if let dayViews = weekView.dayViews {
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
        }
    }
    
    // MARK: - Week View Toggling 
    
    fileprivate var togglingBlocked = false
    func _togglePresentedDate(_ date: Date) {
        let currentWeekView = weekViews[1]!
        let currentDate = currentWeekView.monthView!.date!
        
        // Check if we should toggle. 
        if dateTogglingAllowed(date) {
            // Prepare cache data.
            for weekView in weekViews.values {
                if let monthView = weekView.monthView {
                    recovery.recoverMonthView(monthView)
                }
            }
            
            for key in weekViews.keys {
                let weekView = weekViews[key]
                if let monthView = weekView?.monthView {
                    recovery.recoverMonthView(monthView)
                }
                
                if key != 1 {
                    weekView?.removeFromSuperview()
                }
            }
            
            // Update presented month view.
            self.presentedDate = date
            self.presentedMonthView = currentMonthView()
            
            // Update week views.
            let presentedWeekView = self.presentedWeekView()
            let nextWeekView = self.nextWeekView(presentedWeekView)
            let previousWeekView = self.previousWeekView(presentedWeekView)
            
            presentedWeekView.alpha = 0
            
            insertWeekView(previousWeekView, atIndex: 0)
            insertWeekView(presentedWeekView, atIndex: 1)
            insertWeekView(nextWeekView, atIndex: 2)
            
            UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                presentedWeekView.alpha = 1
                currentWeekView.alpha = 0
                }) { (finished) -> Void in
                    let presentedDate = CVDate(date: date)
                    self.calendarView!.presentedDate = presentedDate
                    
                    if !self.dateTogglingAllowed(date) {
                        self.selectDayViewWithDay(presentedDate.day!, inMonthView: self.presentedMonthView)
                    } else {
                        let day = CVCalendarManager.sharedManager.dateRange(date).day
                        self.selectDayViewWithDay(day, inMonthView: self.presentedMonthView)
                    }
                    
                    self.togglingBlocked = false
            }
        }
    }
    
    func dateTogglingAllowed(_ date: Date) -> Bool {
        let presentedWeekView = weekViews[1]!
        let presentedIndex = presentedWeekView.index!
        var components = manager.componentsForDate(date)
        let currentIndex = components.weekOfMonth! - 1
        
        let currentDate = presentedWeekView.monthView!.date!
        
        let currentDateMonthStartDate = manager.monthDateRange(currentDate).monthStartDate
        let presentedDateMonthStartDate = manager.monthDateRange(date).monthStartDate
        
        var allowed = false
        if currentIndex != presentedIndex {
            allowed = true
        } else {
            if currentDateMonthStartDate != presentedDateMonthStartDate {
                allowed =  true
            }
        }
        
        return allowed
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
        presentNextWeekView(dayView)
    }
    
    func presentPreviousView(_ dayView: DayView?) {
        presentPreviousWeekView(dayView)
    }
    
    func updateDayViews(_ hidden: Bool) {
        _updateDayViews(hidden)
    }
    
    func togglePresentedDate(_ date: Date) {
        _togglePresentedDate(date)
    }
}
