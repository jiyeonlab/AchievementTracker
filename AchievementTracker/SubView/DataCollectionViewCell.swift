//
//  DataCollectionViewCell.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/18.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

// MainVC의 subview에 들어가는 월간기록 셀 클래스
class DataCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dataView: UIView!
    static let identifier = "DataCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // cell의 bgcolor
        dataView.backgroundColor = UIColor.viewBackgroundColor(.subView)
        
        // cell의 모양 잡아주기
        dataView.layer.cornerRadius = 15
        dataView.layer.borderColor = UIColor.borderColor().cgColor
        dataView.layer.borderWidth = 2
        dataView.layer.masksToBounds = true
        
        // 캘린더 페이지 변화에 따라 월간 기록 그래프를 새롭게 로드하기 위한 옵저버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView(_:)), name: ReloadGraphViewNotification, object: nil)
    }
    
    // 캘린더 페이지가 변화하면, 각 월에 맞는 데이터로 월간 기록 그래프를 새롭게 그리기 위한 메소드.
    @objc func reloadView(_ notification: Notification){
        
        // GraphView의 setNeedsDisplay를 호출함.
        dataView.subviews.last?.setNeedsDisplay()
    }
}
