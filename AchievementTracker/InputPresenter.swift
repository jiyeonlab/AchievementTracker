//
//  InputPresenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/03/09.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import RealmSwift

protocol CheckAchievementView: class {
    func displaySelectedEffect(where view: Int)
    func displayMessage(is filled: Bool)
    func setAchievementLabel()
}

// 성취도 입력을 위한 Presenter
class InputPresenter {
    let model: InputModel
    weak private var view: CheckAchievementView?
    
    init(model: InputModel){
        self.model = model
    }
    
    func attachView(view: CheckAchievementView?) {
        self.view = view
    }
    
    func selectedAchievement(selected achievement: Achievement){
  
        model.userAchievement = achievement
        view?.displaySelectedEffect(where: model.convertValue())
        
    }
    
    func getIsToday(clicked date: Date) {
        print("presenter - getIsToday()")
        guard let clickDayInfo = model.checkTodayData(clicked: date) else { return }
        
        print("clickDayInfo.count = \(clickDayInfo.count)")
        if clickDayInfo.count == 0 {
            print("clickDayInfo.count == 0")
            view?.displayMessage(is: true)
            view?.setAchievementLabel()

        }else{
            print("clickDayInfo.count != 0")

            view?.displayMessage(is: false)
            view?.displaySelectedEffect(where: model.convertValue())

        }
    }
}
