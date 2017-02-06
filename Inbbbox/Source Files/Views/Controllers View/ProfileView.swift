//
//  ProfileView.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileView: UIView {

    let headerView = ProfileHeaderView()
    let menuBarView = ProfileMenuBarView()

    var childView = UIView()

    fileprivate let headerHeight = CGFloat(150)
    fileprivate var headerHeightConstraint: NSLayoutConstraint?
    fileprivate var isHeaderVisible: Bool = true
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(headerView)
        addSubview(menuBarView)
        addSubview(childView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            headerHeightConstraint = headerView.autoSetDimension(.height, toSize: headerHeight)

            menuBarView.autoPinEdge(toSuperviewEdge: .leading)
            menuBarView.autoPinEdge(toSuperviewEdge: .trailing)
            menuBarView.autoPinEdge(.top, to: .bottom, of: headerView)
            menuBarView.autoSetDimension(.height, toSize: 48)

            childView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            childView.autoPinEdge(.top, to: .bottom, of: menuBarView)
        }

        super.updateConstraints()
    }

    // MARK: Public

    /// Toggles header visibility.
    ///
    /// - Parameter visible: Desirable state of header.
    func toggleHeader(visible: Bool) {

        guard isHeaderVisible != visible else { return }

        UIView.animate(withDuration: 0.4) {
            self.headerView.contentView.alpha = visible ? 1 : 0
            self.headerHeightConstraint?.constant = visible ? self.headerHeight : 0
            self.layoutIfNeeded()
            self.isHeaderVisible = visible
        }
    }
}