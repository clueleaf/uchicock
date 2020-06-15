//
//  PullToRefreshHeaderView.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/08/09.
//  Copyright © 2019 Kou. All rights reserved.
//

import UIKit

open class PullToRefreshHeaderView: UIView {
    open weak var scrollView: UIScrollView?
    
    /// @param handler Refresh callback method
    open var handler: PullToRefreshHandler?
    
    /// @param animator Animated view refresh controls, custom must comply with the following two protocol
    open var animator: PullToRefreshHeaderAnimator!
    
    fileprivate var previousOffset: CGFloat = 0.0
    fileprivate var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
    fileprivate var scrollViewBounces: Bool = true
    fileprivate var isRefreshing = false
    
    /// @param tag observing
    fileprivate var isObservingScrollView = false
    fileprivate var isIgnoreObserving = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin]
    }
    
    public convenience init(frame: CGRect, handler: @escaping PullToRefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = PullToRefreshHeaderAnimator.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        /// Remove observer from superview immediately
        self.removeObserver()
        DispatchQueue.main.async { [weak self, newSuperview] in
            /// Add observer to new superview in next runloop
            self?.addObserver(newSuperview)
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.scrollView = self.superview as? UIScrollView
        if let _ = animator {
            let v = animator.view
            if v.superview == nil {
                let inset = animator.insets
                self.addSubview(v)
                v.frame = CGRect.init(x: inset.left,
                                      y: inset.right,
                                      width: self.bounds.size.width - inset.left - inset.right,
                                      height: self.bounds.size.height - inset.top - inset.bottom)
                v.autoresizingMask = [
                    .flexibleWidth,
                    .flexibleTopMargin,
                    .flexibleHeight,
                    .flexibleBottomMargin
                ]
            }
        }
        
        DispatchQueue.main.async {
            [weak self] in
            self?.scrollViewBounces = self?.scrollView?.bounces ?? true
            self?.scrollViewInsets = self?.scrollView?.contentInset ?? UIEdgeInsets.zero
        }
    }
    
    // MARK: - Action
    
    public final func startRefreshing() -> Void {
        if isRefreshing == false{
            isRefreshing = true
            guard let scrollView = scrollView else {
                return
            }
            
            // ignore observer
            self.ignoreObserver(true)
            
            // stop scroll view bounces for animation
            scrollView.bounces = false
            
            self.animator.refreshAnimationBegin(view: self)
            
            // 缓存scrollview当前的contentInset, 并根据animator的executeIncremental属性计算刷新时所需要的contentInset，它将在接下来的动画中应用。
            // Tips: 这里将self.scrollViewInsets.top更新，也可以将scrollViewInsets整个更新，因为left、right、bottom属性都没有用到，如果接下来的迭代需要使用这三个属性的话，这里可能需要额外的处理。
            var insets = scrollView.contentInset
            self.scrollViewInsets.top = insets.top
            insets.top += animator.executeIncremental
            
            // We need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then.
            scrollView.contentInset = insets
            scrollView.contentOffset.y = previousOffset
            previousOffset -= animator.executeIncremental
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                scrollView.contentOffset.y = -insets.top
            }, completion: { (finished) in
                self.handler?()
                // un-ignore observer
                self.ignoreObserver(false)
                scrollView.bounces = self.scrollViewBounces
            })
        }
    }
    
    public final func stopRefreshing() -> Void {
        if isRefreshing{
            guard let scrollView = scrollView else {
                return
            }
            
            // ignore observer
            self.ignoreObserver(true)
            
            self.animator.refreshAnimationEnd(view: self)
            
            // Back state
            scrollView.contentInset.top = self.scrollViewInsets.top
            scrollView.contentOffset.y =  self.scrollViewInsets.top + self.previousOffset
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                scrollView.contentOffset.y = -self.scrollViewInsets.top
            }, completion: { (finished) in
                self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
                self.isRefreshing = false
                scrollView.contentInset.top = self.scrollViewInsets.top
                self.previousOffset = scrollView.contentOffset.y
                // un-ignore observer
                self.ignoreObserver(false)
            })
        }
    }
    
    //  ScrollView contentSize change action
    public func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
    }
    
    fileprivate static var context = "PullToRefreshKVOContext"
    fileprivate static let offsetKeyPath = "contentOffset"
    fileprivate static let contentSizeKeyPath = "contentSize"
    
    public func ignoreObserver(_ ignore: Bool = false) {
        if let scrollView = scrollView {
            scrollView.isScrollEnabled = !ignore
        }
        isIgnoreObserving = ignore
    }
    
    fileprivate func addObserver(_ view: UIView?) {
        if let scrollView = view as? UIScrollView, !isObservingScrollView {
            scrollView.addObserver(self, forKeyPath: PullToRefreshHeaderView.offsetKeyPath, options: [.initial, .new], context: &PullToRefreshHeaderView.context)
            scrollView.addObserver(self, forKeyPath: PullToRefreshHeaderView.contentSizeKeyPath, options: [.initial, .new], context: &PullToRefreshHeaderView.context)
            isObservingScrollView = true
        }
    }
    
    fileprivate func removeObserver() {
        if let scrollView = superview as? UIScrollView, isObservingScrollView {
            scrollView.removeObserver(self, forKeyPath: PullToRefreshHeaderView.offsetKeyPath, context: &PullToRefreshHeaderView.context)
            scrollView.removeObserver(self, forKeyPath: PullToRefreshHeaderView.contentSizeKeyPath, context: &PullToRefreshHeaderView.context)
            isObservingScrollView = false
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &PullToRefreshHeaderView.context {
            guard isUserInteractionEnabled == true && isHidden == false else {
                return
            }
            if keyPath == PullToRefreshHeaderView.contentSizeKeyPath {
                if isIgnoreObserving == false {
                    sizeChangeAction(object: object as AnyObject?, change: change)
                }
            }else if keyPath == PullToRefreshHeaderView.offsetKeyPath {
                if isIgnoreObserving == false {
                    offsetChangeAction(object: object as AnyObject?, change: change)
                }
            }
        }
    }
    
    open func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else {
            return
        }
        
        guard self.isRefreshing == false else {
            let top = scrollViewInsets.top
            let offsetY = scrollView.contentOffset.y
            let height = self.frame.size.height
            var scrollingTop = (-offsetY > top) ? -offsetY : top
            scrollingTop = (scrollingTop > height + top) ? (height + top) : scrollingTop
            
            scrollView.contentInset.top = scrollingTop
            
            return
        }
        
        // Check needs re-set animator's progress or not.
        var isRecordingProgress = false
        defer {
            if isRecordingProgress == true {
                let percent = -(previousOffset + scrollViewInsets.top) / self.animator.trigger
            }
        }
        
        let offsets = previousOffset + scrollViewInsets.top
        if offsets < -self.animator.trigger {
            // Reached critical
            if isRefreshing == false {
                if scrollView.isDragging == false {
                    // Start to refresh...
                    self.startRefreshing()
                    self.animator.refresh(view: self, stateDidChange: .refreshing)
                }else{
                    // Release to refresh! Please drop down hard...
                    self.animator.refresh(view: self, stateDidChange: .releaseToRefresh)
                    isRecordingProgress = true
                }
            }
        }else if offsets < 0 {
            // Pull to refresh!
            if isRefreshing == false {
                self.animator.refresh(view: self, stateDidChange: .pullToRefresh)
                isRecordingProgress = true
            }
        }else{
            // Normal state
        }
        
        previousOffset = scrollView.contentOffset.y
    }
}
