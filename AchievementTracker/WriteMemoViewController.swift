//
//  WriteMemoViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/14.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

class WriteMemoViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var inputAchievement: Achievement?
    var info: Results<DayInfo>?
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        label.textColor = UIColor.fontColor(.memo)
        // 플레이스 홀더 글자색 바꾸기
        //        textfield.attributedPlaceholder = NSAttributedString(string: "|", attributes: [NSAttributedString.Key.foregroundColor : UIColor.fontColor(.memo)])
        
        //realm
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
        navigationController?.navigationBar.topItem?.title = ""
        configNavigationBar(vcType: .inputView)
        
        // 키보드 높이를 구하기 위해 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // 키보드 높이를 구하기 위해 추가
    @objc func keyboardShow(_ noti: Notification) {
        if let keyboardRect = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardRect.height)
            
            let height = keyboardRect.height
            let doneButtonOrigin = doneButton.frame.origin.y - 36
            print("원래 origin =\(doneButtonOrigin)")
            doneButton.frame.origin.y = doneButtonOrigin - height
            
        }
        
        // 옵저버를 해제해줘야, 키보드를 맨 처음 누를 때 키보드 관련 노티피케이션이 다시 호출 안됨.
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 메모 입력 화면이 열리면, 저절로 키보드를 보여주기 위함.
        memoTextView.becomeFirstResponder()
    }
    
    /// 메모를 입력하고 done 버튼을 누르면 수행되는 액션메소드
    @IBAction func saveData(_ sender: UIButton) {
        
        do {
            try realm?.write {
                
                guard let data = info else { return }
                
                // db에서 오늘 날짜에 해당하는 데이터가 있는지 검색.
                let todayData = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", TodayDateComponent.day)
                
                // 기존에 오늘 날짜의 데이터가 있으면, 데이터를 update 해줌.
                if todayData.first != nil {
                    print("메모 화면에서 데이터 수정")
                    todayData.forEach { (originValue) in
                        originValue.year = TodayDateComponent.year
                        originValue.month = TodayDateComponent.month
                        originValue.day = TodayDateComponent.day
                        
                        guard let userAchievement = inputAchievement else { return }
                        originValue.achievement = userAchievement.rawValue
                        
                        guard let userMemo = memoTextView.text else { return }
                        originValue.memo = userMemo
                    }
                } else {
                    print("메모 화면에서 데이터 추가")
                    // 기존에 오늘 날짜의 데이터가 없으면, 새롭게 추가해줌.
                    realm?.add(inputToday(database: DayInfo(), year: TodayDateComponent.year, month: TodayDateComponent.month, day: TodayDateComponent.day ))
                    
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
        
        guard let userMemo = memoTextView.text else { return database }
        database.memo = userMemo
        
        return database
    }
}

extension WriteMemoViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("done 키를 누른건가")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("시작한건가")
        
        doneButton.titleLabel?.textColor = UIColor.fontColor(.memo)
    }
    
    // 화면을 터치하면, 키보드가 내려가도록 함.
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
}
