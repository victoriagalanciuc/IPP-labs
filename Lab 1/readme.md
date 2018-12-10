# Design Patterns Laboratory Work 2-3
## Task
Implementing 3 creational patterns 

*Creational patterns:*
+ Factory Method
+ Abstract Factory
+ Builder

In order to illustrate these patterns, I have created a simple game, in which the player is presented with a pair of similar shapes (initially the shape is a square) and the player has to tap the larger one in order to gain a point. Otherwise, they lose a point.


## Factory Method 
**Intent**
Provides an interface for creating objects in a superclass, but allows subclasses to alter the type of objects that will be created.
**Implementation**
In the ```ShapeViewFactory.swift```  the class for drawing the shape views is defined. Therefore, we don't have to know anything about how the shape classes are encoded or how shape classes are initialized.

```swift
protocol ShapeViewFactory {
    var size: CGSize { get set }
    func makeShapeViewsForShapes(shapes: (Shape, Shape)) -> (ShapeView, ShapeView)

}

class SquareShapeViewFactory: ShapeViewFactory {
    var size: CGSize

    init(size: CGSize) {
        self.size = size
    }

    func makeShapeViewsForShapes(shapes: (Shape, Shape)) -> (ShapeView, ShapeView) {
        let squareShape1 = shapes.0 as! SquareShape
        let shapeView1 = SquareShapeView(frame: CGRect(x: 0, y: 0, width: squareShape1.sideLength * size.width, height: squareShape1.sideLength * size.height))
        shapeView1.shape = squareShape1

        let squareShape2 = shapes.1 as! SquareShape
        let shapeView2 = SquareShapeView(frame: CGRect(x: 0, y: 0, width: squareShape2.sideLength * size.width, height: squareShape2.sideLength * size.height))
        shapeView2.shape = squareShape2
        return (shapeView1, shapeView2)
    }
}

let shape1 = SquareShape()
let shape2 = SquareShape()
let shapeViews = shapeViewFactory.makeShapeViewsForShapes((shape1, shape2))

```

## Abstract Factory 
**Intent**
Provides a way to encapsulate a group of individual factories that have a common theme without specifying their concrete classes. In other words, abstract factory is used when we need to create families of related objects. 
**Implementation**
I implemented the abstract factory pattern using factory method, to establish an API for constructing a group of related objects, like the shape views.
```swift
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
```
Now, the ```SquareShapeViewFactory``` produces ```SquareShapeView``` instances in the following way:
+ Initializes a maximum size.
+ Constructs the first shape view from the first passed shape.
+ Constructs the second shape view from the second passed shape.
+ Returns a tuple containing the two created shape views.

Let's see ```SquareShapeViewFactory``` in action:
```swift
// initializes a SquareShapeViewFactory
shapeViewFactory = SquareShapeViewFactory(size: gameView.sizeAvailableForShapes())

// using the new factory to create the shape views
let shapeViews = shapeViewFactory.makeShapeViewsForShapes((shape1, shape2))
```
Now, if we want to introduce a new, say a circle, we wouldn't have to make changes to the logic of the game in the ```GameViewController```,  isolating all the changes to ```SquareShapeViewFactory```:
```swift
class CircleShapeFactory: ShapeFactory {
    var minProportion: CGFloat
    var maxProportion: CGFloat

    init(minProportion: CGFloat, maxProportion: CGFloat) {
        self.minProportion = minProportion
        self.maxProportion = maxProportion
    }

    func createShapes() -> (Shape, Shape) {
        let shape1 = CircleShape()
        shape1.diameter = Utils.randomBetweenLower(minProportion, andUpper: maxProportion)

        let shape2 = CircleShape()
        shape2.diameter = Utils.randomBetweenLower(minProportion, andUpper: maxProportion)

        return (shape1, shape2)
    }
}
```
All we have to change now in our main controller is adding the following:
```swift
shapeViewFactory = CircleShapeViewFactory(size: gameView.sizeAvailableForShapes())
shapeFactory = CircleShapeFactory(minProportion: 0.3, maxProportion: 0.8)
```
And that's it. We have now circles instead of squares.

## Builder Pattern
**Intent**
Separating the construction of a complex object from its representation so that the same construction process can create different representations.
**Implemenation**
Suppose we now want to vary the appearance of our ShapeView instances — for example, we want them to have various colors and we want to decide whether they should show fill and/or outline colors. The Builder design pattern will make such object configuration easier and more flexible. Of course, we may add a variety of constructors, like ```CircleShapeView.redFilledCircleWithBlueOutline()``` or initializers with a variety of arguments and default values. However, it’s not quite a scalable technique as we'd need to write a new method or initializer for every combination. Therefore, the solution would be to create a class as follows:


```swift
class ShapeViewBuilder {
    var showFill  = true
    var fillColor = UIColor.orangeColor()

    var showOutline  = true
    var outlineColor = UIColor.grayColor()

    init(shapeViewFactory: ShapeViewFactory) {
        self.shapeViewFactory = shapeViewFactory
    }

    func buildShapeViewsForShapes(shapes: (Shape, Shape)) -> (ShapeView, ShapeView) {
        let shapeViews = shapeViewFactory.makeShapeViewsForShapes(shapes)
        configureShapeView(shapeViews.0)
        configureShapeView(shapeViews.1)
        return shapeViews
    }

    private func configureShapeView(shapeView: ShapeView) {
        shapeView.showFill  = showFill
        shapeView.fillColor = fillColor
        shapeView.showOutline  = showOutline
        shapeView.outlineColor = outlineColor
    }

    private var shapeViewFactory: ShapeViewFactory
```
Our builder works in the following way:
+ Stores necessary configuration to set ShapeView fill properties.
+ Store necessary configuration to set ShapeView outline properties.
+ Initializes the builder to hold a ShapeViewFactory to construct the views. This means the builder doesn’t need to know if it’s building SquareShapeView or CircleShapeView etc.
+ Does the actual configuration of a ShapeView based on the builder’s stored configuration.


