//
//  CircularProgressBar.swift
//  pixelino
//
import Foundation
import UIKit

/// [Source](https://codeburst.io/circular-progress-bar-in-ios-d06629700334) for the
/// progress bar, slightly modified from original version.
class CircularProgressIndicator: UIView {

    let progressColor: UIColor = .black

    // MARK: - Public

    public var lineWidth: CGFloat = 50 {
        didSet {
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.20 * lineWidth)
        }
    }

    public func setProgress(to progressConstant: Double, withAnimation: Bool) {
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 } else if progressConstant < 0 { return 0 } else { return progressConstant }
            }
        }

        foregroundLayer.strokeEnd = CGFloat(progress)

        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = progress
            animation.duration = 2
            foregroundLayer.add(animation, forKey: "foregroundAnimation")

        }

        var currentTime: Double = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
            if currentTime >= 2 {
                timer.invalidate()
            } else {
                currentTime += 0.05
            }
        }
        timer.fire()

    }

    // MARK: - Private
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var radius: CGFloat {
        get {
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 } else { return (self.frame.height - lineWidth)/2 }
        }
    }

    private var pathCenter: CGPoint { get { return self.convert(self.center, from: self.superview) } }
    private func makeBar() {
        self.layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }

    private func drawBackgroundLayer() {
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        self.backgroundLayer.lineWidth = lineWidth - (lineWidth * 20/100)
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(backgroundLayer)

    }

    private func drawForegroundLayer() {

        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle

        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        foregroundLayer.lineCap = kCALineCapRound
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = progressColor.cgColor
        foregroundLayer.strokeEnd = 0

        self.layer.addSublayer(foregroundLayer)

    }

    private func setupView() {
        makeBar()
    }

    // Layout Sublayers
    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            setupView()
            layoutDone = true
        }
    }

}
