//
//  UIColor+Extension.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 각 폰트의 색상을 리턴하는 메소드
    static func fontColor(_ name: FontType) -> UIColor {
        switch name {
        case .weekday:
            return #colorLiteral(red: 0.4810999632, green: 0.7885328531, blue: 0.4410419762, alpha: 1)
        case .memo:
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case .today:
            return #colorLiteral(red: 0.9579854608, green: 0.781021893, blue: 0, alpha: 1)
        }
    }
    
    /// 각 성취도 값에 따른 색을 리턴하는 메소드
    static func achievementColor(_ achievement: Achievement) -> UIColor {
        switch achievement {
        case .A:
            return #colorLiteral(red: 0.1019607843, green: 0.3803921569, blue: 0.1529411765, alpha: 1)
        case .B:
            return #colorLiteral(red: 0.1411764706, green: 0.6039215686, blue: 0.2352941176, alpha: 1)
        case .C:
            return #colorLiteral(red: 0.4810488224, green: 0.7885745168, blue: 0.4362606406, alpha: 1)
        case .D:
            return #colorLiteral(red: 0.7764705882, green: 0.8941176471, blue: 0.5450980392, alpha: 1)
        case .E:
            return #colorLiteral(red: 0.8118950725, green: 0.8901877999, blue: 0.7907294035, alpha: 1)
        }
    }
    
    /// 각 type에 따라 background 색을 리턴하는 메소드
    static func viewBackgroundColor(_ type: BackGroundType) -> UIColor {
        switch type {
        case .mainView:
            return #colorLiteral(red: 0.158882767, green: 0.1719311476, blue: 0.2238469422, alpha: 1)
        case .inputView:
            return #colorLiteral(red: 0.1235230342, green: 0.1367119849, blue: 0.1842530966, alpha: 1)
        case .subView:
            return #colorLiteral(red: 0.1896958947, green: 0.2074376941, blue: 0.2753842473, alpha: 1)
        }
    }
    
    /// 캘린더의 각 날짜의 border 색을 리턴하는 메소드
    static func borderColor() -> UIColor {
        return #colorLiteral(red: 0.1834537089, green: 0.2006109357, blue: 0.266325891, alpha: 1)
    }
}
