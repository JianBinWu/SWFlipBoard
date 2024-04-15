//
//  FlipBoardCollectionViewCell.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SWFlipBoard

class FlipBoardCollectionViewCell: UICollectionViewCell {
    var flipBoard: SWFlipBoard!
    var title: String!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let page = FirstPageView()
        page.frame = .init(origin: .init(x: 0, y: CGRectGetMaxY(HeaderView.shared.frame)), size: .init(width: frame.width, height: frame.height - CGRectGetMaxY(HeaderView.shared.frame)))
        flipBoard = SWFlipBoard(currentPage: page)
        contentView.addSubview(flipBoard)
        flipBoard.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        flipBoard.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FlipBoardCollectionViewCell: SWFlipBoardDelegate {
    func flipBoard(_ flipBoard: SWFlipBoard, pageAt index: Int) -> UIView {
        switch index % 3 {
        case 0:
            let page = FirstPageView()
            page.frame = .init(origin: .init(x: 0, y: CGRectGetMaxY(HeaderView.shared.frame)), size: .init(width: bounds.width, height: bounds.height - CGRectGetMaxY(HeaderView.shared.frame)))
            return page
        case 1:
            let page = SecondPageView()
            page.frame = .init(origin: .init(x: 0, y: CGRectGetMaxY(HeaderView.shared.frame)), size: .init(width: bounds.width, height: bounds.height - CGRectGetMaxY(HeaderView.shared.frame)))
            return page
        case 2:
            let page = ThirdPageView()
            page.frame = .init(origin: .zero, size: bounds.size)
            return page
        default:
            return UITableViewCell()
        }
    }
    
    func flipBoardRefresh(_ flipBoard: SWFlipBoard) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            flipBoard.endRefresh()
        }
    }
}
