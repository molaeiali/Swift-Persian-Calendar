//
//  CVCalendarViewAnimator.swift
//  CVCalendar
//


import UIKit

class CVCalendarViewAnimator: NSObject, CVCalendarViewAnimatorDelegate {
    
    override init() {
        super.init()
    }
    
    func animateSelectionWithBounceEffect(_ dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        dayView.setDayLabelHighlighted()
        
        dayView.dayLabel?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        dayView.circleView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            coordinator.animationStarted()
            
            dayView.circleView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            dayView.dayLabel?.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            }) { (Bool) -> Void in
                coordinator.animationEnded()
        }
    }
    
    func animateDeselectionWithRollingEffect(_ dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            coordinator.animationStarted()
            dayView.circleView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            dayView.circleView?.alpha = 0.0
            
            }) { (Bool) -> Void in
                dayView.setDayLabelUnhighlighted()
                coordinator.animationEnded()
        }
    }
    
    func animateDeselectionWithBubbleEffect(_ dayView: CVCalendarDayView, withControlCooordinator coordinator: CVCalendarDayViewControlCoordinator) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
            coordinator.animationStarted()
            
            dayView.circleView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            }) { (Bool) -> Void in
                UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    
                    dayView.circleView!.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                    }) { (Bool) -> Void in
                        dayView.setDayLabelUnhighlighted()
                        coordinator.animationEnded()
                }
        }
    }
    
    // MARK: - Animator Delegate
    
    func animateSelection(_ dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator) {
        self.animateSelectionWithBounceEffect(dayView, withControlCooordinator: coordinator)
    }
    
    func animateDeselection(_ dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator) {
        self.animateDeselectionWithRollingEffect(dayView, withControlCooordinator: coordinator)
    }
}
