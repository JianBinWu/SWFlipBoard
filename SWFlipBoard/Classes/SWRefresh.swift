//
//  SWRefresh.swift
//  FlipBoard
//
//  Created by Apple on 2022/11/10.
//

import UIKit

enum SWRefreshState {
    case remindPullDown
    case remindRelease
    case loading
}

//refresh component
class SWRefresh: UIView {
    private var indicator: UIImageView!
    private var reminder: UILabel!
    private var loadingAngle: CGFloat = 0
    var refreshState = SWRefreshState.remindPullDown
    
    lazy private var isPreferredLanCN = {
        if let preferredLang = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String, preferredLang.hasPrefix("zh-") {
            return true
        }
        return false
    }()
    lazy private var remindPullDownText = {
        isPreferredLanCN ? "下拉刷新" : "Pull down to refresh"
    }()
    lazy private var remindReleaseText = {
        isPreferredLanCN ? "松开可以刷新" : "Release to refresh"
    }()
    lazy private var remindLoadingText = {
        isPreferredLanCN ? "正在加载" : "loading"
    }()
    private var arrowImage = {
        let bundle = Bundle.init(identifier: "org.cocoapods.SWFlipBoard")
        return UIImage(named: "SWFlipBoard.bundle/arrow", in: bundle, compatibleWith: nil)
    }()
    private var loadingImage = {
        let bundle = Bundle.init(identifier: "org.cocoapods.SWFlipBoard")
        return UIImage(named: "SWFlipBoard.bundle/loading", in: bundle, compatibleWith: nil)
    }()
    
    
    init() {
        super.init(frame: .zero)
        
        indicator = UIImageView()
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(8)
            make.size.equalTo(CGSizeMake(25, 25))
        }
        indicator.image = arrowImage
        
        reminder = UILabel()
        addSubview(reminder)
        reminder.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(indicator.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        reminder.text = remindPullDownText
        reminder.textColor = UIColor(red: 191 / 255.0, green: 191 / 255.0, blue: 191 / 255.0, alpha: 1)
        reminder.font = .systemFont(ofSize: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remindPullDownToRefresh() {
        refreshState = .remindPullDown
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: 0.0001)
        }
        reminder.text = remindPullDownText
    }
    
    func remindReleaseToRefresh() {
        refreshState = .remindRelease
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: Double.pi)
        }
        reminder.text = remindReleaseText
    }
    
    func remindLoading() {
        refreshState = .loading
        indicator.image = loadingImage
        reminder.text = remindLoadingText
        loading()
    }
    
    func loading() {
        UIView.animate(withDuration: 0.05) {
            self.indicator.transform = CGAffineTransform(rotationAngle: self.loadingAngle)
        } completion: { _ in
            self.loadingAngle += Double.pi / 20
            self.loading()
        }
    }
}
