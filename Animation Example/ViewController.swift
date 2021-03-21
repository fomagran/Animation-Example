//
//  ViewController.swift
//  Animation Example
//
//  Created by Fomagran on 2021/03/21.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK:Vars
    
    private let maxWaveHeight : CGFloat = 100.0
    private let minimalHeight: CGFloat = 50.0
    private let shapeLayer = CAShapeLayer()
    private var displayLink: CADisplayLink!
    
    private var animating = false {
      didSet {
        view.isUserInteractionEnabled = !animating
        displayLink.isPaused = !animating
      }
    }
    
    private let leftFirstView = UIView ()
    private let leftSecondView = UIView ()
    private let leftThirdView = UIView ()
    private let centerView = UIView ()
    private let rightFirstView = UIView ()
    private let rightSecondView = UIView ()
    private let rightThirdView = UIView ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftFirstView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        leftSecondView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        leftThirdView.frame = CGRect ( x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        centerView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        rightFirstView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        rightSecondView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)
        rightThirdView.frame = CGRect (x : 0.0, y : 0.0, width : 3.0, height : 3.0)

        leftFirstView.backgroundColor = .red
        leftSecondView.backgroundColor = .orange
        leftThirdView.backgroundColor = .yellow
        centerView.backgroundColor = .green
        rightFirstView.backgroundColor = .blue
        rightSecondView.backgroundColor = .systemIndigo
        rightThirdView.backgroundColor = .purple

        view.addSubview (leftFirstView)
        view.addSubview (leftSecondView)
        view.addSubview (leftThirdView)
        view.addSubview (centerView)
        view.addSubview (rightFirstView)
        view.addSubview (rightSecondView)
        view.addSubview (rightThirdView)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateShapeLayer))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.isPaused = true
        
    }
    
    
    
    override func loadView() {
        super.loadView()
        
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: minimalHeight)
        shapeLayer.fillColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0).cgColor
        view.layer.addSublayer(shapeLayer)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureDidMove)))
        
        layoutControlPoints(baseHeight: minimalHeight, waveHeight: 0.0, locationX: view.bounds.width / 2.0)
        updateShapeLayer()


        
    }
    
    // MARK: Methods
    
    @objc func panGestureDidMove(gesture: UIPanGestureRecognizer) {
        let additionalHeight = max(gesture.translation(in: view).y, 0)
        let waveHeight = min(additionalHeight * 0.6, maxWaveHeight)
        let baseHeight = minimalHeight + additionalHeight - waveHeight
        let locationX = gesture.location(in: gesture.view).x
        let centerY = minimalHeight
        if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            animating = true
            UIView.animate(withDuration: 0.9,delay: 0.0,usingSpringWithDamping: 0.57, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                self.leftFirstView .center.y = centerY
                self.leftSecondView.center.y = centerY
                self.leftThirdView.center.y = centerY
                self.centerView.center.y = centerY
                self.rightFirstView.center.y = centerY
                self.rightSecondView.center.y = centerY
                self.rightThirdView.center.y = centerY
            }, completion: { _ in
                self.animating = false
            })
        } else {
            
            layoutControlPoints(baseHeight: baseHeight, waveHeight: waveHeight, locationX: locationX)
            
            updateShapeLayer()
        }
        
    }
    
    private func currentPath ()-> CGPath {
      let width = view.bounds.width
      let bezierPath = UIBezierPath ()
        
        //시작
        bezierPath.move (to: CGPoint (x : 0.0, y : 0.0))
        
        //시작부분을 선으로 연결
        bezierPath.addLine (to: CGPoint (x : 0.0, y : leftFirstView.dg_center(usePresentationLayerIfPossible: animating).y))
        
        //왼쪽의 3개 뷰 곡선으로 연결
        bezierPath.addCurve (to: leftThirdView.dg_center(usePresentationLayerIfPossible: animating), controlPoint1 : leftFirstView.dg_center(usePresentationLayerIfPossible: animating), controlPoint2 : leftSecondView.dg_center(usePresentationLayerIfPossible: animating))
        
        //오른쪽 첫번째와 가운데 오른쪽 첫번째를 곡선으로 연결(?)
        bezierPath.addCurve (to: rightFirstView.dg_center(usePresentationLayerIfPossible: animating), controlPoint1 : centerView.dg_center(usePresentationLayerIfPossible: animating), controlPoint2 : rightFirstView.dg_center(usePresentationLayerIfPossible: animating))
        
        //오른쪽 3개 뷰 곡선으로 연결
        bezierPath.addCurve (to: rightThirdView.dg_center(usePresentationLayerIfPossible: animating), controlPoint1 : rightFirstView.dg_center(usePresentationLayerIfPossible: animating), controlPoint2 : rightSecondView.dg_center(usePresentationLayerIfPossible: animating))
        
        //끝 지점을 선으로 연결
        bezierPath.addLine (to: CGPoint (x : width, y : 0.0))
        
        //끝
        bezierPath.close ()

        return bezierPath.cgPath
    }
    
    @objc func updateShapeLayer () {
        shapeLayer.path = currentPath()
    }
    
    private func layoutControlPoints(baseHeight: CGFloat, waveHeight: CGFloat, locationX: CGFloat) {
      let width = view.bounds.width
      let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
      let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)

      let leftPartWidth = locationX - minLeftX
      let rightPartWidth = maxRightX - locationX

      leftFirstView.center = CGPoint(x: minLeftX, y: baseHeight)
      leftSecondView.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
      leftThirdView.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
      centerView.center = CGPoint(x: locationX , y: baseHeight + waveHeight * 1.36)
      rightFirstView.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + waveHeight * 0.64)
      rightSecondView.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
      rightThirdView.center = CGPoint(x: maxRightX, y: baseHeight)
    }
}

extension UIView {
    func dg_center(usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentation(){
            return presentationLayer.position
        }
        return center
    }
}
