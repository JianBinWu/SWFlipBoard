//
//  FlipBoard.swift
//  FlipBoard
//
//  Created by Apple on 2022/11/3.
//

import UIKit
import SnapKit

let keyWindow: UIWindow = {
    var window: UIWindow!
    if #available(iOS 13.0, *) {
        window = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .last?.windows
            .filter({ $0.isKeyWindow })
            .last!
    } else{
        window = UIApplication.shared.keyWindow
    }
    return window
}()

enum SWFlipDirection {
    case up
    case down
}

@objc public protocol SWFlipBoardDelegate {
    func flipBoardRefresh(_ flipBoard: SWFlipBoard)
    func flipBoard(_ flipBoard: SWFlipBoard, pageAt index: Int) -> UIView
}

public class SWFlipBoard: UIView, UIGestureRecognizerDelegate {
    private var flipImages = [UIImage]()
    private var refreshView: SWRefresh?
    private var flipLayer: SWFlipLayer?
    private var flipToTopLayer: SWFlipToTopLayer?
    private(set) var currentPage: UIView!
    public private(set) var pageIndex = 0
    public var delegate: SWFlipBoardDelegate!

    public convenience init(currentPage: UIView) {
        self.init(frame: .zero)
        self.currentPage = currentPage
        addSubview(currentPage)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(flip(pan:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }

    @objc private func flip(pan: UIPanGestureRecognizer) {
        let offSet = pan.velocity(in: pan.view)
        //if pull down the first page, refresh
        if offSet.y > 0 && pageIndex == 0 && pan.state == .began {
            refreshView = SWRefresh()
            insertSubview(refreshView!, belowSubview: currentPage)
            refreshView!.snp.makeConstraints { make in
                make.top.equalTo(currentPage.frame.origin.y)
                make.left.right.equalToSuperview()
            }
            return
        }
        if refreshView != nil {
            handleRefreshAction(with: pan)
            return
        }
        if pan.state == .began {
            flipLayer?.removeFromSuperview()
            let flipDirection: SWFlipDirection = offSet.y > 0 ? .down : .up
            let nextIndex = offSet.y > 0 ? pageIndex - 1 : pageIndex + 1
            let currentPageImage = SWScreenshotsTool.getScreenshots(at: self)
            currentPage.removeFromSuperview()
            let flipNextPage = delegate.flipBoard(self, pageAt: nextIndex)
            addSubview(flipNextPage)
            flipNextPage.layoutIfNeeded()
            let nextPageImage = SWScreenshotsTool.getScreenshots(at: self)
            flipNextPage.isHidden = true
            flipLayer = SWFlipLayer(flipDirection: flipDirection, frame: bounds, currentImage: currentPageImage, nextImage: nextPageImage)
            //After the page is flipped successfully, remove the original page and add the next page
            flipLayer?.flipSuccess = { [weak self] isSuccess in
                if isSuccess {
                    self!.currentPage.removeFromSuperview()
                    flipNextPage.isHidden = false
                    self!.currentPage = flipNextPage
                    self!.pageIndex = nextIndex
                    if flipDirection == .up {
                        self!.flipImages.append(currentPageImage)
                    } else {
                        self!.flipImages.removeLast()
                    }
                } else {
                    self!.addSubview(self!.currentPage)
                    flipNextPage.removeFromSuperview()
                }
            }
            keyWindow.addSubview(flipLayer!)
        }
        flipLayer?.flip(pan)
    }
    
    public func flipToTop() {
        guard pageIndex > 0, flipImages.count > 0 else {
            return
        }
        let nextPageImage = SWScreenshotsTool.getScreenshots(at: self)
        flipImages.append(nextPageImage)
        flipToTopLayer = SWFlipToTopLayer(frame: bounds, images: flipImages)
        keyWindow.addSubview(flipToTopLayer!)
        flipToTopLayer?.flipToTop()
        flipToTopLayer?.complete = {[unowned self] in
            self.currentPage?.removeFromSuperview()
            self.currentPage = delegate.flipBoard(self, pageAt: 0)
            self.addSubview(self.currentPage!)
            self.pageIndex = 0
            flipImages.removeAll()
        }
    }
    
    private func handleRefreshAction(with pan: UIPanGestureRecognizer) {
        var offsetY = pan.translation(in: pan.view).y / 2
        offsetY = offsetY > 0 ? offsetY : 0
        let height = refreshView!.frame.size.height
        if offsetY > height, refreshView!.refreshState == .remindPullDown {
            refreshView!.remindReleaseToRefresh()
        }
        if offsetY < height, refreshView!.refreshState == .remindRelease {
            refreshView!.remindPullDownToRefresh()
        }
        if pan.state == .ended {
            isUserInteractionEnabled = false
            if offsetY > height || pan.velocity(in: pan.view).y > 500 {
                UIView.animate(withDuration: 0.2) {
                    self.currentPage.frame = .init(origin: .init(x: self.refreshView!.frame.origin.x, y: self.refreshView!.frame.origin.y + height), size: self.currentPage.bounds.size)
                }
                refreshView!.remindLoading()
                delegate.flipBoardRefresh(self)
            } else {
                endRefresh()
            }
        } else {
            self.currentPage.frame = .init(origin: .init(x: self.refreshView!.frame.origin.x, y: refreshView!.frame.origin.y + offsetY), size: self.currentPage.bounds.size)
        }
    }
    
    public func endRefresh() {
        UIView.animate(withDuration: 0.2) {
            self.currentPage.frame = .init(origin: self.refreshView!.frame.origin, size: self.currentPage.bounds.size)
        } completion: { _ in
            self.refreshView?.removeFromSuperview()
            self.refreshView = nil
            self.isUserInteractionEnabled = true
        }
    }
    
    private func refreshPage(at index: Int? = nil) {
        let refreshIndex = index ?? pageIndex
        currentPage.removeFromSuperview()
        currentPage = delegate.flipBoard(self, pageAt: refreshIndex)
        addSubview(currentPage)
        currentPage.frame = .init(origin: .init(x: currentPage.frame.origin.x, y: currentPage.frame.origin.y + (refreshView?.bounds.height ?? 0)), size: currentPage.bounds.size)
        pageIndex = refreshIndex
        endRefresh()
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let pan = gestureRecognizer as! UIPanGestureRecognizer
        let velocity = pan.velocity(in: self)
        return abs(velocity.y) > abs(velocity.x)
    }
}

private class SWScreenshotsTool {
    static func getScreenshots(at view: UIView) -> UIImage {
        let image = getImageFromView(view: keyWindow)
        let rect = view.convert(view.bounds, to: keyWindow)
        return generateSubImage(from: image, at: rect)
    }
    
    static func getImageFromView(view:UIView) ->UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func generateSubImage(from image: UIImage, at rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= image.scale
        rect.origin.y *= image.scale
        rect.size.width *= image.scale
        rect.size.height *= image.scale
        let imageRef = image.cgImage?.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        return image
    }
}
