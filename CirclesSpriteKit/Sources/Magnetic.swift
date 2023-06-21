//
//  Magnetic.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/8/17.
//  Copyright © 2017 efremidze. All rights reserved.
//



import SpriteKit

struct Defaults {
    static let fontName = "Avenir-Black"
    static let fontColor = UIColor.white
    static let fontSize = CGFloat(12)
    static let color = UIColor.clear
    static let marginScale = CGFloat(1.1)
    static let scaleToFitContent = true // backwards compatability
    static let padding = CGFloat(20)
}

enum CollisionTypes: UInt32 {
    case bigCircle = 2
    case smallCircle = 4

    case bigField = 8
    case smallField = 16
}

@objc public protocol MagneticDelegate: AnyObject {
    func magnetic(_ magnetic: Magnetic, didSelect node: Node)
    func magnetic(_ magnetic: Magnetic, didDeselect node: Node)
    @objc optional func magnetic(_ magnetic: Magnetic, didRemove node: Node)
}

@objcMembers open class Magnetic: SKScene {

    var cam: SKCameraNode!

    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGesture)

        cam = SKCameraNode()
        self.camera = cam
        self.camera?.position = CGPoint(x: view.center.x, y:view.center.y/2)
    }

    var previousCameraScale = CGFloat()

    @objc func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = camera else {
         return
       }
       if sender.state == .began {
           magneticField.isEnabled = false
         previousCameraScale = camera.xScale
       }

        if sender.state == .ended {
            magneticField.isEnabled = true
        }
       camera.setScale(previousCameraScale * 1 / sender.scale)
     }


    /**
     The field node that accelerates the nodes.
     */
    open lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        field.categoryBitMask = CollisionTypes.bigField.rawValue
        self.addChild(field)
        return field
    }()

    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true


    /**
    Controls whether an item can be removed by holding down
     */
    open var removeNodeOnLongPress: Bool = false

    /**
     The length of time (in seconds) the node must be held on to trigger a remove event
     */
    open var longPressDuration: TimeInterval = 0.35

    open var isDragging: Bool = false

    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.compactMap { $0 as? Node }.filter { $0.isSelected }
    }

    var circlesCount: Int {
        return children.filter { $0 is Node}.count
    }

    /**
     The object that acts as the delegate of the scene.

     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magneticDelegate: MagneticDelegate?

    private var touchStarted: TimeInterval?

    override open var size: CGSize {
        didSet {
            configure()
        }
    }

    override public init(size: CGSize) {
        super.init(size: size)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        backgroundColor = .white
        scaleMode = .aspectFill
        configure()
    }

    func configure() {
        let strength = Float(max(size.width, size.height))
        let radius = strength.squareRoot() * 100

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(radius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        physicsBody?.fieldBitMask = CollisionTypes.bigField.rawValue
        magneticField.region = SKRegion(radius: radius)
        magneticField.minimumRadius = radius
        magneticField.strength = strength
        magneticField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }

    override open func addChild(_ node: SKNode) {
        guard children.contains(where: { $0.name == node.name }) == false else { return }
        
        guard circlesCount > 0 else {
            node.position = CGPoint(x: frame.width/2, y: frame.height/2)
            super.addChild(node)
            return
        }
        var x = 0.0 // left
        if children.count % 2 == 0 {
            x = frame.width // right
        }
        let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: x, y: y)
        super.addChild(node)
    }

    func updateAlpha(nodeName: String, alpha: CGFloat) {
        let node = children.first(where: {$0.name == nodeName}) as? Node
        node?.animateAlpha(to: alpha)
    }
}

extension Magnetic {

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard removeNodeOnLongPress, let touch = touches.first else { return }
        touchStarted = touch.timestamp
    }

    func moveNode() {
        debugPrint("moving node")
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let previous = touch.previousLocation(in: self)
        guard location.distance(from: previous) != 0 else { return }

        isDragging = true
        magneticField.isEnabled = false
        moveNodes(location: location, previous: previous)
    }


    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        magneticField.position = location
        magneticField.isEnabled = true

        defer { isDragging = false }
        guard !isDragging, let node = node(at: location) else { return }

        if removeNodeOnLongPress && !node.isSelected {
            guard let touchStarted = touchStarted else { return }
            let touchEnded = touch.timestamp
            let timeDiff = touchEnded - touchStarted

            if (timeDiff >= longPressDuration) {
                node.removedAnimation {
                    self.magneticDelegate?.magnetic?(self, didRemove: node)
                }
                return
            }
        }

        if node.isSelected {
            node.isSelected = false
            magneticDelegate?.magnetic(self, didDeselect: node)
        } else {
            if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                selectedNode.isSelected = false
                magneticDelegate?.magnetic(self, didDeselect: selectedNode)
            }
            node.isSelected = true
            magneticDelegate?.magnetic(self, didSelect: node)
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

}

extension Magnetic {
    func moveNodes(location: CGPoint, previous: CGPoint) {
        let x = location.x - previous.x
        let y = location.y - previous.y

        for node in children {
            let distance = node.position.distance(from: location)
            let acceleration: CGFloat = 2 * pow(distance, 1/2)
            let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
            node.physicsBody?.applyForce(direction)
        }
    }

    func node(at point: CGPoint) -> Node? {
        return nodes(at: point).compactMap { $0 as? Node }.filter { $0.path!.contains(convert(point, to: $0)) }.first
    }

    /// Resets the `MagneticView` by making all visible `Node` objects vanish to a point.
    func reset() {
        let speed = physicsWorld.speed
        physicsWorld.speed = 0
        let actions = removalActions()
        run(.sequence(actions)) { [unowned self] in
            self.physicsWorld.speed = speed
        }
    }

    // только для дебага
    func removeLast() {
        let lastNote = sortedNodes().last
        lastNote?.removeFromParent()
    }

    func addSubChild() {
        let presetsArray = HabitPreset.allCases
        let subChild = ChildNode(radius: 40, preset: presetsArray.randomItem())
        if let lastNode = sortedNodes().last {
            lastNode.addChild(subChild)
        }
    }

}

/// An extension to handle the reset animation.
extension Magnetic {
    /// Retrieves an array of `Node` objects softed by distance.
    ///
    /// - Returns: `[Node]`
    ///
    func sortedNodes() -> [Node] {
        return children.compactMap { $0 as? Node }.sorted { node, nextNode in
            let distance = node.position.distance(from: magneticField.position)
            let nextDistance = nextNode.position.distance(from: magneticField.position)
            return distance < nextDistance && node.isSelected
        }
    }


    /// Retrieves an array of `SKAction`s that are setup for reset animation.
    ///
    /// - Returns: `[SKAction]`
    ///
    func removalActions() -> [SKAction] {
        var actions = [SKAction]()
        for (index, node) in sortedNodes().enumerated() {
            node.physicsBody = nil
            let action = SKAction.run { [unowned self, unowned node] in
                if node.isSelected {
                    let point = CGPoint(x: self.size.width / 2, y: self.size.height + 40)
                    let movingXAction = SKAction.moveTo(x: point.x, duration: 0.2)
                    let movingYAction = SKAction.moveTo(y: point.y, duration: 0.4)
                    let resize = SKAction.scale(to: 0.3, duration: 0.4)
                    let throwAction = SKAction.group([movingXAction, movingYAction, resize])
                    node.run(throwAction) { [unowned node] in
                        node.removeFromParent()
                    }
                } else {
                    node.removeFromParent()
                }
            }
            actions.append(action)
            let delay = SKAction.wait(forDuration: TimeInterval(index) * 0.002)
            actions.append(delay)
        }
        return actions
    }
}

