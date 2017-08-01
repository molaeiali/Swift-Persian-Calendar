//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//


import UIKit

private let instance = CVCalendarDayViewControlCoordinator()

class CVCalendarDayViewControlCoordinator: NSObject {
    
    var inOrderNumber = 0
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }
   
    var selectedDayView: CVCalendarDayView? = nil
    var animator: CVCalendarViewAnimatorDelegate?
    
    lazy var appearance: CVCalendarViewAppearance = {
       return CVCalendarViewAppearance.sharedCalendarViewAppearance
    }()
    
    fileprivate override init() {
        super.init()
    }
    
    func performDayViewSelection(_ dayView: CVCalendarDayView) {
        if let selectedDayView = self.selectedDayView {
            if selectedDayView != dayView {
                if self.inOrderNumber < 2 {
                    self.presentDeselectionOnDayView(self.selectedDayView!)
                    self.selectedDayView = dayView
                    self.presentSelectionOnDayView(self.selectedDayView!)
                }
            }
        } else {
            self.selectedDayView = dayView
            if self.animator == nil {
                self.animator = self.selectedDayView!.weekView!.monthView!.calendarView!.animator
            }
            self.presentSelectionOnDayView(self.selectedDayView!)
        }
    }
    
    fileprivate func presentSelectionOnDayView(_ dayView: CVCalendarDayView) {
        self.animator?.animateSelection(dayView, withControlCoordinator: CVCalendarDayViewControlCoordinator.sharedControlCoordinator)
    }
    
    fileprivate func presentDeselectionOnDayView(_ dayView: CVCalendarDayView) {
        self.animator?.animateDeselection(dayView, withControlCoordinator: CVCalendarDayViewControlCoordinator.sharedControlCoordinator)
    }
    
    func animationStarted() {
        self.inOrderNumber += 1
    }
    
    func animationEnded() {
        self.inOrderNumber -= 1
    }
}
