//
//  MonthDataCenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/21.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

/// 월간 데이터를 가공하고 제공하는 싱글턴 클래스
class MonthDataCenter {
    static let shared = MonthDataCenter()
    
    var currentPage: Date?
    
    /// 월간 성취도 데이터를 나타내는 배열
    var achievementCount: [Int] = [Int]()
    
    /// 현재 캘린더 페이지의 월간 일수가 며칠인지 나타내는 변수
    var allDayCount: Int = 0
    
    private init() { }
    
    /// 현재 캘린더에 나타난 달의 월간 데이터를 계산하는 메소드
    func calculateData(currentPage date: Date) {
        
        achievementCount.removeAll()
        let realm = try? Realm()
        guard let data = realm?.objects(DayInfo.self) else { return }
        
        let dateComponent = DateComponentConverter.shared.convertDate(from: date)
        
        let thisMonth = data.filter("year == %@", dateComponent[0]).filter("month == %@", dateComponent[1])
        
        countAllDays(currentYear: dateComponent[0], currentMonth: dateComponent[1])
        
        // 선택한 달에 하나라도 데이터가 있다면.
        if thisMonth.count != 0 {
            // 각 성취도가 몇개인지 알아냄.
            let aCount = thisMonth.filter("achievement == %@", "A").count
            let bCount = thisMonth.filter("achievement == %@", "B").count
            let cCount = thisMonth.filter("achievement == %@", "C").count
            let dCount = thisMonth.filter("achievement == %@", "D").count
            let eCount = thisMonth.filter("achievement == %@", "E").count
            
            achievementCount.append(eCount)
            achievementCount.append(dCount)
            achievementCount.append(cCount)
            achievementCount.append(bCount)
            achievementCount.append(aCount)
            
        }else{  // 선택한 달에 데이터가 하나도 없다면. 성취도 배열에 전부 0을 넣어줌
            achievementCount = [0, 0, 0, 0, 0]
        }
        
    }
    
    // 현재 캘린더 페이지에 나오는 년, 월의 총 날짜 수를 계산하는 메소드.
    func countAllDays(currentYear year: Int, currentMonth month: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 해당 월의 첫번째 날.
        guard let firstDate = dateFormatter.date(from: "\(year)-\(month)-1") else { return }
        
        // 현재 달이 12월이 아니라면.
        if month != 12 {
            // 해당 월의 마지막 날.
            guard let lastDate = dateFormatter.date(from: "\(year)-\(month+1)-1") else { return }
            
            let allCount = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate)
            
            guard let count = allCount.day else { return }
            allDayCount = count
        } else {
            // 해당 월의 마지막 날.
            guard let lastDate = dateFormatter.date(from: "\(year+1)-1-1") else { return }
            
            let allCount = Calendar.current.dateComponents([.day], from: firstDate, to: lastDate)
            
            guard let count = allCount.day else { return }
            allDayCount = count
        }
    }
}
