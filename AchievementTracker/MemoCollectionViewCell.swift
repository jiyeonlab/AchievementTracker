//
//  MemoCollectionViewCell.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/18.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

class MemoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var memoView: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    
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
    }

}
