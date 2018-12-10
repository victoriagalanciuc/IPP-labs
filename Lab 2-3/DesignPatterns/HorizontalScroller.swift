import UIKit
import Foundation

@objc protocol HorizontalScrollerDelegate {
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    func horizontalScollerViewAtIndex(scroller: HorizontalScroller, index:Int) -> UIView
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index:Int)
    
    @objc optional func intialViewIndex(scroller: HorizontalScroller) -> Int
}

class HorizontalScroller: UIView {
    
    weak var delegate: HorizontalScrollerDelegate?
    
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEWS_OFFSET = 100
    
    private var scroller: UIScrollView!
    
    var viewArray = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initializeScrollView()
    }
    
    func initializeScrollView() {
        scroller = UIScrollView()
        addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(scrollerTapped))
        scroller.addGestureRecognizer(tapRecognizer)
        scroller.delegate = self
    }
    
    @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if let delegate = delegate {
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                let view = scroller.subviews[index]
                if view.frame.contains(location) {
                    delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: index)
                    scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, y: 0), animated:true)
                    break
                }
            }
        }
    }

    func viewAtIndex(index: Int) -> UIView {
        return viewArray[index]
    }
    
    func reload() {
        if let delegate = delegate {
            
            viewArray = []
            let views: NSArray = scroller.subviews as NSArray
            for view in views {
                (view as AnyObject).removeFromSuperview()
            }
            var xValue = VIEWS_OFFSET
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                xValue += VIEW_PADDING
                let view = delegate.horizontalScollerViewAtIndex(scroller: self, index: index)
                view.frame = CGRect(CGFloat(xValue), CGFloat(VIEW_PADDING), CGFloat(VIEW_DIMENSIONS), CGFloat(VIEW_DIMENSIONS))
                scroller.addSubview(view)
                xValue += VIEW_DIMENSIONS + VIEW_PADDING
                
                viewArray.append(view)
            }
            
            scroller.contentSize = CGSize(CGFloat(xValue + VIEWS_OFFSET), frame.size.height)
            
            if let initialView = delegate.intialViewIndex?(scroller: self) {
                scroller.setContentOffset(CGPoint(x: CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), y: 0), animated: true)
            }
        }
    }
    
    override func didMoveToSuperview() {
        reload()
    }
    
    func centerCurrentView() {
        var xFinal = Int(scroller.contentOffset.x) + (VIEWS_OFFSET/2) + VIEW_PADDING
        let viewIndex = xFinal / (VIEW_DIMENSIONS + (2*VIEW_PADDING))
        xFinal = viewIndex * (VIEW_DIMENSIONS + (2*VIEW_PADDING))
        scroller.setContentOffset(CGPoint(CGFloat(xFinal), 0), animated: true)
        if let delegate = delegate {
            delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: Int(viewIndex))
        }
    }
}

extension HorizontalScroller : UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCurrentView()
    }
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}

