//
//  HeaderView.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    static let shared = HeaderView()
    let titles = ["欢迎来华", "中国城市", "链上两岸", "文化", "艺术", "生活", "吃遍中国", "游遍中国", "买遍中国"]
    private var collectionView: UICollectionView!
    private var listBtn: UIButton!
    private var searchBtn: UIButton!
    
    var selectedIndex = 0 {
        didSet {
            collectionView.scrollToItem(at: .init(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            collectionView.reloadData()
        }
    }
    var scrollToPage: ((_: Int)->())!
    
    init() {
        super.init(frame: .zero)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        listBtn = UIButton()
        addSubview(listBtn)
        listBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalToSuperview()
        }
        listBtn.setImage(UIImage(named: "list"), for: .normal)
        
        searchBtn = UIButton()
        addSubview(searchBtn)
        searchBtn.snp.makeConstraints { make in
            make.right.equalTo(listBtn.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalToSuperview()
        }
        searchBtn.setImage(UIImage(named: "search"), for: .normal)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
//        layout.itemSize = .init(width: 80, height: 50)
//        layout.minimumLineSpacing = 20
        layout.sectionInset = .init(top: 0, left: 10, bottom: 0, right: 0)
        layout.estimatedItemSize = .init(width: 150, height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.right.equalTo(searchBtn.snp.left).offset(-25)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: "ListCollectionViewCell")
    }
}

extension HeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        cell.handleState(isSelected: selectedIndex == indexPath.row, title: titles[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            return
        }
        selectedIndex = indexPath.row
        scrollToPage(indexPath.row)
    }
}
