//
//  DateComponent.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/02/03.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

// 여러 곳에서 쓰이는 datecomponent 가공을 한 곳에서 하기 위해 추가한 싱글턴 클래스.
class DateComponentConverter {
    static let shared = DateComponentConverter()
    
    func convertDate(from date: Date) -> [Int] {

        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let year = dateComponent.year, let month = dateComponent.month, let day = dateComponent.day else { return [0] }
        
        return [year, month, day]
        
    }
}
