//
//  CVCalendarView.swift
//  CVCalendar
//


import UIKit

enum CVCalendarViewMode {
    case monthView
    case weekView
}

class CVCalendarView: UIView {
    
    // MARK: - Calendar Mode 
    
    var calendarMode: CVCalendarViewMode = .monthView
    
    func loadCalendarMode() {
        let calendarModeKey = "CVCalendarViewMode"
        let calendarMode = Bundle.main.object(forInfoDictionaryKey: calendarModeKey) as? String
        
        if calendarMode != nil {
            if calendarMode! == "MonthView" {
                if self.calendarMode != .monthView {
                    self.calendarMode = .monthView
                }
            } else {
                if self.calendarMode != .weekView {
                    self.calendarMode = .weekView
                }
            }
        }
        
        print("Mode is : \(calendarMode!)")
    }
    
    // MARK: - Current date 
    var presentedDate: CVDate? {
        didSet {
            self.delegate?.presentedDateUpdated(self.presentedDate!)
        }
    }
    
    // MARK: - Calendar View Delegate
    
    var shouldShowWeekdaysOut: Bool? {
        if let delegate = self.delegate {
            return delegate.shouldShowWeekdaysOut()
        } else {
            return false
        }
    }
    
    @IBOutlet var calendarDelegate: AnyObject? {
        set {
            if let calendarDelegate: AnyObject = newValue {
                if calendarDelegate.conforms(to: CVCalendarViewDelegate.self) {
                    self.delegate = calendarDelegate as? CVCalendarViewDelegate
                }
            }
        }
        
        get {
            return self.delegate
        }
    }
    
    var delegate: CVCalendarViewDelegate?
    
    // MARK: - Calendar Appearance Delegate
    
    @IBOutlet var calendarAppearanceDelegate: AnyObject? {
        set {
            if let calendarAppearanceDelegate: AnyObject = newValue {
                if calendarAppearanceDelegate.conforms(to: CVCalendarViewAppearanceDelegate.self) {
                    self.appearanceDelegate?.delegate = calendarAppearanceDelegate as? CVCalendarViewAppearanceDelegate
                }
            }
        }
        
        get {
            return self.appearanceDelegate
        }
    }
    
    var appearanceDelegate: CVCalendarViewAppearance? = CVCalendarViewAppearance.sharedCalendarViewAppearance
    
    // MARK: - Calendar Animator Delegate
    
    @IBOutlet var animatorDelegate: AnyObject? {
        set {
            if let animatorDelegate: AnyObject = newValue {
                if animatorDelegate.conforms(to: CVCalendarViewAnimatorDelegate.self) {
                    self.animator = animatorDelegate as? CVCalendarViewAnimatorDelegate
                }
            }
        }
        
        get {
            return self.animator
        }
    }
    
    var animator: CVCalendarViewAnimatorDelegate? = CVCalendarViewAnimator()
    
    // MARK: - Initialization
    
//    override init() {
//        super.init()
//        
//        isHidden = true
//        loadCalendarMode()
//        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isHidden = true
        loadCalendarMode()
        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
    }

    // IB Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        isHidden = true
        loadCalendarMode()
        contentController = CVCalendarContentViewController(calendarView: self, frame: bounds)
    }
    
    var contentController: CVCalendarContentViewController!
    
    // MARK: - Calendar View Control
    
    func changeDaysOutShowingState(_ shouldShow: Bool) {
        contentController.updateDayViews(shouldShow)
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView) {
        self.delegate?.didSelectDayView(dayView)
        if contentController != nil {
            contentController.performedDayViewSelection(dayView)
        }
    }
    
    // MARK: - Final preparation
    
    // Called on view's appearing.
    func commitCalendarViewUpdate() {
        let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
        coordinator.animator = self.animator
        contentController.updateFrames(bounds)
    }
    
    func toggleMonthViewWithDate(_ date: Date) {
        contentController.togglePresentedDate(date)
    }
    
    func toggleTodayMonthView() {
        contentController.togglePresentedDate(Date())
    }
    
    func loadNextMonthView() {
        contentController.presentNextView(nil)
    }
    
    func loadPreviousMonthView() {
        contentController.presentPreviousView(nil)
    }
}
