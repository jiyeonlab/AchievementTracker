//
//  UICollectionViewCell+Extension.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/02/19.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    // Datacell과 Memocell의 생김새를 config
    func configApperance(at view: UIView) {
        view.backgroundColor = UIColor.viewBackgroundColor(.subView)
        view.layer.cornerRadius = Config.Appearance.cellCornerRadius
        view.layer.borderColor = UIColor.borderColor().cgColor
        view.layer.borderWidth = Config.Appearance.cellBorderWidth
        view.layer.masksToBounds = true
    }
}
