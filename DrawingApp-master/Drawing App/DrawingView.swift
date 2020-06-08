//
//  DrawingView.swift
//  Drawing App
//
//  Created by Ozan Mirza on 3/5/19.
//  Copyright © 2019 Ozan Mirza. All rights reserved.
//

import UIKit

public class SmoothCurvedLinesView: UIView {
    
    public var strokeColor = UIColor.white
    public var lineWidth: CGFloat = 10
    public var snapshotImage: UIImage?
    public var isEnabled: Bool = true
    
    private var path: UIBezierPath?
    private var temporaryPath: UIBezierPath?
    private var points = [CGPoint]()
    
    public override func draw(_ rect: CGRect) {
        snapshotImage?.draw(in: rect)
        
        strokeColor.setStroke()
        
        path?.stroke()
        temporaryPath?.stroke()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            if let touch = touches.first {
                points = [touch.location(in: self)]
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            guard let touch = touches.first else { return }
            let point = touch.location(in: self)
            
            points.append(point)
            
            updatePaths()
            
            setNeedsDisplay()
        }
    }
    
    private func updatePaths() {
        // update main path
        
        while points.count > 4 {
            points[3] = CGPoint(x: (points[2].x + points[4].x)/2.0, y: (points[2].y + points[4].y)/2.0)
            
            if path == nil {
                path = createPathStarting(at: points[0])
            }
            
            path?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            
            points.removeFirst(3)
            
            temporaryPath = nil
        }
        
        // build temporary path up to last touch point
        
        if points.count == 2 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addLine(to: points[1])
        } else if points.count == 3 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addQuadCurve(to: points[2], controlPoint: points[1])
        } else if points.count == 4 {
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            finishPath()
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if isEnabled {
            finishPath()
        }
    }
    
    private func finishPath() {
        constructIncrementalImage()
        path = nil
        setNeedsDisplay()
    }
    
    private func createPathStarting(at point: CGPoint) -> UIBezierPath {
        let localPath = UIBezierPath()
        
        localPath.move(to: point)
        
        localPath.lineWidth = lineWidth
        localPath.lineCapStyle = .round
        localPath.lineJoinStyle = .round
        
        return localPath
    }
    
    private func constructIncrementalImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        strokeColor.setStroke()
        snapshotImage?.draw(at: .zero)
        path?.stroke()
        temporaryPath?.stroke()
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    public func restartDrawingView() {
        snapshotImage = nil
        points = []
        setNeedsDisplay()
    }
    
    public func close() {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = self.layer.borderWidth
        animation.toValue = self.frame.size.width
        animation.duration = 1.5
        self.layer.add(animation, forKey: "borderWidth")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.backgroundColor = UIColor.white
        }
    }
    
    public func open() {
        let background = UIView(frame: self.bounds)
        background.backgroundColor = UIColor.black
        background.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.addSubview(background)
        UIView.animate(withDuration: 0.5, animations: {
            background.transform = CGAffineTransform.identity
        }) { (finished: Bool) in
            self.backgroundColor = UIColor.clear
            self.subviews.forEach { view in view.removeFromSuperview() }
        }
    }
}
