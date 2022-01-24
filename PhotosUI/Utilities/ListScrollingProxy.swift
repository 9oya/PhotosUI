//
//  ListScrollingProxy.swift
//  PhotosUI
//
//  Created by Eido Goya on 2022/01/24.
//

import UIKit
import SwiftUI

struct ListScrollingHelper: UIViewRepresentable {
    let proxy: ListScrollingProxy // reference type
    
    func makeUIView(context: Context) -> UIView {
        return UIView() // managed by SwiftUI, no overloads
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        proxy.catchScrollView(for: uiView) // here UIView is in view hierarchy
    }
}

class ListScrollingProxy {
    enum Action {
        case end(animated: Bool)
        case top(animated: Bool)
        case point(point: CGPoint, animated: Bool)
    }
    
    private var scrollView: UIScrollView?
    var animated: Bool = false
    
    func catchScrollView(for view: UIView) {
        if nil == scrollView {
            scrollView = view.enclosingScrollView()
        }
    }
    
    func scrollTo(_ action: Action) {
        if let scroller = scrollView {
            var rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
            switch action {
            case .top(let animated):
                self.animated = animated
            case .end(let animated):
                self.animated = animated
                rect.origin.y = scroller.contentSize.height +
                scroller.contentInset.bottom + scroller.contentInset.top - 1
            case let .point(point, animated):
                self.animated = animated
                rect.origin.y = point.y
            }
            scroller.scrollRectToVisible(rect, animated: animated)
        }
    }
}

extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        var next: UIView? = self
        repeat {
            next = next?.superview
            if let scrollview = next as? UIScrollView {
                return scrollview
            }
        } while next != nil
        return nil
    }
}
