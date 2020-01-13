//
//  UIColor+Extension.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

// 캘린더 폰트 색깔
enum FontColor {
    case weekday
}

extension UIColor {
    static func fontColor(_ name: FontColor) -> UIColor {
        switch name {
        case .weekday:
            return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
    }
}
