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
    
    @IBOutlet weak var achievementA: UIView!
    @IBOutlet weak var achievementB: UIView!
    @IBOutlet weak var achievementC: UIView!
    @IBOutlet weak var achievementD: UIView!
    @IBOutlet weak var achievementE: UIView!
    
    // realm
    var info: Results<DayInfo>?
    var realm: Realm?
    
    // 사용자가 선택한 성취도 값
    var userAchievement = Achievement.A
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오늘 날짜를 label에 입력.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let now = Date()
        let dateString = dateFormatter.string(from: now)
        todayDateLabel.text = dateString
        
        doneButton.isEnabled = false
        
        //realm
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
    }
    
    @IBAction func clickedAchievementA(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.A
        configDoneButton()
    }
    
    @IBAction func clickedAchievementB(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.B
        configDoneButton()
    }
    @IBAction func clickedAchievementC(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.C
        configDoneButton()
    }
    
    @IBAction func clickedAchievementD(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.D
        configDoneButton()
    }
    
    @IBAction func clickedAchievementE(_ sender: UITapGestureRecognizer) {
        userAchievement = Achievement.E
        configDoneButton()
    }
    
    /// 성취도 중 하나를 선택하면, 아래 done 버튼을 활성화하는 메소드
    func configDoneButton() {
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.isEnabled = true
    }
    
    /// 하단의 done 버튼을 누르면 실행되는 액션메소드
    @IBAction func skipNextButton(_ sender: UIButton) {
        // 여기서 데이터베이스에 저장해줘야함.
        
        // 우선 지금은 오늘 날짜를 찾아서, 색깔 값에 넣어주기.
        do {
            try realm?.write {
                
                // 오늘 날짜 구하기
                let now = Date()
                let convertDate = Calendar.current.dateComponents([.year, .month, .day], from: now)
                
                // TODO: 기존에 해당 날짜에 저장한 적이 있으면, add 말고 변경 값만 새로 저장해줘야함!!
                realm?.add(inputToday(database: DayInfo(), savingDate: convertDate))
            }
        }catch{
            print("save error")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputToday(database: DayInfo, savingDate: DateComponents) -> DayInfo {
        //        database.date = savingDate
        database.year = savingDate.year!
        database.month = savingDate.month!
        database.day = savingDate.day!
        database.achievement = userAchievement.rawValue
        
        return database
    }
}
