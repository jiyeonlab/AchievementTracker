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
    var allDayCount: Int = 0
    
    func calculateData(currentPage date: Date) {
        
        achievementCount.removeAll()
        let realm = try? Realm()
        guard let data = realm?.objects(DayInfo.self) else { return }
        
        let dateComponent = Calendar.current.dateComponents([.year, .month], from: date)
        
        guard let year = dateComponent.year else { return }
        guard let month = dateComponent.month else { return }
        let thisMonth = data.filter("year == %@", year).filter("month == %@", month)
        
        countAllDays(currentYear: year, currentMonth: month)
        
        // 선택한 달에 하나라도 데이터가 있다면.
        if thisMonth.count != 0 {
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
            
        }else{  // 선택한 달에 데이터가 하나도 없다면. 성취도 배열에 전부 0을 넣어줌
            achievementCount = [0, 0, 0, 0, 0]
        }
        
    }
    
    // 현재 캘린더 페이지에 나오는 년, 월의 총 날짜 수를 계산하는 메소드.
    func countAllDays(currentYear year: Int, currentMonth month: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if month != 12 {
            guard let firstDate = dateFormatter.date(from: "\(year)-\(month)-1") else { return }
            guard let lastDate = dateFormatter.date(from: "\(year)-\(month+1)-1") else { return }
            
            let allCount = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate)
            
            guard let count = allCount.day else { return }
            allDayCount = count
        } else {
            guard let firstDate = dateFormatter.date(from: "\(year)-\(month)-1") else { return }
            guard let lastDate = dateFormatter.date(from: "\(year+1)-1-1") else { return }
            
            let allCount = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate)
            
            guard let count = allCount.day else { return }
            allDayCount = count
        }
    }
}
