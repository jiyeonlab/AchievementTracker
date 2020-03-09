//
//  InputModel.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/03/09.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

class InputModel {
    var userAchievement: Achievement?
    var test: String?
    
    func convertValue() -> Int {
        guard let value = userAchievement else { return 0 }
        switch value {
        case .A:
            return 4
        case .B:
            return 3
        case .C:
            return 2
        case .D:
            return 1
        case .E:
            return 0
        }
    }
    
    func checkTodayData(clicked date: Date) -> Results<DayInfo>? {
        
        guard let clickDayInfo = DataManager.shared.filterObject(what: date) else { return nil }
//        
//        guard let achievement = clickDayInfo.first?.achievement else { return nil }
//
//        switch achievement {
//        case "A":
//            userAchievement = Achievement.A
//        case "B":
//            userAchievement = Achievement.B
//        case "C":
//            userAchievement = Achievement.C
//        case "D":
//            userAchievement = Achievement.D
//        case "E":
//            userAchievement = Achievement.E
//        default:
//            return nil
//        }

        return clickDayInfo
    }
}
