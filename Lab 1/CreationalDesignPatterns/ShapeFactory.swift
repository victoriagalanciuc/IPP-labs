import Foundation
import UIKit

protocol ShapeFactory {
  func createShapes() -> (Shape, Shape)
}

class SquareShapeFactory: ShapeFactory {
  var minProportion: CGFloat
  var maxProportion: CGFloat
  
  init(minProportion: CGFloat, maxProportion: CGFloat) {
    self.minProportion = minProportion
    self.maxProportion = maxProportion
  }
  
  func createShapes() -> (Shape, Shape) {
    let shape1 = SquareShape()
    shape1.sideLength = Utils.randomBetweenLower(lower: minProportion, andUpper: maxProportion)
    
    let shape2 = SquareShape()
    shape2.sideLength = Utils.randomBetweenLower(lower: minProportion, andUpper: maxProportion)
    
    return (shape1, shape2)
  }
}

class CircleShapeFactory: ShapeFactory {
  var minProportion: CGFloat
  var maxProportion: CGFloat
  
  init(minProportion: CGFloat, maxProportion: CGFloat) {
    self.minProportion = minProportion
    self.maxProportion = maxProportion
  }
  
  func createShapes() -> (Shape, Shape) {
    let shape1 = CircleShape()
    shape1.diameter = Utils.randomBetweenLower(lower: minProportion, andUpper: maxProportion)
    
    let shape2 = CircleShape()
    shape2.diameter = Utils.randomBetweenLower(lower: minProportion, andUpper: maxProportion)
    
    return (shape1, shape2)
  }
}
