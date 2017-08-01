//
//  CVCalendarViewAnimatorDelegate.swift
//  CVCalendar
//


import UIKit

@objc
protocol CVCalendarViewAnimatorDelegate {
    func animateSelection(_ dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator)
    func animateDeselection(_ dayView: CVCalendarDayView, withControlCoordinator coordinator: CVCalendarDayViewControlCoordinator)
}
