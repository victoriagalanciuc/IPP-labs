import Foundation
import UIKit

class Utils {
  class func randomBetweenLower(lower: CGFloat, andUpper: CGFloat) -> CGFloat {
    return lower + CGFloat(arc4random_uniform(101)) / 100.0 * (andUpper - lower)
  }
}
