//
//  GraphView.swift
//  AchievementTracker
//
//  Created by JiyeonKim on 2020/01/21.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import RealmSwift

private struct Constants {
  static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
  static let margin: CGFloat = 30.0
  static let topBorder: CGFloat = 10
  static let bottomBorder: CGFloat = 40
  static let colorAlpha: CGFloat = 0.3
  static let circleDiameter: CGFloat = 5.0
}

@IBDesignable class GraphView: UIView {

    @IBInspectable var startColor: UIColor = UIColor.viewBackgroundColor(.subView)
    @IBInspectable var endColor: UIColor = UIColor.viewBackgroundColor(.subView)
    
    var graphPoints = [10, 15, 10, 3, 20]
    var info: Results<DayInfo>?
    var realm: Realm?
    
    func calculateMonthData() {
//        realm = try? Realm()
//        info = realm?.objects(DayInfo.self)
//
//        guard let data = info else { return }
//
//        let thisMonth = data.filter("year == %@", )
    }
    
    // view에 무언가를 그릴 때 사용하는 메소드
    override func draw(_ rect: CGRect) {
        
        print("그래픽 뷰 2222")
        // MARK: - Drawing Gradient
        // 그림을 그리는 곳이 context인데, 이걸 먼저 얻어와야함.
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
//        let endPoint = CGPoint(x: bounds.width, y: 0)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        // MARK: - Cliping Areas
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        // MARK: - Tricky Calculations for Graphic Points

        let width = rect.width
        let height = rect.height
        
        //calculate the x point
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
          //Calculate the gap between points
          let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
          return CGFloat(column) * spacing + margin + 2
        }
        
        // calculate the y point
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
          let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
          return graphHeight + topBorder - y // Flip the graph
        }

        // draw the line graph

//        UIColor.white.setFill()
//        UIColor.white.setStroke()
//        UIColor.fontColor(.today).setFill()
//        UIColor.fontColor(.today).setStroke()
        UIColor.fontColor(.memo).setFill()
        UIColor.fontColor(.memo).setStroke()
            
        // set up the points line
        let graphPath = UIBezierPath()

        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        let firstInfoView = UIView(frame: CGRect(x: columnXPoint(0), y: height - bottomBorder + 3.0, width: margin / 3 , height: margin / 3))
        firstInfoView.layer.backgroundColor = UIColor.achievementColor(.E).cgColor
        firstInfoView.layer.cornerRadius = 8.0
        self.addSubview(firstInfoView)
            
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
          let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
          graphPath.addLine(to: nextPoint)
            
            let infoView = UIView(frame: CGRect(x: columnXPoint(i) - 7.0, y: height - bottomBorder + 3.0, width: margin / 3 , height: margin / 3))
//            infoView.layer.backgroundColor = UIColor.red.cgColor
            if i == 1 {
                infoView.layer.backgroundColor = UIColor.achievementColor(.D).cgColor
            }else if i == 2 {
                infoView.layer.backgroundColor = UIColor.achievementColor(.C).cgColor
            }else if i == 3 {
                infoView.layer.backgroundColor = UIColor.achievementColor(.B).cgColor
            }else if i == 4{
                infoView.layer.backgroundColor = UIColor.achievementColor(.A).cgColor
            }
            infoView.layer.cornerRadius = 8.0
            self.addSubview(infoView)
        }

        graphPath.stroke()

        // MARK: - A Gradient Graph
        //Create the clipping path for the graph gradient

        //1 - save the state of the context (commented out for now)
        //context.saveGState()
            
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
            
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
            
        //4 - add the clipping path to the context
        clippingPath.addClip()
            
        //5 - check clipping path - temporary code
//        UIColor.green.setFill()
//        UIColor.achievementColor(.A).setFill()
//        let rectPath = UIBezierPath(rect: rect)
//        rectPath.fill()
        //end temporary code
        
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)

        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        //context.restoreGState()
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 3.0
        graphPath.stroke()

        // MARK: - Drawing the Data Points
        
        //Draw the circles on top of the graph stroke
        for i in 0..<graphPoints.count {
          var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
          point.x -= Constants.circleDiameter / 2
          point.y -= Constants.circleDiameter / 2

          let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
          circle.fill()
            
//            if i == 0 {
//                UIColor.achievementColor(.E).setFill()
//                UIColor.achievementColor(.E).setStroke()
//            }else if i == 1 {
//                UIColor.achievementColor(.D).setFill()
//                UIColor.achievementColor(.D).setStroke()
//            }else if i == 2 {
//                UIColor.achievementColor(.C).setFill()
//                UIColor.achievementColor(.C).setStroke()
//            }else if i == 3 {
//                UIColor.achievementColor(.B).setFill()
//                UIColor.achievementColor(.B).setStroke()
//            }else {
//                UIColor.achievementColor(.A).setFill()
//                UIColor.achievementColor(.A).setStroke()
//            }
//            circle.fill()
        }


        // MARK: - Context States
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()

        //top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))
        let topLabel = UILabel(frame: CGRect(x: width - margin, y: topBorder - 10.0, width: margin, height: 20.0))
        topLabel.text = "30"
        topLabel.textColor = UIColor.fontColor(.memo)
        topLabel.font = UIFont.systemFont(ofSize: 11.0)
        topLabel.textAlignment = .center
        self.addSubview(topLabel)

        //center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/2 + topBorder))
        let centerLabel = UILabel(frame: CGRect(x: width - margin, y: graphHeight/2 + topBorder - 10.0, width: margin, height: 20.0))
        centerLabel.text = "15"
        centerLabel.textColor = UIColor.fontColor(.memo)
        centerLabel.font = UIFont.systemFont(ofSize: 11.0)
        centerLabel.textAlignment = .center
        self.addSubview(centerLabel)

        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - margin, y: height - bottomBorder))
        let bottomLabel = UILabel(frame: CGRect(x: width - margin, y: height - bottomBorder - 10.0, width: margin, height: 20.0))
        bottomLabel.text = "0"
        bottomLabel.textColor = UIColor.fontColor(.memo)
        bottomLabel.font = UIFont.systemFont(ofSize: 11.0)
        bottomLabel.textAlignment = .center
        self.addSubview(bottomLabel)
        
        
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()

        linePath.lineWidth = 1.0
        linePath.stroke()

        // MARK: - Adding Graph Labels
        
    }
    

}

