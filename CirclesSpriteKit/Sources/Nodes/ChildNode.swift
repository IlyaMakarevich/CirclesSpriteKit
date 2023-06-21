//
//  ChildNode.swift
//  CirclesSpriteKit
//
//  Created by Ilya Makarevich on 6/16/23.
//

import Foundation
import SpriteKit


 class ChildNode: SKShapeNode {
    private var marginScale: CGFloat = 1.15
    private var habitPreset: HabitPreset = .read

    lazy var label: SKMultilineLabelNode = { [unowned self] in
        let label = SKMultilineLabelNode()
        label.fontName = Defaults.fontName
        label.fontSize = Defaults.fontSize
        label.fontColor = Defaults.fontColor
        label.verticalAlignmentMode = .center
        label.width = self.frame.width
        label.separator = " "
        return label
    }()

    init(radius: CGFloat, preset: HabitPreset) {
        let path = SKShapeNode(circleOfRadius: radius).path!
        super.init()
        self.zPosition = 4
        self.path = path
        self.alpha = 1.0
        self.fillColor = UIColor.colors.randomItem()
        regeneratePhysicsBody(withPath: path)
        addIcon(preset: preset)
        addText(preset: preset)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animateAppearing() {
        let delay = SKAction.wait(forDuration: 0.0)
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        let sequence = SKAction.sequence([delay, fade])
        run(sequence)
    }

    private func regeneratePhysicsBody(withPath path: CGPath) {
        self.physicsBody = {
            var transform = CGAffineTransform.identity.scaledBy(x: marginScale, y: marginScale)
            let body = SKPhysicsBody(polygonFrom: path.copy(using: &transform)!)
            body.allowsRotation = false
            body.friction = 0.2
            body.linearDamping = 50
            body.categoryBitMask = CollisionTypes.smallCircle.rawValue
            body.collisionBitMask = CollisionTypes.smallCircle.rawValue
            body.fieldBitMask = CollisionTypes.smallField.rawValue
            return body
        }()
    }



    private func addIcon(preset: HabitPreset) {
        let iconSprite = SKSpriteNode(imageNamed: preset.icon)
        iconSprite.size = CGSize(width: 24, height: 24)
        iconSprite.position.y = 10
        addChild(iconSprite)
    }

    private func addText(preset: HabitPreset) {
        let label = label
        label.text = preset.title
        label.position.y = -10
        addChild(label)
    }


}
