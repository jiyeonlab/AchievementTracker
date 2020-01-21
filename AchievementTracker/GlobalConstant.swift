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
        static let headerAlpha: CGFloat = 0.1
        static let achievementRadius: CGFloat = 20.0
    }
    
    struct FontSize {
        static let monthFontSize: CGFloat = 23.0
        static let weekdayFontSize: CGFloat = 15.0
        static let dayFontSize: CGFloat = 13.0
    }
    
    struct AspectRatio {
        static let cellAspectRatio: CGFloat = 1.1
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

enum Achievement: String {
    // E-D-C-B-A 순으로 성취도 등급이 높아짐.
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
}

// 어떤 날짜를 선택하면, memocell로 notification 보내기 위해 추가
let UserClickSomeDayNotification = Notification.Name("UserClickSomeDay")

// 메모입력 화면에서 done 버튼을 누르면, 메모 cell이 collectionview의 중간으로 오도록 하기 위해 추가
let CenterToMemoCellNotification = Notification.Name("CenterToMemoCell")

// 앱이 background에서 다시 foreground로 올 때, 캘린더를 reload하기 위한 노티피케이션
let RefreshCalendarNotification = Notification.Name("RefreshCalendar")

// graphview를 새로 그려달라고 보내는 노티피케이션
let ReloadGraphViewNotification = Notification.Name("ReloadGraphView")
