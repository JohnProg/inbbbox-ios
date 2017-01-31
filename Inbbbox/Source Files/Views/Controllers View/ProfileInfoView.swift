//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

final class ProfileInfoView: UIView {

    let followersAmountView = UserStatisticView(title: Localized("ProfileInfoView.Followers", comment: "Followers"))
    let shotsAmountView = UserStatisticView(title: Localized("ProfileInfoView.Shots", comment: "Shots"))
    let followingAmountView = UserStatisticView(title: Localized("ProfileInfoView.Following", comment: "Following"))
    let locationView = LocationView()

    private(set) lazy var bioLabel: UILabel = { [unowned self] in
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        label.numberOfLines = 0
        label.textColor = .textMediumGrayColor()
        label.textAlignment = .center

        return label
    }()

    private lazy var statisticsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.followersAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: .separatorGrayColor()),
                self.shotsAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: .separatorGrayColor()),
                self.followingAmountView
            ]
        )
        stackView.axis = .horizontal

        self.followersAmountView.autoMatch(.width, to: .width, of: self.followingAmountView)
        self.followersAmountView.autoMatch(.width, to: .width, of: self.shotsAmountView)

        return stackView
    }()

    private lazy var headerStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor()),
                self.statisticsStackView,
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor())
            ]
        )
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var informationsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.locationView,
                self.bioLabel,
            ]
        )
        stackView.layoutMargins = UIEdgeInsetsMake(16, 0, 12, 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12

        return stackView
    }()

    private(set) var teamsCollectionView: UICollectionView
    private(set) var teamsCollectionViewFlowLayout: UICollectionViewFlowLayout

    override init(frame: CGRect) {
        teamsCollectionViewFlowLayout = UICollectionViewFlowLayout()
        teamsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: teamsCollectionViewFlowLayout)
        super.init(frame: frame)
        setupCollectionView()
        setupLayout()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .white

        addSubview(headerStackView)
        headerStackView.autoPinEdge(toSuperviewEdge: .top)
        headerStackView.autoPinEdge(toSuperviewEdge: .left)
        headerStackView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(informationsStackView)
        informationsStackView.autoPinEdge(.top, to: .bottom, of: headerStackView)
        informationsStackView.autoPinEdge(toSuperviewEdge: .left)
        informationsStackView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(teamsCollectionView)
        teamsCollectionView.autoPinEdge(.top, to: .bottom, of: informationsStackView)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .left)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .right)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func setupCollectionView() {
        teamsCollectionViewFlowLayout.headerReferenceSize = CGSize(width: frame.size.width, height: 60)
        teamsCollectionViewFlowLayout.minimumInteritemSpacing = 0
        teamsCollectionViewFlowLayout.minimumLineSpacing = 0

        teamsCollectionView.backgroundColor = .white
    }

}
