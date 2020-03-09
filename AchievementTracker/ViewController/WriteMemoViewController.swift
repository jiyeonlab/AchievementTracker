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
class WriteMemoViewController: UIViewController, MemoView {
   
    // MARK: - IBOutlet
    /// 사용자가 메모를 입력하기 위한 textView
    @IBOutlet weak var memoTextView: UITextView!
    
    // MARK: - Variable
    /// 성취도 입력 화면으로부터 사용자가 선택한 성취도 값을 받기 위한 변수
    var inputAchievement: Achievement?
    var inputModel: InputDataModel?
    var presenter: WriteMemoPresenter?
    
    var selectedDate: Date?
    
    // MARK: - View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
        memoTextView.delegate = self
        
        navigationController?.navigationBar.topItem?.title = ""
        configNavigationBar(vcType: .inputView)
        
        configToolBar()
        
        memoTextView.textColor = UIColor.fontColor(.memo)
        
        configMemoContent()

    }
    
    func initialize() {
        presenter = WriteMemoPresenter(inputDataModel: inputModel!, view: self)
        presenter?.receiveAchievement()
    }
    
    func matchingValue(with value: Achievement) {
        print("앞에서 온 성취도 값 = \(value)")
        
        inputAchievement = value
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 메모 입력 화면이 열리면, 저절로 키보드를 보여주기 위함.
        memoTextView.becomeFirstResponder()
    }
    
    // MARK: - Method
    
    /// 메모 내용이 들어가는 TextView에 해당 날짜의 메모 여부에 따라 초기 셋팅하는 메소드
    func configMemoContent() {
                
        guard let userClickDate = selectedDate else { return }
        
        presenter?.findMemo(with: userClickDate)
    }
    
    func settingMemoContent(with memo: String) {
        memoTextView.text = memo
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
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: Config.Font.normal, size: Config.FontSize.doneButton) as Any], for: .normal)
    }
    
    /// 사용자가 입력한 메모 내용을 저장하기위해 DataManger에게 요청하는 메소드
    @objc func saveData(_ sender: Any){
        
        guard let userClickDate = selectedDate else { return }
        guard let userAchievement = inputAchievement else { return }
        guard let userMemo = memoTextView.text else { return }
        
        DataManager.shared.writeMemo(on: userClickDate, with: userAchievement, what: userMemo) {
            dismiss(animated: true) {
                // 메모 입력까지 하고나면, MemoCell을 reload해주고, 화면의 중간으로 오도록 함.
                NotificationCenter.default.post(name: UserClickSomeDayNotification, object: userClickDate)
                NotificationCenter.default.post(name: CenterToMemoCellNotification, object: nil)
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension WriteMemoViewController: UITextViewDelegate {
    
    // 메모 textfield의 글자 수를 250자로 제한하기 위해 추가.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let content = textView.text else { return true }
        
        let limitedLength = content.count + text.count - range.length
        
        return limitedLength <= Config.Appearance.maximumLength
    }
}
