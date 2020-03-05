//
//  CheckAchievementViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

// 성취도 입력 화면을 구성하는 클래스
class CheckAchievementViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    /// 오늘 날짜를 표시하기 위한 label
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var achievementLabel: [UILabel]!
    @IBOutlet var achievementView: [UIView]!

    // MARK: - Variable
    
    /// 사용자가 선택한 성취도 값을 저장하고 있는 변수
    var userAchievement: Achievement?
    
    /// 성취도 선택을 여러번 할 경우를 위해 마지막으로 누른 view를 저장해둘 변수
    var lastSelectedView: UIView?
    
    /// MainVC로 부터 받은 Memocell에 선택되어있는 날짜
    var showingDate: Date?
    
    // MARK: - View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()

        configDateLabel()
        
        // 성취도를 선택하기 전에는 done 버튼 비활성화해둠.
        doneButton.isEnabled = false
        
        configNavigationBar(vcType: .inputView)
        
        configMessage()

        configAppearance()
    }
    
    // MARK: - IBAction
    
    /// 성취도 0~20%에 해당하는 E 버튼을 눌렀을 경우.
    @IBAction func clickAchievementE(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.E
        
        configDoneButton()
        configSelectEffect(what: achievementView[0])
    }
    
    /// 성취도 20~40%에 해당하는 D 버튼을 눌렀을 경우.
    @IBAction func clickAchievementD(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.D
        
        configDoneButton()
        configSelectEffect(what: achievementView[1])
    }
    
    /// 성취도 40~60%에 해당하는 C 버튼을 눌렀을 경우.
    @IBAction func clickAchievementC(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.C
        
        configDoneButton()
        configSelectEffect(what: achievementView[2])
    }
    
    /// 성취도 60~80%에 해당하는 B 버튼을 눌렀을 경우.
    @IBAction func clickAchievementB(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.B
        
        configDoneButton()
        configSelectEffect(what: achievementView[3])
    }
    
    /// 성취도 80~100%에 해당하는 A 버튼을 눌렀을 경우.
    @IBAction func clickAchievementA(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.A
        
        configDoneButton()
        configSelectEffect(what: achievementView[4])
    }
    
    // MARK: - Method
    
    /// 성취도 버튼의 모양 다듬기 메소드
    func configAppearance() {
        achievementView.forEach { view in
            view.layer.cornerRadius = Config.Appearance.achievementRadius
        }
    }
    
    func configDateLabel() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.locale = Locale.current
        
        guard let userClickDate = showingDate else { return }
        let dateString = dateFormatter.string(from: userClickDate)
        todayDateLabel.text = dateString
    }
    
    /// 성취도 중 하나를 선택하면, 아래 done 버튼을 활성화하는 메소드
    func configDoneButton() {
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.isEnabled = true
    }
    
    /// 선택한 성취도 칸에 선택했다는 효과를 보여주기 위한 메소드
    func configSelectEffect(what achievementView: UIView) {
        
        // 성취도 label을 없앰.
        achievementLabel.forEach { label in
            label.textColor = UIColor.clear
        }
        
        // 기존에 눌린 view의 효과를 끄기
        lastSelectedView?.subviews.first?.tintColor = UIColor.clear
        
        // 지금 눌린 view에 효과를 줌
        achievementView.subviews.first?.tintColor = UIColor.viewBackgroundColor(.inputView)
        
        // 지금 누른 view를 저장해둠.
        lastSelectedView = achievementView
    }
    
    /// 오늘 데이터 입력이 처음이면 "check ~"로, 오늘 데이터를 수정하는 거면 "change ~"로 메시지를 바꾸는 메소드
    func configMessage() {
        
        guard let userClickDate = showingDate else { return }
        
        guard let clickDate = DataManager.shared.filterObject(what: userClickDate) else { return }
        
        // Date()자체를 비교하면, 오차가 있어서 원하는 경우대로 안됨. DateFormatter이용하여, string을 비교.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let today = dateFormatter.string(from: Date())
        let clickDay = dateFormatter.string(from: userClickDate)
        
        if clickDay == today && clickDate.count == 0 {
//            messageLabel.text = "오늘의 성취도를 입력하세요!"
            messageLabel.text = "message1".localized
            configAchievementView(for: .empty, from: clickDate)
        }else if clickDay == today && clickDate.count != 0{
            messageLabel.text = "message2".localized
            configAchievementView(for: .fill, from: clickDate)
        }else if clickDay != today && clickDate.count == 0 {
            messageLabel.text = "message3".localized
            configAchievementView(for: .empty, from: clickDate)
        }else if clickDay != today && clickDate.count != 0 {
            messageLabel.text = "message4".localized
            configAchievementView(for: .fill, from: clickDate)
        }
        
    }
    
    /// 경우에 따른 성취도 uiview를 셋팅하기 위한 메소드
    func configAchievementView(for state: AchievementState, from dayInfo: Results<DayInfo> ) {
        switch state {
        case .fill:
            
            // 기존에 선택한 성취도 정보를 성취도 버튼에 표시해줌.
            guard let achievement = dayInfo.first?.achievement else { return }
            switch achievement {
            case "A":
                configSelectEffect(what: achievementView[4])
                userAchievement = Achievement.A
            case "B":
                configSelectEffect(what: achievementView[3])
                userAchievement = Achievement.B
            case "C":
                configSelectEffect(what: achievementView[2])
                userAchievement = Achievement.C
            case "D":
                configSelectEffect(what: achievementView[1])
                userAchievement = Achievement.D
            case "E":
                configSelectEffect(what: achievementView[0])
                userAchievement = Achievement.E
            default:
                return
            }
            
            configDoneButton()
        case .empty:
            // 성취도를 선택한 적이 없다면, 각 성취도 버튼에 % label을 띄워줌.
            achievementLabel.forEach { label in
                label.textColor = UIColor.viewBackgroundColor(.inputView)
            }
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nextVC = segue.destination as? WriteMemoViewController else {
            return
        }
        
        // 사용자가 입력한 성취도 값을 WriteMemoVC로 전달함.
        nextVC.inputAchievement = userAchievement
        
        if showingDate != nil {
            nextVC.selectedDate = showingDate
        }else{
            return
        }
    }
}
