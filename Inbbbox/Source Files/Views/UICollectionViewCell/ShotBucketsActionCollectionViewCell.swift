//
//  ShotBucketsActionCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsActionCollectionViewCell: UICollectionViewCell, Reusable {

    let button = UIButton.newAutoLayout()

    fileprivate let cellHeight = CGFloat(44)

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        
        button.configureForAutoLayout()
        button.setTitleColor(.pinkColor(), for: .normal)
        button.setTitleColor(.textLightColor(), for: .disabled)
        button.setTitleColor(.pinkColor(alpha: 0.5), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        contentView.addSubview(button)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            button.autoPinEdgesToSuperviewEdges()

            contentView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
                    -> UICollectionViewLayoutAttributes {

        layoutAttributes.frame = {

            var frame = layoutAttributes.frame
            frame.size.height = cellHeight

            return frame.integral
        }()

        return layoutAttributes
    }
}
