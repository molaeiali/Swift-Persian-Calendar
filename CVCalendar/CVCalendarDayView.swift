//
//  CVCalendarDayView.swift
//  CVCalendar
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


class CVCalendarDayView: UIView {
    
    // MARK: - Public properties

    var weekView: CVCalendarWeekView?
    var weekdayIndex: Int?
    var date: CVDate?
    
    var dayLabel: UILabel?
    var circleView: CVCircleView?
    var topMarker: CALayer?
    var dotMarker: CVCircleView?
    
    var isOut = false
    var isCurrentDay = false
    
    // MARK: - Initialization
    
    init(weekView: CVCalendarWeekView, frame: CGRect, weekdayIndex: Int) {
        super.init(frame: frame)
        
        self.weekView = weekView
        self.frame = frame
        self.weekdayIndex = weekdayIndex
        
        func hasDayAtWeekdayIndex(_ weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            let keys = weekdaysDictionary.keys
            
            for key in keys {
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        
        var day: Int?
        
        let weekdaysIn = self.weekView!.weekdaysIn!
        if let weekdaysOut = self.weekView?.weekdaysOut {
            if hasDayAtWeekdayIndex(self.weekdayIndex!, weekdaysDictionary: weekdaysOut) {
                self.isOut = true
                day = weekdaysOut[self.weekdayIndex!]![0]
            } else if hasDayAtWeekdayIndex(self.weekdayIndex!, weekdaysDictionary: weekdaysIn) {
                day = weekdaysIn[self.weekdayIndex!]![0]
            }
        } else {
            day = weekdaysIn[self.weekdayIndex!]![0]
        }
        
        if day == self.weekView!.monthView!.currentDay && !self.isOut {
            let manager = CVCalendarManager.sharedManager
            let dateRange = manager.dateRange(self.weekView!.monthView!.date!)
            let currentDateRange = manager.dateRange(Date())
            if dateRange.month == currentDateRange.month && dateRange.year == currentDateRange.year {
                self.isCurrentDay = true
            }
            
        }
        

        
        var shouldShowDaysOut = self.weekView!.monthView!.calendarView!.shouldShowWeekdaysOut!
        
        let calendarManager = CVCalendarManager.sharedManager
        let year = calendarManager.dateRange(self.weekView!.monthView!.date!).year
        var month: Int? = calendarManager.dateRange(self.weekView!.monthView!.date!).month
        if self.isOut {
            if day > 20 {
                month! -= 1
            } else {
                month! += 1
            }
            
            if !shouldShowDaysOut {
                self.isHidden = true
            }
        }
        
        self.date = CVDate(day: day!, month: month!, week: self.weekView!.index!, year: year)
        
        self.labelSetup()
        self.topMarkerSetup()
        self.setupGestures()
        self.setupDotMarker()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties setup
    
    func labelSetup() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        self.dayLabel = UILabel()
        self.dayLabel!.text = String(self.date!.day!)
        self.dayLabel!.textAlignment = NSTextAlignment.center
        self.dayLabel!.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        var font: UIFont? = UIFont.systemFont(ofSize: appearance.dayLabelWeekdayTextSize!)
        var color: UIColor?
        if self.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if self.isCurrentDay {
            let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
            if coordinator.selectedDayView == nil {
                self.weekView!.monthView!.receiveDayViewTouch(self)
            } else {
                color = appearance.dayLabelPresentWeekdayTextColor
                font = UIFont.boldSystemFont(ofSize: appearance.dayLabelPresentWeekdayTextSize!)
            }
            
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        
        if color != nil && font != nil {
            self.dayLabel!.textColor = color!
            self.dayLabel!.font = font
        }
        
        self.addSubview(self.dayLabel!)
    }
    
    
    func topMarkerSetup() {
        func createMarker() {
            let height = CGFloat(0.5)
            let layer = CALayer()
            layer.borderColor = UIColor.gray.cgColor
            layer.borderWidth = height
            layer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: height)
            
            self.topMarker = layer
            
            self.layer.addSublayer(self.topMarker!)
        }
        
        if let delegate = self.weekView!.monthView!.calendarView!.delegate {
            if delegate.topMarker(shouldDisplayOnDayView: self) {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                createMarker()
            } else {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
            }
        } else {
            if self.topMarker == nil {
                createMarker()
            } else {
                self.topMarker?.removeFromSuperlayer()
                self.topMarker = nil
                createMarker()
            }
        }
    }
    
    func setupDotMarker() {
        if let delegate = self.weekView!.monthView!.calendarView!.delegate {
            if delegate.dotMarker(shouldShowOnDayView: self) {
                var color = delegate.dotMarker(colorOnDayView: self)
                let width: CGFloat = 13
                let height = width
                
                let x = self.frame.width / 2
                var yOffset: CGFloat? = 5
                if let appearance = self.weekView!.monthView!.calendarView!.appearanceDelegate {
                    yOffset = appearance.dotMarkerOffset
                }
                let y = self.frame.maxY - self.frame.height / yOffset!
                
                let frame = CGRect(x: 0, y: 0, width: width, height: height)
                
                if self.isOut {
                    color = UIColor.gray
                }
                
                self.dotMarker = CVCircleView(frame: frame, color: color, _alpha: 1)
                self.dotMarker?.center = CGPoint(x: x, y: y)
                
                self.insertSubview(self.dotMarker!, at: 0)
                
                let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
                if self == coordinator.selectedDayView {
                    self.moveDotMarker(false)
                }
            }
        }
    }
    
    // MARK: - Events handling
    
    func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CVCalendarDayView.dayViewTapped))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    func dayViewTapped() {
        let monthView = self.weekView!.monthView!
        monthView.receiveDayViewTouch(self)
    }
    
    // MARK: - Label states management
    
    func moveDotMarker(_ unwinded: Bool) {
        if self.dotMarker != nil {
            var shouldMove = true
            if let delegate = self.weekView!.monthView!.calendarView!.delegate {
                shouldMove = delegate.dotMarker(shouldMoveOnHighlightingOnDayView: self)
            }
            if !unwinded && shouldMove {
                let radius = (self.circleView!.frame.size.width - 10)/2
                let center = CGPoint(x: (self.circleView!.frame.size.width)/2, y: self.circleView!.frame.size.height/2)
                let maxArcPointY = center.y + radius
                self.diff = maxArcPointY - self.dotMarker!.frame.origin.y/0.95
                
                if self.diff > 0 {
                    self.diff = abs(self.diff!)
                    
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                        self.dotMarker!.frame.origin.y += self.diff!
                        }, completion: nil)
                } else {
                    self.diff = nil
                }
            } else if self.diff != nil && shouldMove {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.dotMarker!.frame.origin.y -= self.diff!
                    }, completion: nil)
            } else {
                
                if let dotMarker = self.dotMarker {
                    if let delegate = self.weekView!.monthView!.calendarView!.delegate {
                        let frame = dotMarker.frame
                        var color: UIColor?
                        if unwinded {
                            let appearance = weekView!.monthView!.calendarView!.appearanceDelegate! // Note: if nil then look at recovery mechanism
                            color = (isOut) ? appearance.dayLabelWeekdayOutTextColor : delegate.dotMarker(colorOnDayView: self)
                        } else {
                            if let appearance = self.weekView!.monthView!.calendarView!.appearanceDelegate  {
                                color = appearance.dotMarkerColor!
                            }
                        }
                        
                        let auxiliaryCircleView = CVCircleView(frame: frame, color: color!, _alpha: dotMarker.alpha)
                        self.dotMarker?.removeFromSuperview()
                        self.dotMarker = auxiliaryCircleView
                        self.addSubview(self.dotMarker!)
                    }
                }
            }
        }
    }
    
    fileprivate var diff: CGFloat?
    func setDayLabelHighlighted() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var color: UIColor?
        var _alpha: CGFloat?
        
        if self.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayHighlightedBackgroundColor!
            _alpha = appearance.dayLabelPresentWeekdayHighlightedBackgroundAlpha!
            self.dayLabel?.textColor = appearance.dayLabelPresentWeekdayHighlightedTextColor!
            self.dayLabel?.font = UIFont.boldSystemFont(ofSize: appearance.dayLabelPresentWeekdayHighlightedTextSize!)
        } else {
            color = appearance.dayLabelWeekdayHighlightedBackgroundColor
            _alpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
            self.dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
            self.dayLabel?.font = UIFont.boldSystemFont(ofSize: appearance.dayLabelWeekdayHighlightedTextSize!)
        }
        
        self.circleView = CVCircleView(frame: CGRect(x: 0, y: 0, width: self.dayLabel!.frame.width, height: self.dayLabel!.frame.height), color: color!, _alpha: _alpha!)
        self.insertSubview(self.circleView!, at: 0)
        self.moveDotMarker(false)
    }
    
    func setDayLabelUnhighlighted() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var color: UIColor?
        if self.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if self.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        var font: UIFont?
        if self.isCurrentDay {
            if appearance.dayLabelPresentWeekdayInitallyBold {
                font = UIFont.boldSystemFont(ofSize: appearance.dayLabelPresentWeekdayTextSize!)
            } else {
                font = UIFont.systemFont(ofSize: appearance.dayLabelPresentWeekdayTextSize!)
            }
        } else {
            font = UIFont.systemFont(ofSize: appearance.dayLabelWeekdayTextSize!)
        }
        
        self.dayLabel?.textColor = color
        self.dayLabel?.font = font
        
        self.moveDotMarker(true)
        self.circleView?.removeFromSuperview()
        self.circleView = nil
    }
    
    // MARK: - View Destruction
    
    func destroy() {
        self.weekView = nil
        self.dayLabel?.removeFromSuperview()
        self.circleView?.removeFromSuperview()
        self.topMarker?.removeAllAnimations()
        self.dotMarker?.removeFromSuperview()
    }
    
    // MARK: - Content reload
    
    func reloadContent() {
        self.dotMarker?.removeFromSuperview()
        self.dotMarker = nil
        self.setupDotMarker()
        let shouldShowDaysOut = self.weekView!.monthView!.calendarView!.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if self.isOut {
                self.isHidden = true
            }
        } else {
            if self.isOut {
                self.isHidden = false
            }
        }
        
        self.dayLabel?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        self.topMarker?.frame.size.width = self.frame.width
        
        if self.circleView != nil {
            self.setDayLabelUnhighlighted()
            self.setDayLabelHighlighted()
        }
        
    }
    
}
