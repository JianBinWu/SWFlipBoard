//
//  SWFlipLayer.swift
//  FlipBoard
//
//  Created by Apple on 2022/11/10.
//

import UIKit

private let halfPi = Double.pi / 2
private let transformM34 = {
    var transform = CATransform3DIdentity
    //Setting the deformed m34 can increase the three-dimensional sense
    transform.m34 = -1 / 2000
    return transform
}()

enum SWFlipImagePosition {
    case none
    case below
    case top
    case bottom
}

class SWFlipLayer: UIView {
    private var flipDirection: SWFlipDirection!
    
    private var imageTopView:FlipImageView!
    private var imageBottomView:FlipImageView!
    private var nextImageTopView:FlipImageView!
    private var nextImageBottomView:FlipImageView!
    
    private var currentImage: UIImage!
    private var nextImage: UIImage!
    
    var flipSuccess: ((_: Bool)->())!

    convenience init(flipDirection: SWFlipDirection, frame:CGRect, currentImage: UIImage, nextImage: UIImage){
        self.init()
        self.frame = frame
        self.currentImage = currentImage
        self.nextImage = nextImage
        self.flipDirection = flipDirection
        setupImageViewLayer()
    }
    
    private func setupImageViewLayer(){
        //Add images based on flip direction
        if flipDirection == .up {
            nextImageBottomView = FlipImageView(image: nextImage, frame: bounds, type: .bottom)
            addSubview(nextImageBottomView)
            imageTopView = FlipImageView(image: currentImage, frame: bounds, type: .bottom)
            addSubview(imageTopView)
            imageBottomView = FlipImageView(image: currentImage, frame: bounds, type: .bottom)
            addSubview(imageBottomView)
            nextImageTopView = FlipImageView(image: nextImage, frame: bounds, type: .top)
            addSubview(nextImageTopView)
            nextImageTopView.isHidden = true
        } else {
            nextImageTopView = FlipImageView(image: nextImage, frame: bounds, type: .bottom)
            addSubview(nextImageTopView)
            imageBottomView = FlipImageView(image: currentImage, frame: bounds, type: .bottom)
            addSubview(imageBottomView)
            imageTopView = FlipImageView(image: currentImage, frame: bounds, type: .top)
            addSubview(imageTopView)
            nextImageBottomView = FlipImageView(image: nextImage, frame: bounds, type: .bottom)
            addSubview(nextImageBottomView)
            nextImageBottomView.isHidden = true
        }
        
        //Set the image position and anchor point
        imageTopView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5)
        imageBottomView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5)
        nextImageTopView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5)
        nextImageBottomView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5)
        
        imageTopView.layer.anchorPoint = CGPointMake(0.5, 1)
        imageBottomView.layer.anchorPoint = CGPointMake(0.5, 0)
        nextImageTopView.layer.anchorPoint = CGPointMake(0.5, 1)
        nextImageBottomView.layer.anchorPoint = CGPointMake(0.5, 0)
        
        imageTopView.layer.position = CGPointMake(imageTopView.center.x, imageTopView.center.y + imageTopView.frame.height * 0.5)
        nextImageTopView.layer.position = CGPointMake(nextImageTopView.center.x, nextImageTopView.center.y + nextImageTopView.frame.height * 0.5)

        imageTopView.frame = .init(origin: imageTopView.frame.origin, size: .init(width: imageTopView.frame.width, height: frame.height * 0.5))
        imageBottomView.frame = .init(origin: imageBottomView.frame.origin, size: .init(width: imageBottomView.frame.width, height: frame.height * 0.5))
        nextImageTopView.frame = .init(origin: nextImageTopView.frame.origin, size: .init(width: nextImageTopView.frame.width, height: frame.height * 0.5))
        nextImageBottomView.frame = .init(origin: nextImageBottomView.frame.origin, size: .init(width: nextImageBottomView.frame.width, height: frame.height * 0.5))
    }
    
    func flip(_ pan:UIPanGestureRecognizer){
        var angle = -pan.translation(in: pan.view).y / (bounds.size.height * 0.6) * Double.pi
        if flipDirection == .up && angle < 0 || flipDirection == .down && angle > 0 {
            angle = 0
        }
        let absAngle = abs(angle) >= Double.pi ? Double.pi : abs(angle)
        let flipProcess = absAngle < halfPi ? absAngle / halfPi : (absAngle - halfPi) / halfPi
        //Set the image flip angle and shadow
        if flipDirection == .up {
            imageBottomView.isHidden = absAngle >= halfPi
            nextImageTopView.isHidden = absAngle < halfPi
            if absAngle < halfPi {
                imageBottomView.layer.transform = CATransform3DRotate(transformM34, absAngle, 1, 0, 0)
                imageBottomView.shadowLayer.opacity = Float(flipProcess * 0.5)
                nextImageBottomView.shadowLayer.opacity = 1 - Float(flipProcess * 1)
                imageTopView.shadowLayer.opacity = 0
                nextImageTopView.shadowLayer.opacity = 0
            } else {
                nextImageTopView.layer.transform = CATransform3DRotate(transformM34, absAngle - Double.pi, 1, 0, 0)
                nextImageTopView.shadowLayer.opacity = 0.5 - Float(flipProcess * 0.5)
                imageTopView.shadowLayer.opacity = Float(flipProcess * 1)
                imageBottomView.shadowLayer.opacity = 0
                nextImageBottomView.shadowLayer.opacity = 0
            }
        } else {
            imageTopView.isHidden = absAngle >= halfPi
            nextImageBottomView.isHidden = absAngle < halfPi
            if absAngle < halfPi {
                imageTopView.layer.transform = CATransform3DRotate(transformM34, -absAngle, 1, 0, 0)
                imageTopView.shadowLayer.opacity = Float(flipProcess * 0.5)
                nextImageTopView.shadowLayer.opacity = 1 - Float(flipProcess * 1)
                imageBottomView.shadowLayer.opacity = 0
                nextImageBottomView.shadowLayer.opacity = 0
            } else {
                nextImageBottomView.layer.transform = CATransform3DRotate(transformM34, Double.pi - absAngle, 1, 0, 0)
                nextImageBottomView.shadowLayer.opacity = 0.5 - Float(flipProcess * 0.5)
                imageBottomView.shadowLayer.opacity = Float(flipProcess * 1)
                imageTopView.shadowLayer.opacity = 0
                nextImageTopView.shadowLayer.opacity = 0
            }
        }
        if pan.state == UIGestureRecognizer.State.ended {
            nextImageBottomView.shadowLayer.opacity = 0
            imageBottomView.shadowLayer.opacity = 0
            imageTopView.shadowLayer.opacity = 0
            nextImageTopView.shadowLayer.opacity = 0
            //If the sliding speed is fast, flip to next page
            if abs(pan.velocity(in: pan.view).y) > 500, absAngle < halfPi {
                if flipDirection == .up {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                        self.imageBottomView.layer.transform = CATransform3DRotate(transformM34, halfPi, 1, 0, 0)
                    }, completion: { _ in
                        self.imageBottomView.isHidden = true
                        self.nextImageTopView.isHidden = false
                        self.nextImageTopView.layer.transform = CATransform3DRotate(transformM34, -halfPi, 1, 0, 0)
                        self.endFlipAnimation(duration: 0.1, from: halfPi)
                    })
                } else {
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                        self.imageTopView.layer.transform = CATransform3DRotate(transformM34, -halfPi, 1, 0, 0)
                    }, completion: { _ in
                        self.imageTopView.isHidden = true
                        self.nextImageBottomView.isHidden = false
                        self.nextImageBottomView.layer.transform = CATransform3DRotate(transformM34, halfPi, 1, 0, 0)
                        self.endFlipAnimation(duration: 0.1, from: halfPi)
                    })
                }
            } else {
                endFlipAnimation(duration: 0.3, from: absAngle)
            }
        }
    }
    
    private func endFlipAnimation(duration: CGFloat, from absAngle: CGFloat) {
        isUserInteractionEnabled = false
        flipSuccess(absAngle >= halfPi)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            if self.flipDirection == .up {
                if absAngle >= halfPi {
                    self.nextImageTopView.layer.transform = CATransform3DIdentity
                } else {
                    self.imageBottomView.layer.transform = CATransform3DIdentity
                }
            } else {
                if absAngle >= halfPi {
                    self.nextImageBottomView.layer.transform = CATransform3DIdentity
                } else {
                    self.imageTopView.layer.transform = CATransform3DIdentity
                }
            }
        }, completion: { (Bool) -> Void in
            self.removeFromSuperview()
        })
    }
}

class SWFlipToTopLayer: UIView {
    private var imageTopViews = [FlipImageView]()
    private var imageBottomViews = [FlipImageView]()
    var images: [UIImage]!
    
    var complete: (()->())!

    convenience init(frame: CGRect, images: [UIImage]){
        self.init()
        self.frame = frame
        self.images = images
        setupImageViewLayer()
    }
    
    private func setupImageViewLayer(){
        for (i, image) in images.reversed().enumerated() {
            let topView = FlipImageView(image: image, frame: bounds, type: .none)
            imageTopViews.append(topView)
            insertSubview(topView, at: 0)
            let bottomView = FlipImageView(image: image, frame: bounds, type: .none)
            imageBottomViews.append(bottomView)
            addSubview(bottomView)
            //Set the image position and anchor point
            topView.layer.contentsRect = CGRectMake(0, 0, 1, 0.5)
            bottomView.layer.contentsRect = CGRectMake(0, 0.5, 1, 0.5)
            topView.layer.anchorPoint = CGPointMake(0.5, 1)
            bottomView.layer.anchorPoint = CGPointMake(0.5, 0)
            topView.layer.position = CGPointMake(topView.center.x, topView.center.y + topView.frame.height * 0.5)
            topView.frame = .init(origin: topView.frame.origin, size: .init(width: topView.frame.width, height: frame.height * 0.5))
            bottomView.frame = .init(origin: bottomView.frame.origin, size: .init(width: bottomView.frame.width, height: frame.height * 0.5))
            if i != 0 {
                bottomView.layer.transform = CATransform3DRotate(transformM34, halfPi, 1, 0, 0)
            }
        }
    }
    
    func flipToTop() {
        let loopCount = images.count - 1
        for i in 0..<loopCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i)) {
                let topView = self.imageTopViews[i]
                let bottomView = self.imageBottomViews[i + 1]
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    topView.layer.transform = CATransform3DRotate(transformM34, -halfPi, 1, 0, 0)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: { () -> Void in
                        bottomView.layer.transform = CATransform3DIdentity
                    }) { _ in
                        if i == loopCount - 1 {
                            self.complete()
                            self.removeFromSuperview()
                        }
                    }
                })
            }
        }
    }
}

private class FlipImageView: UIImageView {
    var shadowLayer = CAGradientLayer()
    
    override var frame: CGRect {
        didSet {
            shadowLayer.frame = bounds
        }
    }
    
    init(image: UIImage?, frame: CGRect, type: SWFlipImagePosition) {
        super.init(image: image)
        self.frame = frame
        switch type {
        case .below:
            shadowLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor]
        case .bottom:
            shadowLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        case .top:
            shadowLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        default:
            break
        }
        layer.addSublayer(shadowLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
