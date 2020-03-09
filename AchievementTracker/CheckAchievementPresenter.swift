//
//  Presenter.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/03/09.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

protocol CheckView: class {
    func showMessage(clickDate isFilled: Bool)
    func setAchievementView(by achievement: Achievement)
    func setEachLabel()
}

class CheckAchievementPresenter {
    private let inputDataModel: InputDataModel
    private let view: CheckView
    
    init(inputDataModel: InputDataModel, view: CheckView){
        self.inputDataModel = inputDataModel
        self.view = view
    }
    
    func searchDayInfo(what date: Date) {
        inputDataModel.searchData(what: date)
        
        if inputDataModel.userAchievement != nil {
            view.showMessage(clickDate: true)
            view.setAchievementView(by: inputDataModel.userAchievement!)
        }else{
            view.showMessage(clickDate: false)
            view.setEachLabel()
        }
    }
    
    func passByAchievement(what achievement: Achievement) {
        inputDataModel.userAchievement = achievement
    }
}
