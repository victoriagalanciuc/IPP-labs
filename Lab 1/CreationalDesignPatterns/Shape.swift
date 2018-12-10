import Foundation
import UIKit

class Shape {
  var area: CGFloat { return 0 }

}

class SquareShape: Shape {
  var sideLength: CGFloat!
  override var area: CGFloat { return sideLength * sideLength }

}

class CircleShape: Shape {
  var diameter: CGFloat!
  override var area: CGFloat { return .pi * diameter * diameter / 4.0 }
}


