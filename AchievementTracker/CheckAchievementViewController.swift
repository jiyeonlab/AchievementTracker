//
//  CheckAchievementViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

enum Achievement: String {
    // E-D-C-B-A 순으로 성취도 등급이 높아짐.
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
}

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
    }
    
    @IBAction func clickAchievementE(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.E
        configDoneButton()
    }
    
    @IBAction func clickAchievementD(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.D
        configDoneButton()
    }
    @IBAction func clickAchievementC(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.C
        configDoneButton()
    }
    
    @IBAction func clickAchievementB(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.B
        configDoneButton()
    }
    
    @IBAction func clickAchievementA(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.A
        configDoneButton()
    }
    
    /// 성취도 중 하나를 선택하면, 아래 done 버튼을 활성화하는 메소드
    func configDoneButton() {
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.isEnabled = true
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
