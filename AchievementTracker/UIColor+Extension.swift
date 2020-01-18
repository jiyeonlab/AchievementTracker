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
    case memo
}

extension UIColor {
    static func fontColor(_ name: FontColor) -> UIColor {
        switch name {
        case .weekday:
            return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .memo:
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
    
    static func achievementColor(_ achievement: Achievement) -> UIColor {
        switch achievement {
        case .A:
            return #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        case .B:
            return #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        case .C:
            return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        case .D:
            return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .E:
            return #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
    }
    
    static func viewBackgroundColor(_ type: BackGroundType) -> UIColor {
        switch type {
        case .mainView:
            return #colorLiteral(red: 0.158882767, green: 0.1719311476, blue: 0.2238469422, alpha: 1)
        case .inputView:
            return #colorLiteral(red: 0.1235230342, green: 0.1367119849, blue: 0.1842530966, alpha: 1)
        case .subView:
            return #colorLiteral(red: 0.1723069251, green: 0.1884202957, blue: 0.2501500547, alpha: 1)
        case .memoView:
            return #colorLiteral(red: 0.8054062128, green: 0.883908093, blue: 0.7655668855, alpha: 1)
            
        }
    }
    
    static func borderColor() -> UIColor {
        return #colorLiteral(red: 0.1834537089, green: 0.2006109357, blue: 0.266325891, alpha: 1)
    }
}
