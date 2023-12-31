//
//  ViewController.swift
//  CirclesSpriteKit
//
//  Created by Ilya Makarevich on 6/15/23.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    private let slider = UISlider()
    private let dataSource = DataSource.generate()

    @IBOutlet weak var magneticView: MagneticView! {
        didSet {
            magnetic.magneticDelegate = self
            magnetic.removeNodeOnLongPress = true
            #if DEBUG
            magneticView.showsFPS = true
            magneticView.showsDrawCount = true
            magneticView.showsQuadCount = true
            magneticView.showsPhysics = false
            magneticView.showsFields = false
            #endif
        }
    }

    @IBOutlet var dayLabel: UILabel!

    var magnetic: Magnetic {
        return magneticView.magnetic
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        dataSource.aims.forEach { aim in
            let color = UIColor.colors.randomItem()
            let node = Node(text: aim.name.capitalized, color: color, radius: 50)
            node.name = aim.name
            magnetic.addChild(node)
        }
    }


    @IBAction func sliderChanged(_ sender: UISlider) {
        dayLabel.text = String(sender.value)
        let sliderDay = sender.value.rounded()
        let aims = dataSource.aims
        var aimsInRange = [Aim]()
        var aimsNotInRange = [Aim]()

        var habitsInRange = [Habit]()

        aims.forEach {
            if $0.dayRange.contains(sliderDay) {
                aimsInRange.append($0)
            } else {
                aimsNotInRange.append($0)
            }
        }

        // Ищем хэбиты у которых подходит интервал
        aimsInRange.forEach { aim in
            let habits = aim.habits.filter {
                $0.dayRange.contains(sliderDay)
            }
            habitsInRange.append(contentsOf: habits)
        }

        // Добаляем цели и/или обновляем альфу
        aims.forEach { aim in
//            let color = UIColor.colors.randomItem()
//            let node = Node(text: aim.name.capitalized, color: color, radius: 50)
//            node.name = aim.name
//            magnetic.addChild(node)

            debugPrint("TEST aim.dayRange.lowerBound = \(aim.dayRange.lowerBound)")
            debugPrint("TEST sliderDay = \(sliderDay)")
            let alphaDaysMaxDistance: Float = 10.0
            let aim = aim
            let daysDelta = sliderDay - aim.dayRange.lowerBound
            let alpha = min(1.0, daysDelta/alphaDaysMaxDistance) 
            let roundedAlpha = round(alpha * 10) / 10.0
            debugPrint("TEST roundedAlpha = \(roundedAlpha)")
            magnetic.updateAlpha(nodeName: aim.name, alpha: CGFloat(roundedAlpha))
        }

        // Цели которые не в интервале удаляем
//        aimsNotInRange.forEach { aim in
//            let nodeToRemove = magnetic.children.first {$0.name == aim.name}
//            nodeToRemove?.removeFromParent()
//        }
    }


    @IBAction func add(_ sender: UIControl?) {
        let name = UIImage.names.randomItem()
        let color = UIColor.colors.randomItem()
        let node = Node(text: name.capitalized, color: color, radius: 50)
        node.selectedColor = UIColor.colors.randomItem()

        magnetic.addChild(node)
    }

    @IBAction func removeLat(_ sender: Any) {
        magneticView.magnetic.removeLast()
    }

    @IBAction func addSubChild(_ sender: Any) {
        magneticView.magnetic.addSubChild()
    }

    @IBAction func reset(_ sender: UIControl?) {
        magneticView.magnetic.reset()
    }

}

// MARK: - MagneticDelegate
extension ViewController: MagneticDelegate {

    func magnetic(_ magnetic: Magnetic, didSelect node: Node) {
        print("didSelect -> \(node)")
    }

    func magnetic(_ magnetic: Magnetic, didDeselect node: Node) {
        print("didDeselect -> \(node)")
    }

    func magnetic(_ magnetic: Magnetic, didRemove node: Node) {
        print("didRemove -> \(node)")
    }

}

// MARK: - ImageNode
class ImageNode: Node {
    override var image: UIImage? {
        didSet {
            texture = image.map { SKTexture(image: $0) }
        }
    }
    override func selectedAnimation() {}
    override func deselectedAnimation() {}
}


