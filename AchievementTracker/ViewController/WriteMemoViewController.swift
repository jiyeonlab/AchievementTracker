//
//  WriteMemoViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/14.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

// 메모 입력 화면을 구성하는 클래스
class WriteMemoViewController: UIViewController {
    
    // MARK: - IBOutlet
    /// 사용자가 메모를 입력하기 위한 textView
    @IBOutlet weak var memoTextView: UITextView!
    
    // MARK: - Variable
    /// 성취도 입력 화면으로부터 사용자가 선택한 성취도 값을 받기 위한 변수
    var inputAchievement: Achievement?
    
    var info: Results<DayInfo>?
    var realm: Realm?
    
    var userClickDate: Date?
    
    var isToday = false
    
    // MARK: - View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
                
        //realm 객체
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
        navigationController?.navigationBar.topItem?.title = ""
        configNavigationBar(vcType: .inputView)
        
        configToolBar()
        
        memoTextView.textColor = UIColor.fontColor(.memo)
        
        configMemoContent()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 메모 입력 화면이 열리면, 저절로 키보드를 보여주기 위함.
        memoTextView.becomeFirstResponder()
    }
    
    // MARK: - Method
    
    func configMemoContent() {
        
        guard let data = info else { return }
        
        if userClickDate == nil {
            isToday = true
            
            // 오늘 데이터가 있는지 확인
            let today = data.filter("year == %@", TodayDateCenter.shared.year).filter("month == %@", TodayDateCenter.shared.month).filter("day == %@", TodayDateCenter.shared.day)
            
            // 기존에 입력한 메모가 있으면, memoview에 보여줌.
            if today.first?.memo.count != 0 {
                memoTextView.text = today.first?.memo
            }else{
                return
            }
        }else{
            isToday = false
            
            guard let userClickDate = userClickDate else {
                return
            }
            let dateInfo = DateComponentConverter.shared.convertDate(from: userClickDate)
            let clickDate = data.filter("year == %@", dateInfo[0]).filter("month == %@", dateInfo[1]).filter("day == %@", dateInfo[2])
            
            if clickDate.first?.memo.count != 0 {
                print("기존 메모가 있음")
                memoTextView.text = clickDate.first?.memo
            }else{
                print("기존 메모가 없음")
                return
            }
        }
        
    }
    
    /// 키보드 상단에 UIBar를 붙이고, 오른쪽에 done 버튼을 추가. toolbar의 색상을 view의 배경색과 일치시키는 메소드.
    func configToolBar() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.tintColor = .white
        toolBar.barTintColor = UIColor.viewBackgroundColor(.inputView)
        toolBar.isTranslucent = false
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveData(_:)))
        toolBar.setItems([space, doneButton], animated: false)
        
        memoTextView.inputAccessoryView = toolBar
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "NanumBarunpen", size: 18.0) as Any], for: .normal)
    }
    
    /// 사용자가 입력한 메모 내용을 저장하는 메소드
    @objc func saveData(_ sender: Any){
        
        do {
            try realm?.write {
                
                guard let data = info else { return }
                
                if isToday {
                    print("+ 버튼으로 선택해서 메모저장할 경우 \(inputAchievement)")
                    // db에서 오늘 날짜에 해당하는 데이터가 있는지 검색.
                    let todayData = data.filter("year == %@", TodayDateCenter.shared.year).filter("month == %@", TodayDateCenter.shared.month).filter("day == %@", TodayDateCenter.shared.day)
                    
                    // 기존에 오늘 날짜의 데이터가 있으면, 데이터를 update 해줌.
                    if todayData.first != nil {
                        print("메모 화면에서 데이터 수정")
                        todayData.forEach { (originValue) in
                            originValue.year = TodayDateCenter.shared.year
                            originValue.month = TodayDateCenter.shared.month
                            originValue.day = TodayDateCenter.shared.day
                            
                            guard let userAchievement = inputAchievement else { return }
                            originValue.achievement = userAchievement.rawValue
                            
                            guard let userMemo = memoTextView.text else { return }
                            originValue.memo = userMemo
                        }
                    } else {
                        print("메모 화면에서 데이터 추가")
                        // 기존에 오늘 날짜의 데이터가 없으면, 새롭게 추가해줌.
                        realm?.add(inputToday(database: DayInfo(), year: TodayDateCenter.shared.year, month: TodayDateCenter.shared.month, day: TodayDateCenter.shared.day ))
                        
                    }
                }else{
                    print("메모셀에서 선택해서 메모저장할 경우 \(inputAchievement)")
                    guard let userClickDate = userClickDate else {
                        return
                    }
                    let dateInfo = DateComponentConverter.shared.convertDate(from: userClickDate)
                    let clickDate = data.filter("year == %@", dateInfo[0]).filter("month == %@", dateInfo[1]).filter("day == %@", dateInfo[2])
                    
                    if clickDate.first != nil {
                        print("메모 화면에서 데이터 수정")
                        clickDate.forEach { (originValue) in
                            
                            originValue.year = dateInfo[0]
                            originValue.month = dateInfo[1]
                            originValue.day = dateInfo[2]
                            
                            guard let userAchievement = inputAchievement else { return }
                            originValue.achievement = userAchievement.rawValue
                            
                            print("userMemo")
                            guard let userMemo = memoTextView.text else { return }
                            originValue.memo = userMemo
                            
                            print("여기까지 안오는건가")
                        }
                    }else{
                        print("메모 화면에서 데이터 추가")
                        realm?.add(inputToday(database: DayInfo(), year: dateInfo[0], month: dateInfo[1], day: dateInfo[2]))
                    }
                }
                
            }
        }catch{
            print("save error")
            self.showErrorAlert()
        }
        
        dismiss(animated: true) {
            // 메모 입력까지 하고나면, MemoCell을 reload해주고, 화면의 중간으로 오도록 함.
            if self.isToday {
                 NotificationCenter.default.post(name: UserClickSomeDayNotification, object: Date())
            }else{
                guard let date = self.userClickDate else { return }
                NotificationCenter.default.post(name: UserClickSomeDayNotification, object: date)
            }
           
            NotificationCenter.default.post(name: CenterToMemoCellNotification, object: nil)
        }
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

// MARK: - UITextViewDelegate

extension WriteMemoViewController: UITextViewDelegate {
    
    // 메모 textfield의 글자 수를 250자로 제한하기 위해 추가.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let content = textView.text else { return true }
        
        let limitedLength = content.count + text.count - range.length
        
        print("length =\(limitedLength)")
        return limitedLength <= 250
    }
}
