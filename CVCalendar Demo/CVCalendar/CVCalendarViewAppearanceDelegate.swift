//
//  CVCalendarViewAppearanceDelegate.swift
//  CVCalendar
//

import UIKit

@objc
protocol CVCalendarViewAppearanceDelegate {
    @objc optional func spaceBetweenWeekViews() -> CGFloat
    @objc optional func spaceBetweenDayViews() -> CGFloat
    
    @objc optional func dayLabelWeekdayTextSize() -> CGFloat
    @objc optional func dayLabelWeekdayHighlightedTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdayTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdayHighlightedTextSize() -> CGFloat
    @objc optional func dayLabelPresentWeekdayInitallyBold() -> Bool
    
    @objc optional func dayLabelWeekdayInTextColor() -> UIColor
    @objc optional func dayLabelWeekdayOutTextColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayTextColor() -> UIColor
    @objc optional func dayLabelWeekdayHighlightedTextColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayHighlightedTextColor() -> UIColor
    
    @objc optional func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor
    @objc optional func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat
    @objc optional func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor
    @objc optional func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat
    
    // new
    @objc optional func dotMarkerColor() -> UIColor
    @objc optional func dotMarkerOffset() -> CGFloat
    
}
