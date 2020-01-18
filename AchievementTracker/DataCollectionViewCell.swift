//
//  DataCollectionViewCell.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/18.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

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
    }
}
