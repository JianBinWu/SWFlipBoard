//
//  FlipBoard.swift
//  FlipBoard
//
//  Created by Apple on 2022/11/3.
//

import UIKit
import SnapKit

enum SWFlipDirection {
    case up
    case down
}

@objc public protocol SWFlipBoardDelegate {
    //page used when flipping page
    func flipBoard(_ flipBoard: SWFlipBoard, flipPageAt index: Int) -> UIView
    func flipBoardRefresh(_ flipBoard: SWFlipBoard)
    //The page used after the page is flipped
    @objc optional func flipBoard(_ flipBoard: SWFlipBoard, pageAt index: Int) -> UIView
}

public class SWFlipBoard: UIView {
    private var refreshView: SWRefresh?
    private var flipLayer: SWFlipLayer!
    private(set) var currentPage: UIView!
    public private(set) var pageIndex = 0
    public var delegate: SWFlipBoardDelegate!
    
    public convenience init(currentPage: UIView) {
        self.init()
        self.currentPage = currentPage
        addSubview(currentPage)
        currentPage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(flip(pan:))))
    }

    @objc private func flip(pan: UIPanGestureRecognizer) {
        let offSet = pan.velocity(in: pan.view)
        //if pull down the first page then refresh
        if offSet.y > 0 && pageIndex == 0 && pan.state == .began {
            refreshView = SWRefresh()
            insertSubview(refreshView!, belowSubview: currentPage)
            refreshView!.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
            }
            return
        }
        if refreshView != nil {
            handleRefreshAction(with: pan)
            return
        }
        if pan.state == .began {
            let flipDirection: SWFlipDirection = offSet.y > 0 ? .down : .up
            let nextIndex = offSet.y > 0 ? pageIndex - 1 : pageIndex + 1
            let flipNextPage = delegate.flipBoard(self, flipPageAt: nextIndex)
            flipNextPage.layoutIfNeeded()
            flipLayer = SWFlipLayer(flipDirection: flipDirection, frame: bounds, currentImage: SWScreenshotsTool.getScreenshots(at: self), nextImage: SWScreenshotsTool.getImageFromView(view: flipNextPage))
            //After the page is flipped successfully, remove the original page and add the next page
            flipLayer.flipSuccess = { [weak self] in
                self!.currentPage.removeFromSuperview()
                self!.currentPage = self!.delegate.flipBoard?(self!, pageAt: nextIndex) ?? flipNextPage
                self!.insertSubview(self!.currentPage, belowSubview: self!.flipLayer)
                self!.currentPage.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self!.pageIndex = nextIndex
            }
            addSubview(flipLayer)
        }
        flipLayer.flip(pan)
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
                    self.currentPage.frame = .init(origin: .init(x: 0, y: height), size: self.currentPage.bounds.size)
                }
                refreshView!.remindLoading()
                delegate.flipBoardRefresh(self)
            } else {
                endRefresh()
            }
        } else {
            self.currentPage.frame = .init(origin: .init(x: 0, y: offsetY), size: self.currentPage.bounds.size)
        }
    }
    
    public func endRefresh() {
        UIView.animate(withDuration: 0.2) {
            self.currentPage.frame = self.bounds
        } completion: { _ in
            self.refreshView?.removeFromSuperview()
            self.refreshView = nil
            self.isUserInteractionEnabled = true
        }
    }
}

private class SWScreenshotsTool {
    static func getScreenshots(at view: UIView) -> UIImage {
        var window: UIWindow!
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .last?.windows
                .filter({ $0.isKeyWindow })
                .last
        } else {
            window = UIApplication.shared.keyWindow
        }
        let image = getImageFromView(view: window!)
        let rect = view.convert(view.bounds, to: window)
        return generateSubImage(from: image, at: rect)
    }
    
    static func getImageFromView(view:UIView) ->UIImage{
        UIGraphicsBeginImageContext(view.bounds.size)
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
