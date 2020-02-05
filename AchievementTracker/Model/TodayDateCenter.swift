//
//  TodayDateCenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/27.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

// 오늘 날짜에 해당하는 year, month, day 값을 가지고 있는 싱글턴 클래스.
class TodayDateCenter {
    static let shared = TodayDateCenter()
    
    var today = Date()
    
    lazy var year: Int = 0
    lazy var month: Int = 0
    lazy var day: Int = 0
    
    private init() { }
    
    /// 앱이 foreground로 돌아왔을 때, today 값이 바뀌었을 수도 있기 때문에 업데이트하기 위한 메소드.
    func updateToday() {
        
        // 현재 날짜에 해당하는 Date를 today에 넣어줌.
        today = Date()
        
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)

        guard let yearComponent = dateComponent.year else { return }
        guard let monthComponent = dateComponent.month else { return }
        guard let dayComponent = dateComponent.day else { return }

        self.year = yearComponent
        self.month = monthComponent
        self.day = dayComponent
        
        print("Today Date Center 싱글턴 클래스의 updateToday \(year) \(month) \(day)")
    }
    
}
