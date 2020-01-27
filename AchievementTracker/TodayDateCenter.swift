//
//  TodayDateCenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/27.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

class TodayDateCenter {
    static let shared = TodayDateCenter()
    
    var today = Date()
    
    
    var year: Int {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)

        guard let yearComponent = dateComponent.year else { return 0 }
        return yearComponent
    }
    
    var month: Int {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)

        guard let monthComponent = dateComponent.month else { return 0 }
        return monthComponent
    }
    
    var day: Int {
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)

        guard let dayComponent = dateComponent.day else { return 0 }
        return dayComponent
    }
    
    func updateToday() {
        today = Date()
        
        print("Today Date Center 싱글턴 클래스의 updateToday \(year) \(month) \(day)")
    }
    
}
