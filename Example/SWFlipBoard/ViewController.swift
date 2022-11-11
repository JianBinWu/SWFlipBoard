//
//  ViewController.swift
//  SWFlipBoard
//
//  Created by 121805186@qq.com on 11/11/2022.
//  Copyright (c) 2022 121805186@qq.com. All rights reserved.
//

import UIKit
import SWFlipBoard

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        let page = Bundle.main.loadNibNamed("FirstPageView", owner: self)?.first as! FirstPageView
        let page = UIImageView(image: UIImage(named: "first"))
        let flipBoard = SWFlipBoard(currentPage: page)
        view.addSubview(flipBoard)
        flipBoard.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(-100)
        }
        flipBoard.delegate = self
    }

}

extension ViewController: SWFlipBoardDelegate {
    func flipBoard(_ flipBoard: SWFlipBoard, flipPageAt index: Int) -> UIView {
        if flipBoard.pageIndex%2 == 0 {
//            return Bundle.main.loadNibNamed("SecondPageView", owner: self)?.first as! SecondPageView
            return UIImageView(image: UIImage(named: "second"))
        } else {
//            return Bundle.main.loadNibNamed("FirstPageView", owner: self)?.first as! FirstPageView
            return UIImageView(image: UIImage(named: "first"))
        }
    }

    func flipBoardRefresh(_ flipBoard: SWFlipBoard) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            flipBoard.endRefresh()
        }
    }
}

