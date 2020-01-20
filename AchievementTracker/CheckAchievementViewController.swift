//
//  CheckAchievementViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

class CheckAchievementViewController: UIViewController {
    
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var achievementE: UIView!
    @IBOutlet weak var achievementD: UIView!
    @IBOutlet weak var achievementC: UIView!
    @IBOutlet weak var achievementB: UIView!
    @IBOutlet weak var achievementA: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    // realm
    var info: Results<DayInfo>?
    var realm: Realm?
    
    // 사용자가 선택한 성취도 값
    var userAchievement: Achievement?
    
    /// 성취도 선택을 여러번 할 경우를 위해 마지막으로 누른 view를 저장해둘 변수
    var lastSelectedView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오늘 날짜를 label에 입력.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let now = Date()
        let dateString = dateFormatter.string(from: now)
        todayDateLabel.text = dateString
        
        // 성취도를 선택하기 전에는 done 버튼 비활성화.
        doneButton.isEnabled = false
        
        //realm
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
        configNavigationBar(vcType: .inputView)
        
        configMessage()
        
        // donebutton의 초기 이미지 셋팅
//        doneButton.setImage(UIImage(named: "unchecked"), for: .normal)
        
        // 성취도 칸의 모양 다듬기
        achievementA.layer.cornerRadius = Config.Appearance.achievementRadius
        achievementB.layer.cornerRadius = Config.Appearance.achievementRadius
        achievementC.layer.cornerRadius = Config.Appearance.achievementRadius
        achievementD.layer.cornerRadius = Config.Appearance.achievementRadius
        achievementE.layer.cornerRadius = Config.Appearance.achievementRadius

    }
    
    @IBAction func clickAchievementE(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.E
        
        configDoneButton()
        configSelectEffect(what: achievementE)
    }
    
    @IBAction func clickAchievementD(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.D
        
        configDoneButton()
        configSelectEffect(what: achievementD)
    }
    @IBAction func clickAchievementC(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.C
        
        configDoneButton()
        configSelectEffect(what: achievementC)
    }
    
    @IBAction func clickAchievementB(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.B
        
        configDoneButton()
        configSelectEffect(what: achievementB)
    }
    
    @IBAction func clickAchievementA(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.A
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.isEnabled = true
        configDoneButton()
        configSelectEffect(what: achievementA)
    }
    
    /// 성취도 중 하나를 선택하면, 아래 done 버튼을 활성화하는 메소드
    func configDoneButton() {
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.isEnabled = true
    }
    
    /// 선택한 성취도 칸의 효과를 주기 위한 메소드
    func configSelectEffect(what achievementView: UIView) {
        // 기존에 눌린 view의 효과를 끄기
        lastSelectedView?.subviews.first?.tintColor = UIColor.clear
        
        // 지금 눌린 view에 효과를 줌
        achievementView.subviews.first?.tintColor = UIColor.viewBackgroundColor(.inputView)
        
        lastSelectedView = achievementView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("메모 입력 화면으로 넘어감")
        
        guard let nextVC = segue.destination as? WriteMemoViewController else {
            return
        }
        
        // 사용자가 입력한 성취도 값을 WriteMemoVC로 전달함.
        nextVC.inputAchievement = userAchievement
    }
    
    /// 오늘 데이터 입력이 처음이면 "check ~"로, 오늘 데이터를 수정하는 거면 "change ~"로 메시지를 바꾸는 메소드
    func configMessage() {
        guard let data = info else { return }
        
        // 오늘 데이터가 있는지 확인
        let today = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", TodayDateComponent.day)
        
        // 오늘 데이터가 있으면
        if today.count != 0 {
            messageLabel.text = "오늘의 성취도를 수정해보세요!"
        }else{
            messageLabel.text = "오늘의 성취도를 입력해보세요!"
        }
    }
}
