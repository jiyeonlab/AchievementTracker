//
//  MonthDataCenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/21.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

class MonthDataCenter {
    static let shared = MonthDataCenter()
    
    var currentPage: Date?
    var achievementCount: [Int] = [Int]()
    
    func calculateData(currentPage date: Date) {
        
        achievementCount.removeAll()
        let realm = try? Realm()
        guard let data = realm?.objects(DayInfo.self) else { return }
        
        let dateComponent = Calendar.current.dateComponents([.year, .month], from: date)
        
        guard let year = dateComponent.year else { return }
        guard let month = dateComponent.month else { return }
        let thisMonth = data.filter("year == %@", year).filter("month == %@", month)
        
        // 데이터에 접근은 햇고, 성취도가 몇개인지 알아내야해.
        let aCount = thisMonth.filter("achievement == %@", "A").count
        let bCount = thisMonth.filter("achievement == %@", "B").count
        let cCount = thisMonth.filter("achievement == %@", "C").count
        let dCount = thisMonth.filter("achievement == %@", "E").count
        let eCount = thisMonth.filter("achievement == %@", "D").count
        
        achievementCount.append(eCount)
        achievementCount.append(dCount)
        achievementCount.append(cCount)
        achievementCount.append(bCount)
        achievementCount.append(aCount)
        
        print("성취도 array =\(achievementCount)")
    }
}
