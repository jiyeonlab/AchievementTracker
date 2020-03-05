//
//  String+Extensions.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/03/05.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
