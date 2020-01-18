//
//  GlobalConstant.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/15.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

struct Config {
    
    struct Appearance {
        static let dayBorderRadius: CGFloat = 0
        static let headerAlpha: CGFloat = 0.0
    }
    
    struct FontSize {
        static let monthFontSize: CGFloat = 23.0
        static let weekdayFontSize: CGFloat = 15.0
        static let dayFontSize: CGFloat = 13.0
    }
    
}

// 오늘 날짜에 해당하는 year, month, day 값을 가지는 TodayDateComponent 타입.
struct TodayDateComponent {
    
    static let today = Date()
    
    static var dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)
    
    static var year: Int {
        guard let yearComponent = dateComponent.year else { return 0 }
        return yearComponent
    }
    static var month: Int {
        guard let monthComponent = dateComponent.month else { return 0 }
        return monthComponent
    }
    static var day: Int {
        guard let dayComponent = dateComponent.day else { return 0 }
        return dayComponent
    }
    
}
