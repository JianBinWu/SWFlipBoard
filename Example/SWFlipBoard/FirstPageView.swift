//
//  FirstPageView.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class FirstPageView: UIView {
    var tableView: UITableView!
    
    init() {
        super.init(frame: .zero)
        
        layoutTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutTableView() {
        tableView = UITableView()
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(1)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorColor = .lightGray
        tableView.register(UINib(nibName: "FirstTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstTableViewCell")
    }
}

extension FirstPageView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "FirstTableViewCell")!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.bounds.height / 4
    }
}
