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
    @IBOutlet weak var subView: UICollectionView!
    @IBOutlet weak var datePickerTapView: UIView!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    
    // realm 추가
    var info: Results<DayInfo>?
    var realm: Realm?
    
    // notification token
    var token: NotificationToken?
    
    /// 사용자가 캘린더에서 어떤 날짜를 누를 때 일을 수행하기 위한 핸들러
    var centerToMemoCell: (() -> Void)?
    
    /// 캘린더 페이지를 변경하면 월간 기록 cell을 중간으로 옯기기 위한 핸들러
    var centerToDataCell: (() -> Void)?
    
    /// Custom Picker View 생성
    var customPickerView: UIPickerView?
    var yearList = [String]()
    var monthList = [String]()
    var selectedYearIndex: Int = 0
    var selectedMonthIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar(vcType: .mainView)
        configNavigationTitle()
        
        mainCalendar.dataSource = self
        mainCalendar.delegate = self
        
        configCalendar()
        
        // realm 추가
        realm = try? Realm()
        info = realm?.objects(DayInfo.self)
        print("realm 경로 = \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        receiveRealmNotification()
        
        // subView에 해당하는 collectionview 추가
        subView.dataSource = self
        subView.delegate = self
        subView.decelerationRate = .fast
        configSubview()
        
        // 날짜를 선택할 수 있는 date picker를 열기 위한 tap gesture 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDatePickerView(_:)))
        datePickerTapView.addGestureRecognizer(tapGesture)
        
        // 메모 입력 화면의 노티피케이션을 받기 위한 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(moveMemoCell(_:)), name: CenterToMemoCellNotification, object: nil)
        
        configPickerData()
    }
    /// 현재 달력 페이지의 year, month를 네비게이션 바의 타이틀로 설정하는 메소드
    func configNavigationTitle() {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy"
        //
        //        let currentPageYear = dateFormatter.string(from: mainCalendar.currentPage)
        //
        //        dateFormatter.dateFormat = "MM"
        //        let currentPageMonth = dateFormatter.string(from: mainCalendar.currentPage)
        //
        //        navigationItem.title = currentPageYear + "."+currentPageMonth
        //        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    /// 캘린더의 각종 초기 셋팅을 해주는 메소드
    func configCalendar() {
        
        // 캘린더의 높이 설정
        calendarHeight.constant = view.frame.height / 1.8
        
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
        //        mainCalendar.placeholderType = .fillHeadTail
        
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
        
        guard let data = info else { return }
        
        // 현재 보여지는 캘린더의 year, month, day를 db에서 검색해서, 해당 날짜의 데이터가 있는지 없는지 찾아냄.
        let thisDay = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", TodayDateComponent.day)
        
        token = thisDay.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            case .error(let error):
                print("noti error \(error)")
            case .initial:
                print("noti init")
            case .update(_, let deletions, let insertions, let modifications):
                print("noti update \(deletions) \(insertions) \(modifications)")
                
                guard let todayCell = self.mainCalendar.cell(for: TodayDateComponent.today, at: .current) else { return }
                
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
    
    // 캘린더의 title 부분을 설정하면 datepicker가 뜨도록 함
    @objc func selectDatePickerView(_ sender: UITapGestureRecognizer){
        
        let alertView = UIAlertController(title: "이동하려는 날짜 선택", message: nil, preferredStyle: .actionSheet)
        
        // custom으로 만든 pickerview를 actionsheet에 추가해줌.
        let datePickerView = UIViewController()
        
        configPickerView()
        datePickerView.view = customPickerView
        datePickerView.preferredContentSize.height = 150
        
        // 컨텐츠 뷰 영역에 datePickerView를 설정해줌.
        alertView.setValue(datePickerView, forKey: "contentViewController")
        
        let alertAction = UIAlertAction(title: "확인", style: .default) { action in
           
            // picker view에서 선택한 년, 월을 Date 타입으로 변환하기.
            let movingYear = self.yearList[self.selectedYearIndex]
            let movingMonth = self.monthList[self.selectedMonthIndex]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM"
            
            let movingDate = movingYear + "-" + movingMonth
            print("\(movingDate) 로 이동")
            guard let movingPage = dateFormatter.date(from: movingDate) else { return }
            
            self.mainCalendar.setCurrentPage(movingPage, animated: true)
        }
        alertView.addAction(alertAction)
        
        present(alertView, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertView(_:)))
            alertView.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        
    }
    
    // actionsheet가 열려있는데, 화면의 다른 부분을 tap하면 actionsheet가 사라지게 하기 위함.
    @objc func dismissAlertView(_ tapGesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 메모입력 화면에서 done 버튼을 누르면 받는 노티피케이션을 받아 핸들러를 수행함.
    @objc func moveMemoCell(_ noti: Notification){
        centerToMemoCell?()
    }
    
}

extension MainViewController: FSCalendarDataSource {
    
    // 각 날짜가 찍히는 위치를 cell의 중간으로 조정하기 위해.
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        
        let cellDay = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.string(from: date)
        
        guard let data = info else { return "" }
        let thisDay = data.filter("year == %@", TodayDateComponent.year).filter("month == %@", TodayDateComponent.month).filter("day == %@", TodayDateComponent.day)
        
        // 오늘 날짜에는 날짜 대신 "Today" 가 찍히도록 함.
        if TodayDateComponent.year == cellDay.year && TodayDateComponent.month == cellDay.month && TodayDateComponent.day == cellDay.day{
            print("투데이 title")
            
            if thisDay.count == 0 {
                print("아직 오늘 데이터 없어서 today 찍음 \(thisDay)")
                
                return "TODAY"
            }else {
                print("오늘 데이터 생겨서 날짜 찍음")
                
                return day
            }
        }else {
            return day
        }
    }
}

extension MainViewController: FSCalendarDelegate {
    
    // 캘린더 페이지가 바뀌면 호출되는 메소드
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        configNavigationTitle()
        
        // datacell을 중간으로 보이게 함
        centerToDataCell?()
    }
    
    // 오늘 날짜를 선택하면, 성취도 입력 화면이 나오도록 함.
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let today = TodayDateComponent.today
        
        // 과거 날짜만 선택 가능
        if date <= today {
            // memoCell로 노티피케이션 보냄.
            NotificationCenter.default.post(name: UserClickSomeDayNotification, object: date)
            
            // 어떤 날짜를 누르면, 아래의 memocell이 화면의 중간으로 오도록 하는 핸들러 호출
            centerToMemoCell?()
            
            return false
        }else{
            return false
        }
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
        
        let cellDay = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        if TodayDateComponent.year == cellDay.year && TodayDateComponent.month == cellDay.month && TodayDateComponent.day == cellDay.day {
            return .clear
        }else {
            return UIColor.borderColor()
        }
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /// subview의 스타일을 지정하는 메소드
    func configSubview(){
        
        // data cell
        let dataCellNib = UINib(nibName: "DataCollectionViewCell", bundle: nil)
        subView.register(dataCellNib, forCellWithReuseIdentifier: DataCollectionViewCell.identifier)
        
        // memo cell
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
            
            // 캘린더 페이지를 이동하면, datacell이 중간으로 오도록 하는 핸들러
            centerToDataCell = {
                self.subView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemoCollectionViewCell.identifier, for: indexPath) as? MemoCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            // 캘린더에서 어떤 날짜를 누르면, memocell이 중간으로 오도록 하기 위한 핸들러
            centerToMemoCell = {
                self.subView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    // dataCell과 memoCell의 사이즈를 결정하는 부분
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight = subView.frame.height / Config.AspectRatio.cellAspectRatio
        let cellWidth = subView.frame.width / Config.AspectRatio.cellAspectRatio
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // dataCell과 memoCell을 select하면, 해당 cell이 collectionview의 중간으로 오도록 함.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    
    // collectionview cell의 paging 효과를 위해 추가
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //
    //        // item의 사이즈와 item 간의 간격 사이즈를 구해서 하나의 item 크기로 설정.
    //        let layout = subView.collectionViewLayout as! UICollectionViewFlowLayout
    //        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
    //
    //        // targetContentOff을 이용하여 x좌표가 얼마나 이동했는지 확인
    //        // 이동한 x좌표 값과 item의 크기를 비교하여 몇 페이징이 될 것인지 값 설정
    //        var offset = targetContentOffset.pointee
    //        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
    //        var roundedIndex = round(index)
    //
    //        // scrollView, targetContentOffset의 좌표 값으로 스크롤 방향을 알 수 있다.
    //        // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야 페이징이 된다.
    //        // 스크로로 방향을 체크하여 올림,내림을 사용하면 좀 더 자연스러운 페이징 효과를 낼 수 있다.
    //        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
    //            roundedIndex = floor(index)
    //        } else {
    //            roundedIndex = ceil(index)
    //        }
    //
    //        // 위 코드를 통해 페이징 될 좌표값을 targetContentOffset에 대입하면 된다.
    //        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
    //        targetContentOffset.pointee = offset
    //    }
}

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
        for _ in 0..<7 {
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
        guard let initYearIndex = yearList.firstIndex(of: String(TodayDateComponent.year)) else { return }
        guard let initMonthIndex = monthList.firstIndex(of: String(TodayDateComponent.month)) else { return }
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
            return yearList[row]
        }else{
            // 오른쪽 component에서는 month에 해당하는 목록을 보여줌
            return monthList[row] + "월"
        }
    }
    
    // PickerView의 row 높이 설정
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            print("년을 선택했음 \(row)")
            selectedYearIndex = row
        }else{
            print("월을 선택했음 \(row)")
            selectedMonthIndex = row
        }
    }
}
