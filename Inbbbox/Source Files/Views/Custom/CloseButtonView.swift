//
//  CloseButtonView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 16/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CloseButtonView: UIView {
    
    let closeButton = UIButton(type: .System)
    let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark)))
    
    private let diameterSize = CGFloat(26)
    private var didSetConstraints = false
    
    // MARK: - Life cycle
    
    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        vibrancyView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.4)
        vibrancyView.layer.cornerRadius = diameterSize/2
        vibrancyView.clipsToBounds = true
        addSubview(vibrancyView)
        
        closeButton.configureForAutoLayout()
        let image = UIImage(named: "ic-cross-naked")?.imageWithRenderingMode(.AlwaysOriginal)
        closeButton.setImage(image, forState: .Normal)
        addSubview(closeButton)
    }
    
    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true
            
            closeButton.autoPinEdgesToSuperviewEdges()
            vibrancyView.autoPinEdgesToSuperviewEdges()
            autoSetDimensionsToSize(CGSize(width: diameterSize, height: diameterSize))
        }
        super.updateConstraints()
    }
}