//
//  PullToRefresh.swift
//  uchicock
//
//  Created by Kou Kinyo on 2019/08/09.
//  Copyright © 2019 Kou. All rights reserved.
//

import Foundation
import UIKit

public enum PullToRefreshViewState {
    case pullToRefresh
    case releaseToRefresh
    case refreshing
}

public protocol RefreshExtensionsProvider: class {
    associatedtype CompatibleType
    var refreshHeader: CompatibleType { get }
}

extension RefreshExtensionsProvider {
    /// A proxy which hosts reactive extensions for `self`.
    public var refreshHeader: PullToRefresh<Self> {
        return PullToRefresh(self)
    }
}

public struct PullToRefresh<Base> {
    public let base: Base
    
    // Construct a proxy.
    // - parameters:
    //   - base: The object to be proxied.
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

extension UIScrollView: RefreshExtensionsProvider {}

private var kRefreshHeaderKey: Void?
public extension UIScrollView {
    /// Pull-to-refresh associated property
    var header: PullToRefreshHeaderView? {
        get { return (objc_getAssociatedObject(self, &kRefreshHeaderKey) as? PullToRefreshHeaderView) }
        set(newValue) { objc_setAssociatedObject(self, &kRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
}

public extension PullToRefresh where Base: UIScrollView {
    /// Add pull-to-refresh
    @discardableResult
    func addPullToRefresh(handler: @escaping PullToRefreshHandler) -> PullToRefreshHeaderView {
        removeRefreshHeader()
        let header = PullToRefreshHeaderView(frame: CGRect.zero, handler: handler)
        let headerH = header.animator.executeIncremental
        header.frame = CGRect.init(x: 0.0, y: -headerH /* - contentInset.top */, width: self.base.bounds.size.width, height: headerH)
        self.base.addSubview(header)
        self.base.header = header
        return header
    }
    
    /// Remove
    func removeRefreshHeader() {
        self.base.header?.stopRefreshing()
        self.base.header?.removeFromSuperview()
        self.base.header = nil
    }
    
    /// Stop pull to refresh
    func stopPullToRefresh() {
        self.base.header?.stopRefreshing()
    }
}

public typealias PullToRefreshHandler = (() -> ())
