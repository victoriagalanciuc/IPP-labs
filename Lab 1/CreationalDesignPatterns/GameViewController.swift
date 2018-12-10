import UIKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    shapeViewFactory = SquareShapeViewFactory(size: gameView.sizeAvailableForShapes())
//    shapeFactory = SquareShapeFactory(minProportion: 0.3, maxProportion: 0.8)
    
    shapeViewFactory = CircleShapeViewFactory(size: gameView.sizeAvailableForShapes())
    shapeFactory = CircleShapeFactory(minProportion: 0.3, maxProportion: 0.8)
    
    shapeViewBuilder = ShapeViewBuilder(shapeViewFactory: shapeViewFactory)
    shapeViewBuilder.fillColor = UIColor.brown
    shapeViewBuilder.outlineColor = UIColor.orange
    
    

    
    
    beginNextTurn()
    
    
  }
  
  
  private func beginNextTurn() {
    let shapes = shapeFactory.createShapes()
    
//    let shapeViews = shapeViewFactory.makeShapeViewsForShapes(shapes: shapes)
    let shapeViews = shapeViewBuilder.buildShapeViewsForShapes(shapes: shapes)

    shapeViews.0.tapHandler = {
      tappedView in
      self.gameView.score += shapes.0.area >= shapes.1.area ? 1 : -1
      self.beginNextTurn()
    }
    shapeViews.1.tapHandler = {
      tappedView in
      self.gameView.score += shapes.1.area >= shapes.0.area ? 1 : -1
      self.beginNextTurn()
    }
    
    gameView.addShapeViews(newShapeViews: shapeViews)
  }
  
  private var gameView: GameView { return view as! GameView }
  
  private var shapeViewFactory: ShapeViewFactory!
  
  private var shapeFactory: ShapeFactory!
  
  private var shapeViewBuilder: ShapeViewBuilder!


}
