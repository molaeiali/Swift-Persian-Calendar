//
//  CVCalendarViewAppearance.swift
//  CVCalendar
//


import UIKit

private let sharedInstance = CVCalendarViewAppearance()

class CVCalendarViewAppearance: NSObject {
    
    class var sharedCalendarViewAppearance: CVCalendarViewAppearance {
        return sharedInstance
    }

    var spaceBetweenWeekViews: CGFloat? = 0
    var spaceBetweenDayViews: CGFloat? = 0
    
    var dayLabelWeekdayTextSize: CGFloat? = 18
    var dayLabelPresentWeekdayTextSize: CGFloat? = 18
    var dayLabelWeekdayHighlightedTextSize: CGFloat? = 20
    var dayLabelPresentWeekdayHighlightedTextSize: CGFloat? = 20
    
    var dayLabelPresentWeekdayInitallyBold: Bool = true
    
    var dayLabelWeekdayInTextColor: UIColor? = .black
    var dayLabelWeekdayOutTextColor: UIColor? = .gray
    var dayLabelWeekdayHighlightedBackgroundColor: UIColor? = .blue
    var dayLabelWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.6
    var dayLabelPresentWeekdayTextColor: UIColor? = .red
    var dayLabelPresentWeekdayHighlightedBackgroundColor: UIColor? = .red
    var dayLabelPresentWeekdayHighlightedBackgroundAlpha: CGFloat? = 0.6
    
    var dayLabelWeekdayHighlightedTextColor: UIColor? = .white
    var dayLabelPresentWeekdayHighlightedTextColor: UIColor? = .white
    
    var dotMarkerColor: UIColor? = .white
    var dotMarkerOffset: CGFloat? = 3.5
    
    var delegate: CVCalendarViewAppearanceDelegate? {
        didSet {
            self.setupAppearance()
        }
    }
    
    func setupAppearance() {
        if let spaceBetweenWeekViews = self.delegate!.spaceBetweenWeekViews?() {
            self.spaceBetweenWeekViews = spaceBetweenWeekViews
        }
        
        if let spaceBetweenDayViews = self.delegate!.spaceBetweenDayViews?() {
            self.spaceBetweenDayViews = spaceBetweenDayViews
        }
        
        if let dayLabelWeekdayTextSize = self.delegate!.dayLabelWeekdayTextSize?() {
            self.dayLabelWeekdayTextSize = dayLabelWeekdayTextSize
        }
        
        if let dayLabelPresentWeekdayTextSize = self.delegate!.dayLabelPresentWeekdayTextSize?() {
            self.dayLabelPresentWeekdayTextSize = dayLabelPresentWeekdayTextSize
        }
        
        if let dayLabelWeekdayHighlightedTextSize = self.delegate!.dayLabelWeekdayHighlightedTextSize?() {
            self.dayLabelWeekdayHighlightedTextSize = dayLabelWeekdayHighlightedTextSize
        }
        
        if let dayLabelPresentWeekdayHighlightedTextSize = self.delegate!.dayLabelPresentWeekdayHighlightedTextSize?() {
            self.dayLabelPresentWeekdayHighlightedTextSize = dayLabelPresentWeekdayHighlightedTextSize
        }
        
        if let dayLabelPresentWeekdayInitallyBold = self.delegate!.dayLabelPresentWeekdayInitallyBold?() {
            self.dayLabelPresentWeekdayInitallyBold = dayLabelPresentWeekdayInitallyBold
        }
        
        if let dayLabelWeekdayTextSize = self.delegate!.dayLabelWeekdayTextSize?() {
            self.dayLabelWeekdayTextSize = dayLabelWeekdayTextSize
        }
        
        if let dayLabelWeekdayInTextColor = self.delegate!.dayLabelWeekdayInTextColor?() {
            self.dayLabelWeekdayInTextColor = dayLabelWeekdayInTextColor
        }
        
        if let dayLabelWeekdayOutTextColor = self.delegate!.dayLabelWeekdayOutTextColor?() {
            self.dayLabelWeekdayOutTextColor = dayLabelWeekdayOutTextColor
        }
        
        if let dayLabelWeekdayHighlightedBackgroundColor = self.delegate!.dayLabelWeekdayHighlightedBackgroundColor?() {
            self.dayLabelWeekdayHighlightedBackgroundColor = dayLabelWeekdayHighlightedBackgroundColor
        }
        
        if let dayLabelWeekdayHighlightedBackgroundAlpha = self.delegate!.dayLabelWeekdayHighlightedBackgroundAlpha?() {
            self.dayLabelWeekdayHighlightedBackgroundAlpha = dayLabelWeekdayHighlightedBackgroundAlpha
        }
        
        if let dayLabelPresentWeekdayTextColor = self.delegate!.dayLabelPresentWeekdayTextColor?() {
            self.dayLabelPresentWeekdayTextColor = dayLabelPresentWeekdayTextColor
        }
        
        if let dayLabelPresentWeekdayHighlightedBackgroundColor = self.delegate!.dayLabelPresentWeekdayHighlightedBackgroundColor?() {
            self.dayLabelPresentWeekdayHighlightedBackgroundColor = dayLabelPresentWeekdayHighlightedBackgroundColor
        }
        
        if let dayLabelPresentWeekdayHighlightedBackgroundAlpha = self.delegate!.dayLabelPresentWeekdayHighlightedBackgroundAlpha?() {
            self.dayLabelPresentWeekdayHighlightedBackgroundAlpha = dayLabelPresentWeekdayHighlightedBackgroundAlpha
        }
        
        if let dayLabelWeekdayHighlightedTextColor = self.delegate!.dayLabelWeekdayHighlightedTextColor?() {
            self.dayLabelWeekdayHighlightedTextColor = dayLabelWeekdayHighlightedTextColor
        }
        
        if let dayLabelPresentWeekdayHighlightedTextColor = self.delegate!.dayLabelPresentWeekdayHighlightedTextColor?() {
            self.dayLabelPresentWeekdayHighlightedTextColor = dayLabelPresentWeekdayHighlightedTextColor
        }
        
        if let dotMarkerColor = self.delegate!.dotMarkerColor?() {
            self.dotMarkerColor = dotMarkerColor
        }
        
        if let dotMarkerOffset = self.delegate!.dotMarkerOffset?() {
            self.dotMarkerOffset = dotMarkerOffset
        }
    }
    
    fileprivate override init() {
        super.init()
    }
}
