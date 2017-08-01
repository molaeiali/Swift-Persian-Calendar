//
//  CVCircleView.swift
//  CVCalendar
//

import UIKit

class CVCircleView: UIView {
    
    fileprivate var color: UIColor?
    
    init(frame: CGRect, color: UIColor, _alpha: CGFloat) {
        super.init(frame: frame)
        
        self.color = color
        self.alpha = _alpha
        
        self.backgroundColor = .clear
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(0.5)
        
        let radius = (frame.width > frame.height) ? frame.height : frame.width
        
        let center = CGPoint(x:(round(frame.size.width))/2, y:round(frame.size.height)/2)
        
        context?.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        
//        CGContextAddArc(context, (frame.size.width)/2, frame.size.height/2, (radius - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
        
        // Draw
        context?.setFillColor(self.color!.cgColor)
        context?.setStrokeColor(self.color!.cgColor)
        context?.drawPath(using: .stroke)
    }
}
