//
//  WriteMemoViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/14.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

class WriteMemoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var inputAchievement: Achievement?
    var info: Results<DayInfo>?
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfield.delegate = self
        
        // 플레이스 홀더 글자색 바꾸기
        textfield.attributedPlaceholder = NSAttributedString(string: "더 적어볼래요?", attributes: [NSAttributedString.Key.foregroundColor : UIColor.fontColor(.memo)])
        
        //realm
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
    }
    
    // textfield를 수정할 때 호출.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.titleLabel?.textColor = UIColor.fontColor(.memo)
    }
    
    /// 메모를 입력하고 done 버튼을 누르면 수행되는 액션메소드
    @IBAction func saveData(_ sender: UIButton) {
        
        do {
            try realm?.write {

                guard let data = info else { return }
                
                // 오늘 날짜 구하기
                let now = Date()
                let convertDate = Calendar.current.dateComponents([.year, .month, .day], from: now)

                guard let currentYear = convertDate.year, let currentMonth = convertDate.month, let currentDay = convertDate.day else { return }

                // db에서 오늘 날짜에 해당하는 데이터가 있는지 검색.
                let todayData = data.filter("year == %@", currentYear).filter("month == %@", currentMonth).filter("day == %@", currentDay)

                // 기존에 오늘 날짜의 데이터가 있으면, 데이터를 update 해줌.
                if todayData.first != nil {
                    print("메모 화면에서 데이터 수정")
                    todayData.forEach { (originValue) in
                        originValue.year = currentYear
                        originValue.month = currentMonth
                        originValue.day = currentDay

                        guard let userAchievement = inputAchievement else { return }
                        originValue.achievement = userAchievement.rawValue

                        guard let userMemo = textfield.text else { return }
                        originValue.memo = userMemo
                    }
                } else {
                    print("메모 화면에서 데이터 추가")
                    // 기존에 오늘 날짜의 데이터가 없으면, 새롭게 추가해줌.
                    realm?.add(inputToday(database: DayInfo(), year: currentYear, month: currentMonth, day: currentDay ))
                    
                }
            }
        }catch{
            print("save error")
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputToday(database: DayInfo, year: Int, month: Int, day: Int) -> DayInfo {
        
        guard let achievement = inputAchievement else { return DayInfo() }
        
        database.year = year
        database.month = month
        database.day = day
        database.achievement = achievement.rawValue
        
        guard let userMemo = textfield.text else { return database }
        database.memo = userMemo
        
        return database
    }
}
