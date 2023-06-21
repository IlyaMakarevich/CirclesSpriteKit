//
//  Extensions.swift
//  CirclesSpriteKit
//
//  Created by Ilya Makarevich on 6/15/23.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }

    static var red: UIColor {
        return UIColor(red: 255, green: 59, blue: 48)
    }

    static var orange: UIColor {
        return UIColor(red: 255, green: 149, blue: 0)
    }

    static var yellow: UIColor {
        return UIColor(red: 255, green: 204, blue: 0)
    }

    static var green: UIColor {
        return UIColor(red: 76, green: 217, blue: 100)
    }

    static var tealBlue: UIColor {
        return UIColor(red: 90, green: 200, blue: 250)
    }

    static var blue: UIColor {
        return UIColor(red: 0, green: 122, blue: 255)
    }

    static var purple: UIColor {
        return UIColor(red: 88, green: 86, blue: 214)
    }

    static var pink: UIColor {
        return UIColor(red: 255, green: 45, blue: 85)
    }

    static let colors: [UIColor] = [.red, .orange, .yellow, .green, .tealBlue, .blue, .purple, .pink]

}

extension UIImage {

    static let names: [String] = ["water plants",
                                  "put the bin out",
                                  "eat a health y meal",
                                  "eat fruits and vegies",
                                  "drink water",
                                  "brush And floss",
                                  "take vitamins",
                                  "limit caffeine",
                                  "check my posture",
                                  "hit the gym",
                                  "exercise",
                                  "go for a walk",
                                  "go for a run",
                                  "go for a ride",
                                  "go for a swim",
                                  "practic eyoga",
                                  "do stretching",
                                  "tidy the house",
                                  "pay bills",
                                  "track my expenses",
                                  "make my bed",
                                  "do the laundry",
                                  "cook more often",
                                  "meditate"]
}





extension Array {

    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }

}
