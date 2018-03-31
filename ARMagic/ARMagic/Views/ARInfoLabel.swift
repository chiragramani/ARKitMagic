//
//  ARInfoLabel.swift
//  ARMagic
//
//  Created by Chirag Ramani on 31/03/18.
//  Copyright © 2018 Chirag Ramani. All rights reserved.
//

import UIKit

class ARInfoLabel: UILabel {
    /// Constants.
    private enum Constants {
        static let topPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 16
        static let leftPadding: CGFloat = 16
        static let rightPadding: CGFloat = 16
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    /// Intrinsic Content Size: takes padding as defined into account.
    override var intrinsicContentSize: CGSize {
        let actualIntrinsicContentSize = super.intrinsicContentSize
        let totalHorizontalPadding = Constants.leftPadding + Constants.rightPadding
        let totalVerticalPadding = Constants.topPadding + Constants.bottomPadding
        let intrinsicContentSizeWithPadding = CGSize(width: actualIntrinsicContentSize.width + totalHorizontalPadding,
                                                     height: actualIntrinsicContentSize.height + totalVerticalPadding)
        return intrinsicContentSizeWithPadding
    }
    
    /// Configures the UI attributes.
    private func configureUI() {
        /// Configuring Font.
        font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        /// Configuring corner radius.
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }
}
