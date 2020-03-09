//
//  InputData.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/03/09.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

class InputDataModel {
    var userAchievement: Achievement?
    var memo: String?
    
    func searchData(what date: Date) {
        guard let dayInfo = DataManager.shared.filterObject(what: date) else { return }
        
        guard let achievement = dayInfo.first?.achievement else { return }
        switch achievement {
        case "A":
            userAchievement = Achievement.A
        case "B":
            userAchievement = Achievement.B
        case "C":
            userAchievement = Achievement.C
        case "D":
            userAchievement = Achievement.D
        case "E":
            userAchievement = Achievement.E
        default:
            return
        }
    }
    
    func searchMemo(what date: Date){
        guard let dayInfo = DataManager.shared.filterObject(what: date) else { return }
        
        if dayInfo.first?.memo.count != 0 {
            memo = dayInfo.first?.memo
        }else{
            return
        }
    }
}
