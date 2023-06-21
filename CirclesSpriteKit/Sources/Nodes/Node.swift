//
//  Node.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/25/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

@objcMembers open class Node: SKShapeNode {

    private var childrenCirclesCount: Int {
        return children.filter { $0 is ChildNode}.count
    }

    var currentPosition = 0 {
        didSet {
            if currentPosition > 3 {
                currentPosition = 0
            }
        }
    }

    let positionsArray = [(-100.0, 0.0),(0.0, 100.0),(100.0, 0.0), (0.0, -100.0)]

    override open func addChild(_ node: SKNode) {

        if let node = node as? ChildNode {
            node.animateAppearing()

//            var x = 0.0
//            if children.count % 2 == 0 {
//                x += 100.0
//            } else {
//                x -= 100.0
//            }
//            let y = CGFloat.random(0.0, 100.0)

            if childrenCirclesCount == 0 {
                node.position = .zero
                node.physicsBody?.isDynamic = false
            } else {
                let x = positionsArray[currentPosition].0
                let y =  positionsArray[currentPosition].1
                node.position = CGPoint(x: x, y: y)
                currentPosition += 1
            }

            super.addChild(node)

            recalculateSize()
            createMagnticField()

        } else {
            super.addChild(node)
        }
    }

    private func recalculateSize() {
        var newRadius: CGFloat
        switch childrenCirclesCount {
        case 1:  newRadius = 80.0
        case 2...6: newRadius = 150.0
        case 7...10: newRadius = 200
        default: newRadius = 200.0
        }
        self.radius = newRadius

        self.update(radius: newRadius)

    }

    public func animateAlpha(to alpha: CGFloat) {
        let fade = SKAction.fadeAlpha(to: alpha, duration: 0.4)
        run(fade)
    }

    public lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = Defaults.fontName
        label.fontSize = Defaults.fontSize
        label.fontColor = Defaults.fontColor
        label.verticalAlignmentMode = .center
        label.width = self.frame.width
        label.separator = " "
        addChild(label)
        return label
    }()


    open var text: String? {
        get { return label.text }
        set {
            label.text = newValue
        }
    }

    open var image: UIImage? {
        didSet {
//            let url = URL(string: "https://picsum.photos/1200/600")!
//            let image = UIImage(data: try! Data(contentsOf: url))
            texture = image.map { SKTexture(image: $0.aspectFill(self.frame.size)) }
        }
    }

    open var color: UIColor = Defaults.color {
        didSet {
            self.fillColor = color
        }
    }

    open var texture: SKTexture?

    open var isSelected: Bool = false {
        didSet {
            guard isSelected != oldValue else { return }
            if isSelected {
                selectedAnimation()
            } else {
                deselectedAnimation()
            }
        }
    }

    open var selectedScale: CGFloat = 4 / 3
    open var deselectedScale: CGFloat = 1
    private var originalColor: UIColor = Defaults.color
    open var selectedColor: UIColor?
    open var selectedFontColor: UIColor?
    private var originalFontColor: UIColor = Defaults.fontColor
    open var animationDuration: TimeInterval = 0.2
    open var marginScale: CGFloat = Defaults.marginScale
    open private(set) var radius: CGFloat?

    public init(text: String? = nil,
                image: UIImage? = nil,
                color: UIColor,
                path: CGPath,
                marginScale: CGFloat = 1.1,
                radius: CGFloat) {
        super.init()
        self.alpha = 0.0
        self.path = path
        self.marginScale = marginScale
        self.radius = radius
        regeneratePhysicsBody(withPath: path)
        configure(text: text, image: image, color: color)
        createMagnticField()
    }

    public convenience init(text: String? = nil,
                            image: UIImage? = nil,
                            color: UIColor,
                            radius: CGFloat,
                            marginScale: CGFloat = 1.1) {
        let path = SKShapeNode(circleOfRadius: radius).path!
        self.init(text: text, image: image, color: color, path: path, marginScale: marginScale, radius: radius)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String?, image: UIImage?, color: UIColor) {
        self.text = text
        self.image = image
        self.color = color
    }

    private func createMagnticField() {
        guard self.radius ?? 0.0 > 0 else {
            assertionFailure("unknown radius")
            return
        }
        let floatRadius = Float(self.radius ?? .zero)
        magneticField.region = SKRegion(radius: floatRadius)
//        magneticField.minimumRadius = 0.1
//        magneticField.strength = 0.5
//        magneticField.position = .zero
//        magneticField.zPosition = 10
    }

    open lazy var magneticField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.springField()
        field.categoryBitMask = CollisionTypes.smallField.rawValue
        field.zPosition = 20

        self.addChild(field)
        return field
    }()

    override open func removeFromParent() {
        removedAnimation() {
            super.removeFromParent()
        }
    }

    private func update(radius: CGFloat) {
        guard let path = SKShapeNode(circleOfRadius: radius).path else { return }
        self.path = path
        self.radius = radius
        regeneratePhysicsBody(withPath: path)
    }

    private func regeneratePhysicsBody(withPath path: CGPath) {
        self.physicsBody = {
            var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
            let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
            body.allowsRotation = false
            body.friction = 0
            body.linearDamping = 3
            body.categoryBitMask = CollisionTypes.bigCircle.rawValue
            body.collisionBitMask = CollisionTypes.bigCircle.rawValue
            body.fieldBitMask = CollisionTypes.bigField.rawValue
            return body
        }()
    }


    /**
     The animation to execute when the node is selected.
     */
    open func selectedAnimation() {
        self.originalColor = fillColor

        let scaleAction = SKAction.scale(to: selectedScale, duration: animationDuration)

        if let selectedFontColor = selectedFontColor {
            label.run(.colorTransition(from: originalFontColor, to: selectedFontColor))
        }

        if let selectedColor = selectedColor {
          run(.group([
            scaleAction,
            .colorTransition(from: originalColor, to: selectedColor, duration: animationDuration),
          ]))
        } else {
          run(scaleAction)
        }

        if let texture = texture {
          fillTexture = texture
        }
    }

    /**
     The animation to execute when the node is deselected.
     */
    open func deselectedAnimation() {
        let scaleAction = SKAction.scale(to: deselectedScale, duration: animationDuration)

        if let selectedColor = selectedColor {
          run(.group([
            scaleAction,
            .colorTransition(from: selectedColor, to: originalColor, duration: animationDuration)
          ]))
        } else {
          run(scaleAction)
        }

        if let selectedFontColor = selectedFontColor {
          label.run(.colorTransition(from: selectedFontColor, to: originalFontColor, duration: animationDuration))
        }

        self.fillTexture = nil
    }

    /**
     The animation to execute when the node is removed.

     - important: You must call the completion block.

     - parameter completion: The block to execute when the animation is complete. You must call this handler and should do so as soon as possible.
     */
    open func removedAnimation(completion: @escaping () -> Void) {
        run(.group([.fadeOut(withDuration: animationDuration), .scale(to: 0, duration: animationDuration)]), completion: completion)
    }

}
