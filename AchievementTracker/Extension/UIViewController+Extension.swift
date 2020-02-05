//
//  UIViewController+Extension.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/17.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// 화면과 navigationbar를 연장한 효과를 주기 위한 메소드
    func configNavigationBar(vcType type: BackGroundType) {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.viewBackgroundColor(type)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // 각종 에러 상황에서 띄워줄 action sheet
    func showErrorAlert() {
        let alertController = UIAlertController(title: "경고", message: "다시 시도하세요", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
