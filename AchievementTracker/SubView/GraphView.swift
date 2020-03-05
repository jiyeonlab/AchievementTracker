//
//  GraphView.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/21.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

/// GraphView에 필요한 상수값
private struct Constants {
    static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
    static let margin: CGFloat = 30.0
    static let topBorder: CGFloat = 10
    static let bottomBorder: CGFloat = 30
    static let colorAlpha: CGFloat = 0.3
    static let circleDiameter: CGFloat = 5.0
}

/// Subview의 월간기록 표시를 위한 그래프 view.
@IBDesignable class GraphView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.viewBackgroundColor(.subView)
    @IBInspectable var endColor: UIColor = UIColor.viewBackgroundColor(.subView)
    
    var graphPoints = [0, 0, 0, 0, 0]
    var info: Results<DayInfo>?
    var realm: Realm?
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        graphPoints = MonthDataCenter.shared.achievementCount
        
        // 캘린더 페이지가 바뀌거나, 새로운 데이터가 업데이트 되면, 기존에 add한 subview를 지워주기 위함.
        subviews.forEach({$0.removeFromSuperview()})
        
    }
    
    // view에 무언가를 그릴 때 사용하는 메소드
    override func draw(_ rect: CGRect) {
        
        // MARK: - Drawing Gradient
        // 그림을 그리는 곳이 context인데, 이걸 먼저 얻어와야함.
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        let width = rect.width
        let height = rect.height
        
        //calculate the x point (총 5개의 포인트 - 성취도 값이 5개니까)
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        
        // y 축 값 계산
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = 30
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }
        
        // 라인 그래프 그리기.
        UIColor.fontColor(.memo).setFill()
        UIColor.fontColor(.memo).setStroke()
        
        let graphPath = UIBezierPath()
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // 그래프 아래 부분에 각 성취도 개수를 나타내는 label 추가
        let firstInfoLabel = configLabel(position: CGPoint(x: columnXPoint(0) - 15.0, y: height - bottomBorder + 3.0))
        firstInfoLabel.text = "\(graphPoints[0])" + "count".localized
        self.addSubview(firstInfoLabel)
        
        // 각 포인트를 그래프에 추가
        for i in 1..<graphPoints.count {
            
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
            
            let infoLabel = configLabel(position: CGPoint(x: columnXPoint(i) - 15.0, y: height - bottomBorder + 3.0))
            
            if i == 1 {
               infoLabel.text = "\(graphPoints[i])" + "count".localized
            }else if i == 2 {
                infoLabel.text = "\(graphPoints[i])" + "count".localized
            }else if i == 3 {
                infoLabel.text = "\(graphPoints[i])" + "count".localized
            }else if i == 4{
                infoLabel.text = "\(graphPoints[i])" + "count".localized
            }
            self.addSubview(infoLabel)
        }
        
        graphPath.stroke()
        
        context.saveGState()
        
        guard let clippingPath = graphPath.copy() as? UIBezierPath else { return }
        
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
        clippingPath.addClip()
          
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
        
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context.restoreGState()
        
        graphPath.lineWidth = 1.3
        graphPath.stroke()
        
        let linePath = UIBezierPath()
//        let labelXpos = width - margin
        
        //top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))
        
        //center line
        let centerValue = graphHeight/2 + topBorder
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/2 + topBorder))
  
        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - margin, y: height - bottomBorder))
        
        var color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        // 30일-15일, 15일-0일 중간에 라인 추가
        linePath.move(to: CGPoint(x: margin, y: graphHeight/4 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/4 + topBorder))
        linePath.move(to: CGPoint(x: margin, y: centerValue + graphHeight/4))
        linePath.addLine(to: CGPoint(x: width - margin, y: centerValue + graphHeight/4))
        
        color = UIColor(white: 0.5, alpha: Constants.colorAlpha)
        color.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        
        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
           
            if i == 0 {
                UIColor.achievementColor(.E).setFill()
                UIColor.achievementColor(.E).setStroke()
                
            }else if i == 1 {
                UIColor.achievementColor(.D).setFill()
                UIColor.achievementColor(.D).setStroke()
                
            }else if i == 2 {
                UIColor.achievementColor(.C).setFill()
                UIColor.achievementColor(.C).setStroke()
                
            }else if i == 3 {
                UIColor.achievementColor(.B).setFill()
                UIColor.achievementColor(.B).setStroke()
                
            }else {
                UIColor.achievementColor(.A).setFill()
                UIColor.achievementColor(.A).setStroke()
            }
            circle.fill()
        }
    }
    
    // 그래프의 각 point 아래 들어갈 성취도 갯수 label을 만드는 메소드
    func configLabel(position origin: CGPoint) -> UILabel {
        let labelOrigin = CGPoint(x: origin.x, y: origin.y)
        
        let label = UILabel(frame: CGRect(origin: labelOrigin, size: CGSize(width: Constants.margin, height: Config.Appearance.graphLabelHeight)))
        label.textColor = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        label.font = UIFont(name: Config.Font.normal, size: Config.FontSize.graphLabel)
        label.textAlignment = .center
        
        return label
    }
    
    
}

