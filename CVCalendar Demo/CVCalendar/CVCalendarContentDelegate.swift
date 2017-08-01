//
//  CVCalendarContentDelegate.swift
//  CVCalendar Demo
//


import UIKit

protocol CVCalendarContentDelegate {
    func updateFrames()
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    func performedDayViewSelection(_ dayView: CVCalendarDayView)
    
    func presentNextView(_ dayView: CVCalendarDayView?)
    func presentPreviousView(_ dayView: CVCalendarDayView?)
    
    func updateDayViews(_ hidden: Bool)
    
    func togglePresentedDate(_ date: Date)
}
