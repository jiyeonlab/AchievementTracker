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
    
    // notification token
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        
        mainCalendar.dataSource = self
        mainCalendar.delegate = self
        
        configCalendar()
        
        // realm 추가
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        print("realm 경로 = \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        receiveRealmNotification()
    }
    
    /// navigation bar 설정 (VC의 배경을 넓힌 효과를 주기 위해)
    func configNavigationBar() {
        
        let showingYear = Calendar.current.dateComponents([.year], from: mainCalendar.currentPage)
        print("현재 달력의 year = \(showingYear)")
        guard let yearString = showingYear.year?.description else { return }
        
        navigationItem.title = yearString
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.158882767, green: 0.1719311476, blue: 0.2238469422, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    /// 캘린더의 각종 초기 셋팅을 해주는 메소드
    func configCalendar() {
        // 캘린더 스크롤 방향
        mainCalendar.scrollDirection = .horizontal
        
        // 원 말고 사각형으로 표시
        mainCalendar.appearance.borderRadius = Config.Appearance.dayBorderRadius
        
        // Month 폰트 설정
        mainCalendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: Config.FontSize.monthFontSize)
        
        // day 폰트 설정
        mainCalendar.appearance.titleFont = UIFont.boldSystemFont(ofSize: Config.FontSize.dayFontSize)
        
        // 해당 Month의 날짜만 표시되도록 설정
        mainCalendar.placeholderType = .none
        
        // MON -> M으로 표시
        mainCalendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        
        // 이전달, 다음달 표시의 알파값 조정
        mainCalendar.appearance.headerMinimumDissolvedAlpha = Config.Appearance.headerAlpha
        
        // 요일 표시 text 색 바꾸기
        for weekday in mainCalendar.calendarWeekdayView.weekdayLabels {
            weekday.textColor = UIColor.fontColor(.weekday)
            weekday.font = UIFont.boldSystemFont(ofSize: Config.FontSize.weekdayFontSize)
        }
        
        // 오늘 날짜의 titlecolor
        mainCalendar.appearance.titleTodayColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    }
    
    /// realm 의 notification을 받는 곳
    func receiveRealmNotification() {
        print("receive realm noti func()")
        
        guard let data = info else { return }
        
        let today = Date()
        let todayComponent = Calendar.current.dateComponents([.year, .month, .day], from: today)
        
        guard let year = todayComponent.year, let month = todayComponent.month, let day = todayComponent.day else { return }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let thisDay = data.filter("year == %@", year).filter("month == %@", month).filter("day == %@", day)
        
        token = thisDay.observe({ (changes: RealmCollectionChange) in
            print("in token ")
            
            switch changes {
            case .error(let error):
                print("noti error \(error)")
            case .initial:
                print("noti init")
            case .update(_, let deletions, let insertions, let modifications):
                print("noti update \(deletions) \(insertions) \(modifications)")
                
                guard let todayCell = self.mainCalendar.cell(for: today, at: .current) else { return }
                
                // 데이터를 수정할 수 있는 '오늘'에 해당하는 cell만 reload 하도록!
                if let index = self.mainCalendar.collectionView.indexPath(for: todayCell){
                    self.mainCalendar.collectionView.reloadItems(at: [index])
                }
            }
        })
    }
    
    deinit {
        token?.invalidate()
    }
}

extension MainViewController: FSCalendarDataSource {
    
}

extension MainViewController: FSCalendarDelegate {
    
    // 캘린더 페이지가 바뀌면 호출되는 메소드
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("calendar did change! ")
        
        // navigation bar에 현재 달력의 년도를 보여주기위해.
        let showingYear = Calendar.current.dateComponents([.year], from: mainCalendar.currentPage)
        print("현재 달력의 year = \(showingYear)")
        
        guard let yearString = showingYear.year?.description else { return }
        
        navigationItem.title = yearString
    }
    
    // 날짜가 선택되면 호출되는 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜 변환 해줘야 함. (UTC -> locale)
        
    }
    
}

extension MainViewController: FSCalendarDelegateAppearance {
    
    // 기본적으로 채우는 색. 즉, 여기서 DB와 날짜 매칭해서 해당 날짜에 맞는 각 컬러를 입혀줘야함. (이건 캘린더의 날짜 수만큼 수행됨.). calendarCurrentPageDidChange호출 후, 여기로 옴.
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        guard let data = info else { return UIColor.red}
        
        let convertDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let year = convertDate.year, let month = convertDate.month, let day = convertDate.day else { return UIColor.clear }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let thisDay = data.filter("year == %@", year).filter("month == %@", month).filter("day == %@", day)
        
        if thisDay.first != nil {
            print("해당 날짜가 있음 \(day)")
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
    
    // 각 날짜의 border color 설정. 옅은 회색을 줘서, 칸처럼 보이게.
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        print("222")
        let now = Date()
        let today = Calendar.current.dateComponents([.year, .month, .day], from: now)
        let cellDay = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        if today.year == cellDay.year && today.month == cellDay.month && today.day == cellDay.day {
            return .clear
        }else {
            return #colorLiteral(red: 0.2229849696, green: 0.2271204591, blue: 0.2532250583, alpha: 1)
        }
    }
    
    // 각 날짜가 찍히는 위치를 cell의 중간으로 조정하기 위해.
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {

        let now = Date()
        let today = Calendar.current.dateComponents([.year, .month, .day], from: now)
        let cellDay = Calendar.current.dateComponents([.year, .month, .day], from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)

        // 오늘 날짜에는 날짜 대신 "Today" 가 찍히도록 함.
        if today.year == cellDay.year && today.month == cellDay.month && today.day == cellDay.day {
            print("투데이 title")

            return "TODAY"
        }else {
            return day
        }
    }
}
