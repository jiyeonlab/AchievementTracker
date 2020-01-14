//
//  DayInfo.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

class DayInfo: Object {
//    @objc dynamic var date = Date()
//    @objc dynamic var date = DateConvert()
    @objc dynamic var year = 0
    @objc dynamic var month = 0
    @objc dynamic var day = 0
    @objc dynamic var achievement = ""
    @objc dynamic var memo = ""
}

//class DateConvert: Object {
//    @objc dynamic var year = 0
//    @objc dynamic var month = 0
//    @objc dynamic var day = 0
//}
