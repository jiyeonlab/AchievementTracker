//
//  UIViewController+Extension.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/17.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

enum VCType {
    case mainView, inputView
}

extension UIViewController {
    
    /// 화면과 navigationbar를 연장한 효과를 주기 위한 메소드
    func configNavigationBar(vcType type: VCType) {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.viewBackgroundColor(type)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
