//
//  HomeViewController.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    var collectionView: UICollectionView!
    var headerView: HeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(flipToTop), name: NSNotification.Name(rawValue: "flipToTop"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func initUI() {
        view.backgroundColor = .white
        
        headerView = HeaderView.shared
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(50)
        }
        headerView.scrollToPage = { [weak self] in
            self!.collectionView.scrollToItem(at: .init(row: $0, section: 0), at: .left, animated: true)
        }
        headerView.layoutIfNeeded()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.insertSubview(collectionView, belowSubview: headerView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(FlipBoardCollectionViewCell.self, forCellWithReuseIdentifier: "FlipBoardCollectionViewCell")
    }
    
    @objc func flipToTop() {
        let cell = collectionView.cellForItem(at: .init(row: headerView.selectedIndex, section: 0)) as! FlipBoardCollectionViewCell
        cell.flipBoard.flipToTop()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        headerView.titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlipBoardCollectionViewCell", for: indexPath) as! FlipBoardCollectionViewCell
        cell.title = headerView.titles[headerView.selectedIndex]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        headerView.selectedIndex = index
    }
}
