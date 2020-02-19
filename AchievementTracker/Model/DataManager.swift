//
//  DataCenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/02/18.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    static let shared = DataManager()
    var dayInfo: Results<DayInfo>?
    var realm: Realm?
    
    /// realm의 변화를 실시간으로 알아내기 위한 Notification Token
    var notificationToken: NotificationToken?
    
    init() {
        realm = try? Realm()
        dayInfo = realm?.objects(DayInfo.self)
        print("realm 경로 = \(Realm.Configuration.defaultConfiguration.fileURL!)")
        self.receiveRealmNotification(what: nil)
    }
    
    /// Realm 의 Notification을 받아, DB의 변화에 따른 일을 처리하는 메소드
    func receiveRealmNotification(what date: Date?) {
        
        guard let data = dayInfo else { return }
        guard let observingDate = date else { return }
        
        MonthDataCenter.shared.calculateData(currentPage: observingDate)
        
        // subview의 월간 기록 그래프를 새로 그려달라는 노티피케이션 보냄.
        NotificationCenter.default.post(name: ReloadGraphViewNotification, object: nil)
        
        // Realm의 변화를 실시간으로 받는 곳.
        notificationToken = data.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            case .error(let error):
                print("noti error \(error)")
            //                self.showErrorAlert()
            case .initial:
                print("noti init")
            case .update(_, let deletions, let insertions, let modifications):
                print("noti update \(deletions) \(insertions) \(modifications)")
                
                // '오늘' 데이터 수정에 따라 월간 기록 데이터를 다시 계산하고, 그래프를 다시 그려줌.
                MonthDataCenter.shared.calculateData(currentPage: observingDate)
                NotificationCenter.default.post(name: ReloadGraphViewNotification, object: nil)
            }
        })
    }
    
    // ViewController에서 데이터 검색을 요청하는 메소드
    func filterObject(what date: Date) -> Results<DayInfo>? {
        
        guard let data = dayInfo else { return nil }
        
        let date = DateComponentConverter.shared.convertDate(from: date)
        
        let object = data.filter("year == %@", date[0]).filter("month == %@", date[1]).filter("day == %@", date[2])
        
        return object
    }
    
    /// realm에 데이터를 쓰는 메소드
    func writeMemo(on userClickDate: Date, with inputAchievement: Achievement, what userMemo: String, completion: ()->Void) {
        do {
            try realm?.write {
                
                guard let clickDate = filterObject(what: userClickDate) else { return }
                
                let dateInfo = DateComponentConverter.shared.convertDate(from: userClickDate)
                
                if clickDate.first != nil {
                    clickDate.forEach { (originValue) in
                        
                        originValue.year = dateInfo[0]
                        originValue.month = dateInfo[1]
                        originValue.day = dateInfo[2]
                        
                        originValue.achievement = inputAchievement.rawValue
                        
                        originValue.memo = userMemo
                    }
                }else{
                    realm?.add(inputToday(database: DayInfo(), year: dateInfo[0], month: dateInfo[1], day: dateInfo[2], achievement: inputAchievement, memo: userMemo))
                }
                
            }
        }catch{
            print("save error")
//            self.showErrorAlert()
        }
        
        completion()
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputToday(database: DayInfo, year: Int, month: Int, day: Int, achievement: Achievement, memo: String) -> DayInfo {
                
        database.year = year
        database.month = month
        database.day = day
        database.achievement = achievement.rawValue
        database.memo = memo
        
        return database
    }
    
    deinit {
        // Realm을 실시간으로 구독하는 notificationToken을 해제해줌.
        notificationToken?.invalidate()
    }
}
