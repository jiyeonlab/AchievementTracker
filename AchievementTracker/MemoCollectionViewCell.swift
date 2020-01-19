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
        
        // 사용자가 캘린더에서 어떤 날짜를 선택하는 것을 추적할 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(configMemoView(_:)), name: UserClickSomeDayNotification, object: nil)
        
        // db 검색을 위한 realm 객체
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        
        // 메모 내용을 보여주는 textview 설정
        memoContent.textColor = UIColor.lightGray
        memoContent.backgroundColor = .clear
        
        // 초기 화면에서 최근 날짜의 메모를 보여주기
        configMemoContent()
        
        // section line 설정
        sectionLine.backgroundColor = UIColor.viewBackgroundColor(.mainView)
        sectionLineWidth.constant = memoContent.bounds.width / 1.5
    }
    
    /// 초기 화면에서 오늘 데이터가 없으면, 최근 날짜의 메모를 보여주고, 오늘 데이터가 있으면, 오늘 메모를 보여주기.
    func configMemoContent() {
        // db에서 해당 날짜의 메모를 찾아서 memocontent textview에 보여주기
        guard let data = info else { return }
        
        // 오늘 데이터가 있는지 확인
        let today = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", TodayDateComponent.day)
        let yesterday = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", (TodayDateComponent.day - 1))
        
        // 오늘 데이터가 있으면, 오늘 메모를 보여줌
        if today.count != 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.M.d"
            
            cellTitle.text = dateFormatter.string(from: Date()) + " 기록"
            
            guard let todayData = today.first else { return }
            
            if todayData.memo.lengthOfBytes(using: .unicode) > 0 {
                memoContent.text = todayData.memo
                
            }else if todayData.memo.lengthOfBytes(using: .unicode) == 0{
                memoContent.text = "메모를 입력하지 않았어요"
            }
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.M.d"
            
            // 어제 날짜를 MemoCell의 titlelabel로 입력해주기 위함.
            guard let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return }
            cellTitle.text = dateFormatter.string(from: yesterdayDate) + " 기록"
            
            guard let yesterdayData = yesterday.first else { return }
            
            if yesterdayData.memo.lengthOfBytes(using: .unicode) > 0 {
                memoContent.text = yesterdayData.memo
                
            }else if yesterdayData.memo.lengthOfBytes(using: .unicode) == 0{
                memoContent.text = "메모를 입력하지 않았어요"
            }
        }
    }
    
    
    /// 사용자가 캘린더에서 어떤 날짜를 선택하면 memoview의 title 설정을 해주는 메소드
    @objc func configMemoView(_ noti: Notification) {
        
        print("메모셀의 노티피케이션을 받아 수행하는 곳")
        
        guard let clickDate = noti.object as? Date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M.d"
        
        cellTitle.text = dateFormatter.string(from: clickDate) + " 기록"
        
        // db에서 해당 날짜의 메모를 찾아서 memocontent textview에 보여주기
        guard let data = info else { return }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let clickDayComponent = Calendar.current.dateComponents([.year, .month, .day], from: clickDate)
        guard let year = clickDayComponent.year else { return }
        guard let month = clickDayComponent.month else { return }
        guard let day = clickDayComponent.day else { return }
        let clickDay = data.filter("year == %@", year).filter("month == %@", month).filter("day == %@", day)
        
        if clickDay.count != 0 {
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
