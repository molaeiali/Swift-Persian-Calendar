//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//


import UIKit

class CVCalendarContentViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Type Work 
    
    typealias CalendarView = CVCalendarView
    typealias ContentDelegate = CVCalendarContentDelegate
    typealias CalendarMode = CVCalendarViewMode
    typealias MonthContent = CVCalendarMonthContentView
    typealias WeekContent = CVCalendarWeekContentView
    typealias MonthView = CVCalendarMonthView
    typealias DayView = CVCalendarDayView
    
    // MARK: - Private Properties
    
    var calendarView: CalendarView!
    var presentedMonthView: MonthView!
    
    fileprivate var scrollView: UIScrollView!
    fileprivate var delegate: ContentDelegate!

    // MARK: - Initialization 
    
    init(calendarView: CalendarView, frame: CGRect, coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)!
        } else {
            super.init(nibName: nil, bundle:nil)
        }
        
        self.calendarView = calendarView
        self.scrollView = UIScrollView(frame: frame)
        
        // Setup Scroll View. 
        scrollView.contentSize = CGSize(width: frame.width * 3, height: frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        presentedMonthView = MonthView(calendarView: calendarView, date: Date())///Not
        
        if calendarView.calendarMode == CalendarMode.monthView {
            delegate = MonthContent(contentController: self)
            print("Scroll View: \(scrollView)")
        } else {
            delegate = WeekContent(contentController: self)
            print("Scroll View: \(scrollView)")
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Control 
    
    func preparedScrollView() -> UIScrollView {
        if let scrollView = self.scrollView {
            return scrollView
        } else {
            return UIScrollView()
        }
    }
    
    // MARK: - Appearance Update 
    
    func updateFrames(_ frame: CGRect) {
        print("Updating 1")
        
        presentedMonthView.updateAppearance(frame)
        
        scrollView.frame = frame
        scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
        
        delegate.updateFrames()
        
        calendarView.isHidden = false
    }
    
    // MARK: - Scroll View Delegate 
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate.scrollViewWillBeginDragging(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate.scrollViewDidEndDecelerating(scrollView)
    }
    
    // MARK: - Day View Selection
    
    func performedDayViewSelection(_ dayView: DayView) {
        delegate.performedDayViewSelection(dayView)
    }
    
    // MARK: - Toggle Date
    
    func togglePresentedDate(_ date: Date) {
        delegate.togglePresentedDate(date)
    }
    
    // MARK: - Paging 
    
    func presentNextView(_ dayView: DayView?) {
        delegate.presentNextView(dayView)
    }
    
    func presentPreviousView(_ dayView: DayView?) {
        delegate.presentPreviousView(dayView)
    }
    
    // MARK: - Days Out Showing
    
    func updateDayViews(_ hidden: Bool) {
        delegate.updateDayViews(hidden)
    }
}
