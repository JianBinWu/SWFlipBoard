//
//  ListCollectionViewCell.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/15.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    var label: UILabel!
    var indicator: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        label = UILabel()
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        label.font = .systemFont(ofSize: 18)
        label.textColor = .lightGray
        
        indicator = UIView()
        contentView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(5)
        }
        indicator.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleState(isSelected: Bool, title: String) {
        label.text = title
        label.textColor = isSelected ? .black : .lightGray
        indicator.isHidden = !isSelected
    }
}
