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
        
        print("선택된 날짜 = \(convertingDate)")
        
        testSaveInDB(clickedDate: convertingDate)
    }
    
}

extension MainViewController {
    
    /// 데이터베이스에 선택된 날짜를 저장하는 메소드
    func testSaveInDB(clickedDate: Date) {
        do{
            try realm?.write {
                realm?.add(inputData(database: DayInfo(), savingDate: clickedDate))
            }
        }catch{
            print("save error")
        }
    }
    
    /// DayInfo 타입으로 저장할 데이터를 만들어주는 메소드
    func inputData(database: DayInfo, savingDate: Date) -> DayInfo {
        database.date = savingDate
        
        return database
    }
    
}

extension MainViewController: FSCalendarDelegateAppearance {
    
    // 기본적으로 채우는 색. 즉, 여기서 DB와 날짜 매칭해서 해당 날짜에 맞는 각 컬러를 입혀줘야함. (이건 캘린더의 날짜 수만큼 수행됨.)
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let convertdate = DateFormatter()
        
        // 저장된 데이터를 읽어오기.
        guard let dbData = info else { return UIColor.clear }
        
        // 저장된 데이터에서 날짜만 뽑아서, 배열에 넣어둠.
        var savingDate: [String] = []

        convertdate.dateFormat = "yyyy-MM-dd"
        
        dbData.forEach { data in
            print("\(data.date)")
            
            // 비교를 위해 날짜값을 string으로 변환
            let dbDay = convertdate.string(from: data.date)
            
            savingDate.append(dbDay)
        }
        
        print("저장된 날짜만 뽑은 배열 \(savingDate)")
        
        // 실제 date 칸의 값에서 날짜만 가져옴.
        let calendarDay = convertdate.string(from: date)
        
        if savingDate.contains(calendarDay) {
            return #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        } else {
            return UIColor.clear
        }
        
    }
}

