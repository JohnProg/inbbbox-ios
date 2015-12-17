//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotCollectionViewCell: UICollectionViewCell, HeightAware {

//    MARK: - Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor.greenColor()
    }

    static func prefferedHeight() -> CGFloat {
        return CGFloat(235)
    }
}
