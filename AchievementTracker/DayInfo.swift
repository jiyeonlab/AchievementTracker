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
    @objc dynamic var date = Date()
    @objc dynamic var achievement = ""
    @objc dynamic var memo = ""
}
