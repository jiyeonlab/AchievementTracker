//
//  MainViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainCalendar: FSCalendar!
    
    // realm 추가
    var info: Results<DayInfo>?
    var realm: Realm?
    
    // 저장된 데이터에서 날짜만 뽑아서, 배열에 넣어둠.
    var savingDate: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar 설정 (VC의 배경을 넓힌 효과를 주기 위해)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.158882767, green: 0.1719311476, blue: 0.2238469422, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        mainCalendar.dataSource = self
        mainCalendar.delegate = self
        
        configCalendar()
        
        // realm 추가
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        print("realm 경로 = \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
    }
    
    /// 캘린더의 각종 초기 셋팅을 해주는 메소드
    func configCalendar() {
        // 캘린더 스크롤 방향
        mainCalendar.scrollDirection = .horizontal
        
        // 원 말고 사각형으로 표시
        mainCalendar.appearance.borderRadius = 0
        
        // Month 표시 설정
        //mainCalendar.appearance.headerTitleFont = UIFont.italicSystemFont(ofSize: 20.0)
        
        // 해당 Month의 날짜만 표시되도록 설정
        mainCalendar.placeholderType = .none
        
        // MON -> M으로 표시
        mainCalendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        // 요일 표시 text 색 바꾸기
        for weekday in mainCalendar.calendarWeekdayView.weekdayLabels {
            weekday.textColor = UIColor.fontColor(.weekday)
        }
    }
}

extension MainViewController: FSCalendarDataSource {
    
}

extension MainViewController: FSCalendarDelegate {
    
    // 캘린더 페이지가 바뀌면 호출되는 메소드
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("calendar did change!")
    }
    
    // 날짜가 선택되면 호출되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜 변환 해줘야 함. (UTC -> locale)
        let convertingDate = date.addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
        
//        let test = Calendar.current.dateComponents([.year, .month, .day], from: date)
//
//        testSaveInDB(clickedDate: test)
    }
    
}

extension MainViewController {
    
    /// 데이터베이스에 선택된 날짜를 저장하는 메소드
    func testSaveInDB(clickedDate: DateComponents) {
        do{
            try realm?.write {
                realm?.add(inputData(database: DayInfo(), savingDate: clickedDate))
            }
        }catch{
            print("save error")
        }
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputData(database: DayInfo, savingDate: DateComponents) -> DayInfo {
//        database.date = savingDate
        database.year = savingDate.year!
        database.month = savingDate.month!
        database.day = savingDate.day!
        database.achievement = Achievement.D.rawValue
        
        return database
    }
    
}

extension MainViewController: FSCalendarDelegateAppearance {
    
    // 기본적으로 채우는 색. 즉, 여기서 DB와 날짜 매칭해서 해당 날짜에 맞는 각 컬러를 입혀줘야함. (이건 캘린더의 날짜 수만큼 수행됨.). calendarCurrentPageDidChange호출 후, 여기로 옴.
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        guard let data = info else { return UIColor.red}
        
        let convertDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let yearInfo = convertDate.year!
        let month = convertDate.month!
        let day = convertDate.day!
        
        let thisDay = data.filter("year == %@", yearInfo).filter("month == %@", month).filter("day == %@", day)
       
        if thisDay.first != nil {
            print("해당 날짜가 있음")
            guard let fillDay = thisDay.first else { return UIColor.clear }
            
            switch fillDay.achievement {
            case "A":
                return UIColor.achievementColor(.A)
            case "B":
                return UIColor.achievementColor(.B)
            case "C":
                return UIColor.achievementColor(.C)
            case "D":
                return UIColor.achievementColor(.D)
            case "E":
                return UIColor.achievementColor(.E)
            default:
                return UIColor.clear
                
            }
        }else{
            return UIColor.clear
        }
        
    }
}

