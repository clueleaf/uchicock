//
//  PullToRefreshHeaderAnimator.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/08/09.
//  Copyright © 2019 Kou. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

struct PullToRefreshStrings{
    static var pullToRefreshString = "引っ張ってシャッフル"
    static var releaseToRefreshString = "離すとシャッフル"
    static var refreshingString = "シャッフル中..."
}

open class PullToRefreshHeaderAnimator: UIView {
    open var pullToRefreshDescription = NSLocalizedString(PullToRefreshStrings.pullToRefreshString, comment: "") {
        didSet {
            if pullToRefreshDescription != oldValue {
                titleLabel.text = pullToRefreshDescription;
            }
        }
    }
    open var releaseToRefreshDescription = NSLocalizedString(PullToRefreshStrings.releaseToRefreshString, comment: "")
    open var loadingDescription = NSLocalizedString(PullToRefreshStrings.refreshingString, comment: "")
    
    open var view: UIView { return self }
    open var insets: UIEdgeInsets = UIEdgeInsets.zero
    open var trigger: CGFloat = 60.0
    open var executeIncremental: CGFloat = 60.0
    open var state: PullToRefreshViewState = .pullToRefresh
    
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.image = UIImage(named: "pull_to_refresh_arrow")
        imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Style.labelTextColor
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = Style.labelTextColor
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let indicatorView: PullToRefreshActivityIndicatorView = {
        let indicatorView = PullToRefreshActivityIndicatorView.init(style: .gray)
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = pullToRefreshDescription
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(indicatorView)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func refreshAnimationBegin(view: PullToRefreshHeaderView) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        imageView.isHidden = true
        titleLabel.text = loadingDescription
        imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat.pi)
    }
    
    open func refreshAnimationEnd(view: PullToRefreshHeaderView) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        imageView.isHidden = false
        titleLabel.text = pullToRefreshDescription
        imageView.transform = CGAffineTransform.identity
    }
    
    open func refresh(view: PullToRefreshHeaderView, stateDidChange state: PullToRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing:
            titleLabel.text = loadingDescription
            self.setNeedsLayout()
            break
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            self.setNeedsLayout()
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                [weak self] in
                self?.imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat.pi)
            }) { (animated) in }
            break
        case .pullToRefresh:
            titleLabel.text = pullToRefreshDescription
            self.setNeedsLayout()
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
                [weak self] in
                self?.imageView.transform = CGAffineTransform.identity
            }) { (animated) in }
            break
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        UIView.performWithoutAnimation {
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint.init(x: w / 2.0, y: h / 2.0)
            indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 16.0, y: h / 2.0)
            imageView.frame = CGRect.init(x: titleLabel.frame.origin.x - 28.0, y: (h - 18.0) / 2.0, width: 18.0, height: 18.0)
        }
    }
}

class PullToRefreshActivityIndicatorView: UIActivityIndicatorView{
}
