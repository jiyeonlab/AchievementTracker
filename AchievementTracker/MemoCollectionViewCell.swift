//
//  MemoCollectionViewCell.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/18.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

class MemoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var memoView: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var memoContent: UITextView!
    @IBOutlet weak var sectionLine: UIView!
    @IBOutlet weak var sectionLineWidth: NSLayoutConstraint!
    
    var info: Results<DayInfo>?
    var realm: Realm?
    
    static let identifier = "MemoCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // cell의 bgcolor
        memoView.backgroundColor = UIColor.viewBackgroundColor(.subView)
        
        // cell의 모양 잡아주기
        memoView.layer.cornerRadius = 15
        memoView.layer.borderColor = UIColor.borderColor().cgColor
        memoView.layer.borderWidth = 2
        memoView.layer.masksToBounds = true
        
        // cell의 title 설정
        cellTitle.text = TodayDateComponent.year.description + "." + TodayDateComponent.month.description + "." + TodayDateComponent.day.description + " 기록"
        
        // db 검색을 위한 realm 객체
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
        // 메모 내용을 보여주는 textview 설정
        memoContent.textColor = UIColor.lightGray
        memoContent.backgroundColor = .clear
        
        // 초기 로드 시, 오늘 날짜의 메모를 보여주기.
        let today = Date()
        configMemoView(today)
        
        // 사용자가 캘린더에서 어떤 날짜를 선택하는 것을 추적할 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(configMemoView(_:)), name: UserClickSomeDayNotification, object: nil)
        
        // section line 설정
        sectionLineWidth.constant = memoContent.bounds.width / 1.5
    }
    
    /// 사용자가 캘린더에서 어떤 날짜를 선택하면 memoview의 title 설정을 해주는 메소드
    @objc func configMemoView(_ sender: Any) {
        
        var clickDate = Date()
        
        if let noti = sender as? Notification { // 특정 날짜를 클릭하여, 노티피케이션 옵저버의 호출로 실행되었을 경우.
            guard let receivedDate = noti.object as? Date else { return }
            clickDate = receivedDate
        }else if let today = sender as? Date {  // 초기 로드 시, viewDidLoad()에서 호출되었을 경우.
            clickDate = today
        }
        
        // db에서 해당 날짜의 메모를 찾아서 memocontent textview에 보여주기
        guard let data = info else { return }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let clickDayComponent = Calendar.current.dateComponents([.year, .month, .day], from: clickDate)
        guard let year = clickDayComponent.year else { return }
        guard let month = clickDayComponent.month else { return }
        guard let day = clickDayComponent.day else { return }
        let clickDay = data.filter("year == %@", year).filter("month == %@", month).filter("day == %@", day)
        
        // 메모 cell의 title
        cellTitle.text = "\(year).\(month).\(day) 기록"
        
        if clickDay.count != 0 {    // clickDay는 초기 실행 시는 today이고, 특정 날짜 선택 시 호출될 때는 특정 날짜 date임.
            guard let clickDayInfo = clickDay.first else { return }
            
            if clickDayInfo.memo.lengthOfBytes(using: .unicode) > 0 {
                memoContent.text = clickDayInfo.memo
                
            }else if clickDayInfo.memo.lengthOfBytes(using: .unicode) == 0{
                memoContent.text = "메모를 입력하지 않았어요"
            }
            
            // section line에 해당하는 uiview의 bgColor를 입혀줌.
            switch clickDayInfo.achievement {
            case "A":
                sectionLine.backgroundColor = UIColor.achievementColor(.A)
            case "B":
                sectionLine.backgroundColor = UIColor.achievementColor(.B)
            case "C":
                sectionLine.backgroundColor = UIColor.achievementColor(.C)
            case "D":
                sectionLine.backgroundColor = UIColor.achievementColor(.D)
            case "E":
                sectionLine.backgroundColor = UIColor.achievementColor(.E)
            default:
                sectionLine.backgroundColor = UIColor.clear
            }
        }else{
            memoContent.text = "기록을 하지 않았어요"
            sectionLine.backgroundColor = UIColor.viewBackgroundColor(.mainView)
        }
        
    }
    
}
