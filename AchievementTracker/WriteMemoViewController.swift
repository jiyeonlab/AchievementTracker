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
    
    var tempData: DayInfo = DayInfo()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.titleLabel?.textColor = UIColor.white
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        // 우선 지금은 오늘 날짜를 찾아서, 색깔 값에 넣어주기.
        do {
            try realm?.write {
                
                // TODO: 기존에 해당 날짜에 저장한 적이 있으면, add 말고 변경 값만 새로 저장해줘야함!!
                realm?.add(inputToday(database: DayInfo()))
            }
        }catch{
            print("save error")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputToday(database: DayInfo) -> DayInfo {
        database.year = tempData.year
        database.month = tempData.month
        database.day = tempData.day
        database.achievement = tempData.achievement
        
        guard let userMemo = textfield.text else { return database }
        database.memo = userMemo
        
        return database
    }
}
