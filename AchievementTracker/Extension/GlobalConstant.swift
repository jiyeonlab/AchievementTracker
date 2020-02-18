//
//  GlobalConstant.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/15.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

/// 쓰이는 폰트 종류
enum FontType {
    case weekday
    case memo
    case today
}

/// Background 타입 종류
enum BackGroundType {
    case mainView, inputView, subView
}

/// 성취도 종류
enum Achievement: String {
    // E-D-C-B-A 순으로 성취도 등급이 높아짐.
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
}

/// 해당 날짜의 성취도 정보가 있는지 없는지를 위한 enum
enum AchievementState {
    case fill
    case empty
}

// 각종 상수값 셋팅
struct Config {
    
    struct Appearance {
        static let dayBorderRadius: CGFloat = 0
        static let headerAlpha: CGFloat = 0.1
        static let achievementRadius: CGFloat = 20.0
    }
    
    struct FontSize {
        static let monthFontSize: CGFloat = 25.0
        static let weekdayFontSize: CGFloat = 15.0
        static let dayFontSize: CGFloat = 13.0
    }
    
    struct AspectRatio {
        static let cellAspectRatio: CGFloat = 1.1
        static let calendarHeightRatio: CGFloat = 1.8
        static let pickerViewHeight: CGFloat = 150
    }
    
}

// MemoCell에서 MainVC로 성취도 입력 화면 모달을 열어달라고 요청하기 위해 추가한 프로토콜
protocol UserAddNewAchievementDelegate {
    func showInputModal(from date: Date)
}

// 어떤 날짜를 선택하면, memocell로 notification 보내기 위해 추가
let UserClickSomeDayNotification = Notification.Name("UserClickSomeDay")

// 메모입력 화면에서 done 버튼을 누르면, 메모 cell이 collectionview의 중간으로 오도록 하기 위해 추가
let CenterToMemoCellNotification = Notification.Name("CenterToMemoCell")

// 앱이 background에서 다시 foreground로 올 때, 캘린더를 reload하기 위한 노티피케이션
let RefreshCalendarNotification = Notification.Name("RefreshCalendar")

// graphview를 새로 그려달라고 보내는 노티피케이션
let ReloadGraphViewNotification = Notification.Name("ReloadGraphView")
