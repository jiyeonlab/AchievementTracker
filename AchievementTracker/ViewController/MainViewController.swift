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

// 캘린더와 subview(월간기록, 메모)가 있는 메인 ViewController 클래스.
class MainViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mainCalendar: FSCalendar!
    
    /// 월간기록, 메모를 포함하는 collection view.
    @IBOutlet weak var subView: UICollectionView!
    
    /// customPickerView를 띄우기 위한 탭이 적용된 UIView.
    @IBOutlet weak var datePickerTapView: UIView!
    
    /// 캘린더의 높이를 비율로 정해주기 위해 추가한 constraint outlet.
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    // MARK: - Variable
    /// DayInfo 데이터 변수
    var dayInfo: Results<DayInfo>?
    
    /// Realm 변수
    var realm: Realm?
    
    /// realm의 변화를 실시간으로 알아내기 위한 Notification Token
    var notificationToken: NotificationToken?
    
    /// 사용자가 캘린더에서 어떤 날짜를 누르면,  메모 cell을 subview의 중간으로 옮기기 위한 핸들러.
    var centerToMemoCellHandler: (() -> Void)?
    
    /// 캘린더 페이지를 변경하면 월간 기록 cell을 subview의 중간으로 옯기기 위한 핸들러.
    var centerToDataCellHandler: (() -> Void)?
    
    /// 캘린더 이동을 위한 년, 월을 선택할 수 있는 Custom Picker View
    var customPickerView: UIPickerView?
    
    /// Custom Picker View에 띄울 년 목록
    var yearList = [String]()
    
    /// Custom Picker View에 띄울 월 목록
    var monthList = [String]()
    
    /// Custom Picker View에서 선택한 년
    var selectedYearIndex: Int = 0
    
    /// Custom Picker View에서 선택한 달
    var selectedMonthIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 싱글턴 클래스의 날짜 프로퍼티 초기 설정
        TodayDateCenter.shared.updateToday()
        
        mainCalendar.dataSource = self
        mainCalendar.delegate = self
        
        configNavigationBar(vcType: .mainView)
        configCalendar()
        
        // realm에서 DayInfo 객체를 가져옴
        realm = try? Realm()
        dayInfo = realm?.objects(DayInfo.self)
        print("realm 경로 = \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        receiveRealmNotification()
        
        // 화면 하단에 subView를 추가하기 위해 collectionview 추가.
        subView.dataSource = self
        subView.delegate = self
        subView.decelerationRate = .fast
        configSubview()
        
        // 날짜를 선택할 수 있는 date picker를 열기 위한 tap gesture 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDatePickerView(_:)))
        datePickerTapView.addGestureRecognizer(tapGesture)
        
        configPickerData()
        
        // 메모 입력 화면의 노티피케이션을 받기 위한 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(moveMemoCell(_:)), name: CenterToMemoCellNotification, object: nil)
        
        // 앱이 foreground로 올라오면, 캘린더를 reload 하기 위한 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCalendar(_:)), name: RefreshCalendarNotification, object: nil)
    }
    
    /// 캘린더의 각종 초기 셋팅을 위한 메소드
    func configCalendar() {
        
        // 캘린더의 높이 설정
        calendarHeight.constant = view.frame.height / Config.AspectRatio.calendarHeightRatio
        
        // 캘린더 스크롤 방향 설정
        mainCalendar.scrollDirection = .horizontal
        
        // 각 날짜를 원형 말고 사각형으로 표시
        mainCalendar.appearance.borderRadius = Config.Appearance.dayBorderRadius
        
        // Month 폰트 설정
        mainCalendar.appearance.headerTitleFont = UIFont(name: "NanumBarunpen", size: Config.FontSize.monthFontSize)
        
        // day 폰트 설정
        mainCalendar.appearance.titleFont = UIFont(name: "NanumBarunpen-Bold", size: Config.FontSize.dayFontSize)
        
        // 캘린더에 이번달 날짜만 표시하기 위함
        mainCalendar.placeholderType = .none
        
        // MON -> M으로 표시
        mainCalendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        
        // 이전달, 다음달 표시의 알파값 조정
        mainCalendar.appearance.headerMinimumDissolvedAlpha = Config.Appearance.headerAlpha
        
        // 요일 text 색 바꾸기
        for weekday in mainCalendar.calendarWeekdayView.weekdayLabels {
            weekday.textColor = UIColor.fontColor(.weekday)
            weekday.font = UIFont(name: "NanumBarunpen-Bold", size: Config.FontSize.weekdayFontSize)
        }
        
        // 오늘 날짜의 titlecolor
        mainCalendar.appearance.titleTodayColor = UIColor.fontColor(.today)
    }
    
    /// Realm 의 Notification을 받아, DB의 변화에 따른 일을 처리하는 메소드
    func receiveRealmNotification() {
        
        guard let data = dayInfo else { return }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let thisDay = data.filter("year == %@", TodayDateCenter.shared.year).filter("month == %@", TodayDateCenter.shared.month).filter("day == %@", TodayDateCenter.shared.day)
        
        MonthDataCenter.shared.calculateData(currentPage: mainCalendar.currentPage)
        
        // subview의 월간 기록 그래프를 새로 그려달라는 노티피케이션 보냄.
        NotificationCenter.default.post(name: ReloadGraphViewNotification, object: nil)
        
        // Realm의 변화를 실시간으로 받는 곳.
        notificationToken = thisDay.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            case .error(let error):
                print("noti error \(error)")
                self.showErrorAlert()
            case .initial:
                print("noti init")
            case .update(_, let deletions, let insertions, let modifications):
                print("noti update \(deletions) \(insertions) \(modifications)")
                
                guard let todayCell = self.mainCalendar.cell(for: TodayDateCenter.shared.today, at: .current) else { return }
                
                // 데이터를 수정할 수 있는 '오늘'에 해당하는 cell만 reload 하도록!
                if let index = self.mainCalendar.collectionView.indexPath(for: todayCell){
                    self.mainCalendar.collectionView.reloadItems(at: [index])
                }
                
                // '오늘' 데이터 수정에 따라 월간 기록 데이터를 다시 계산하고, 그래프를 다시 그려줌.
                MonthDataCenter.shared.calculateData(currentPage: self.mainCalendar.currentPage)
                NotificationCenter.default.post(name: ReloadGraphViewNotification, object: nil)
            }
        })
    }
    
    deinit {
        // Realm을 실시간으로 구독하는 notificationToken을 해제해줌.
        notificationToken?.invalidate()
    }
    
    /// 캘린더의 title 부분을 tap하면 datepicker를 띄우는 메소드
    @objc func selectDatePickerView(_ sender: UITapGestureRecognizer){
        
        let alertView = UIAlertController(title: "이동하려는 날짜 선택", message: nil, preferredStyle: .actionSheet)
        
        // custom으로 만든 pickerview를 actionsheet에 추가해줌.
        let datePickerView = UIViewController()
        
        configPickerView()
        datePickerView.view = customPickerView
        datePickerView.preferredContentSize.height = Config.AspectRatio.pickerViewHeight
        
        // 컨텐츠 뷰 영역에 datePickerView를 설정해줌.
        alertView.setValue(datePickerView, forKey: "contentViewController")
        
        // 이번달로 돌아가는 alertAction
        let goTodayAction = UIAlertAction(title: "이번달로 돌아가기", style: .default) { action in
            let now = Date()
            self.mainCalendar.setCurrentPage(now, animated: true)
        }
        
        // 선택한 년, 월로 이동하기 위한 alertAction
        let selectAction = UIAlertAction(title: "확인", style: .default) { action in
            
            // picker view에서 선택한 년, 월을 Date 타입으로 변환하기.
            let movingYear = self.yearList[self.selectedYearIndex]
            let movingMonth = self.monthList[self.selectedMonthIndex]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            
            let movingDate = movingYear + "-" + movingMonth
            guard let movingPage = dateFormatter.date(from: movingDate) else { return }
            
            // picker view에서 선택한 년, 월로 캘린더를 이동하기.
            self.mainCalendar.setCurrentPage(movingPage, animated: true)
        }
        alertView.addAction(goTodayAction)
        alertView.addAction(selectAction)
        
        // alertView 띄우기
        present(alertView, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertView(_:)))
            alertView.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        
    }
    
    /// actionsheet가 열려있는데, 화면의 다른 부분을 tap하면 actionsheet가 사라지게 하기 위한 메소드
    @objc func dismissAlertView(_ tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 메모입력 화면에서 done 버튼을 누르면 받는 노티피케이션을 받아 해당 핸들러를 수행하는 메소드
    @objc func moveMemoCell(_ noti: Notification){
        centerToMemoCellHandler?()
        mainCalendar.reloadData()
    }
    
    /// 앱이 background에서  foreground로 이동 시, 오늘 날짜가 바뀌었을 수도 있기 때문에 캘린더를 reload 해주기 위한 메소드
    @objc func refreshCalendar(_ noti: Notification) {
        
        // today가 바뀌었을 수도 있어서, 한번 업데이트 해줌.
        TodayDateCenter.shared.updateToday()
        mainCalendar.reloadData()
    }
    
}

// MARK: - FSCalendarDataSource
extension MainViewController: FSCalendarDataSource {
    
    // 각 날짜가 찍히는 위치를 cell의 중간으로 조정하는 메소드.
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        
        let cellDay = DateComponentConverter.shared.convertDate(from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        
        guard let data = dayInfo else { return "" }
        let thisDay = data.filter("year == %@", TodayDateCenter.shared.year).filter("month == %@", TodayDateCenter.shared.month).filter("day == %@", TodayDateCenter.shared.day)
        
        // 오늘 날짜에는 날짜 대신 "Today" 가 찍히도록 함.
        if TodayDateCenter.shared.year == cellDay[0] && TodayDateCenter.shared.month == cellDay[1] && TodayDateCenter.shared.day == cellDay[2]{
            
            if thisDay.count == 0 {
                // 오늘 데이터가 아직 추가되지 않았으면 "today" 찍히도록.
                return "TODAY"
            }else {
                // 오늘 데이터를 추가한 상태라면, 오늘 날짜가 찍히도록.
                return day
            }
        }else {
            return day
        }
    }
}

// MARK: - FSCalendarDelegate
extension MainViewController: FSCalendarDelegate {
    
    // 캘린더 페이지가 바뀌면 호출되는 메소드
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        // datacell을 중간으로 오도록 함.
        centerToDataCellHandler?()
        
        MonthDataCenter.shared.calculateData(currentPage: mainCalendar.currentPage)
        
        // 캘린더 페이지가 바뀌면, 월간 기록에 해당하는 graph view를 각 월 데이터에 맞춰 다시 로드하기 위해 노티피케이션 보냄.
        NotificationCenter.default.post(name: ReloadGraphViewNotification, object: nil)
        
    }
    
    // 오늘 날짜를 선택하면, 성취도 입력 화면이 나오도록 하는 메소드
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let today = TodayDateCenter.shared.today
        
        // 선택한 날짜가 오늘보다 과거라면.
        if date <= today {
            // memoCell로 노티피케이션 보냄.
            NotificationCenter.default.post(name: UserClickSomeDayNotification, object: date)
            
            // 어떤 날짜를 누르면, 아래의 memocell이 화면의 중간으로 오도록 하는 핸들러 호출
            centerToMemoCellHandler?()
            
            return false
        }else{
            return false
        }
    }
}

// MARK: - FSCalendarDelegateApperance
extension MainViewController: FSCalendarDelegateAppearance {
    
    // 기본적으로 채우는 색. 즉, 여기서 DB와 날짜 매칭해서 해당 날짜에 맞는 각 컬러를 입혀줘야함. (이건 캘린더의 날짜 수만큼 수행됨.). calendarCurrentPageDidChange호출 후, 여기로 옴.
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        guard let data = dayInfo else { return UIColor.clear }
        
        let convertDate = DateComponentConverter.shared.convertDate(from: date)
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let thisDay = data.filter("year == %@", convertDate[0]).filter("month == %@", convertDate[1]).filter("day == %@", convertDate[2])
        
        // 성취도를 입력한 적이 있는 날이라면, 각 성취도 색으로 날짜 칸을 채워줌.
        if thisDay.first != nil {
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
        
        let cellDay = DateComponentConverter.shared.convertDate(from: date)
        
        if TodayDateCenter.shared.year == cellDay[0] && TodayDateCenter.shared.month == cellDay[1] && TodayDateCenter.shared.day == cellDay[2] {
            // 오늘 날짜는 날짜칸의 border를 안줌.
            return .clear
        }else {
            return UIColor.borderColor()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    
    /// subview의 스타일을 지정하는 메소드
    func configSubview(){
        
        // subview의 data cell 등록
        let dataCellNib = UINib(nibName: "DataCollectionViewCell", bundle: nil)
        subView.register(dataCellNib, forCellWithReuseIdentifier: DataCollectionViewCell.identifier)
        
        // subview의 memo cell 등록
        let memoCellNib = UINib(nibName: "MemoCollectionViewCell", bundle: nil)
        subView.register(memoCellNib, forCellWithReuseIdentifier: MemoCollectionViewCell.identifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DataCollectionViewCell.identifier, for: indexPath) as? DataCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            // 캘린더 페이지를 이동하면, datacell이 subview의 중간으로 오도록 하는 핸들러
            centerToDataCellHandler = {
                self.subView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoCollectionViewCell.identifier, for: indexPath) as? MemoCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.editDelegate = self
            
            // 캘린더에서 어떤 날짜를 누르면, memocell이 subview의 중간으로 오도록 하는 핸들러
            centerToMemoCellHandler = {
                self.subView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // dataCell과 memoCell의 사이즈를 결정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight = subView.frame.height / Config.AspectRatio.cellAspectRatio
        let cellWidth = subView.frame.width / Config.AspectRatio.cellAspectRatio
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 0, height: 0) }
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension MainViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// DatePicker에 필요한  yearlist와 monthlist를 초기화하는 메소드
    func configPickerData() {
        
        // 캘린더의 minimum~maximum까지의 year를 yearList에 넣어줌.
        var minimumYear = 1970
        for _ in 0...99 {
            yearList.append(String(minimumYear))
            
            minimumYear += 1
        }
        
        // month 정보를 monthList에 넣음.
        var minimumMonth = 1
        for _ in 0..<12 {
            monthList.append(String(minimumMonth))
            minimumMonth += 1
        }
    }
    
    /// CustomPickerView를 생성하고, 초깃값을 설정하는 메소드
    func configPickerView() {
        
        customPickerView = UIPickerView()
        
        customPickerView?.dataSource = self
        customPickerView?.delegate = self
        
        // 각 component에서 보여줄 초기값.
        guard let initYearIndex = yearList.firstIndex(of: String(TodayDateCenter.shared.year)) else { return }
        guard let initMonthIndex = monthList.firstIndex(of: String(TodayDateCenter.shared.month)) else { return }
        customPickerView?.selectRow(initYearIndex, inComponent: 0, animated: true)
        customPickerView?.selectRow(initMonthIndex, inComponent: 1, animated: true)
        
        // 년, 월이 현재로 선택되어있는 상태에서 확인 버튼을 누를 경우를 위해 추가
        selectedYearIndex = initYearIndex
        selectedMonthIndex = initMonthIndex
    }
    
    // PickerView의 component를 몇 개로 할건지
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // PickerView의 각 component에서 몇 개의 row를 보여줄건지
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return yearList.count
        }else{
            return monthList.count
        }
    }
    
    // PickerView의 각 component에서 각 row에 어떤 내용을 보여줄건지
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // 왼쪽 component에서는 year에 해당하는 목록을 보여줌
        if component == 0 {
            return yearList[row] + "년"
        }else{
            // 오른쪽 component에서는 month에 해당하는 목록을 보여줌
            return monthList[row] + "월"
        }
    }
    
    // PickerView의 row 높이 설정.
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    // 사용자가 선택한 row 값을 저장.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedYearIndex = row
        }else{
            selectedMonthIndex = row
        }
    }
}

// MemoCell에서 edit 버튼을 누르면 클릭한 날짜를 기준으로 Modal을 열기 위함.
extension MainViewController: UserWantEditDelegate {
    func showInputModal(from date: Date) {
        print("MainVC에서 delegate 받음")
        
        // 성취도 입력 화면인 ModalView를 present 하기.
        guard let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "InputVC") as? UINavigationController else {
            return
        }
        
        guard let checkVC = modalVC.topViewController as? CheckAchievementViewController else {
            return
        }
        checkVC.showingDate = date
        present(modalVC, animated: true, completion: nil)
    }
}
