//
//  MainViewController.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/13.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import FSCalendar

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainCalendar: FSCalendar!
    
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
    }
}

