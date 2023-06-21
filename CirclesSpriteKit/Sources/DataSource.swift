//
//  DataSource.swift
//  CirclesSpriteKit
//
//  Created by Ilya Makarevich on 6/20/23.
//

import Foundation

class DataSource {
    static func generate() -> Data {
        let oldAim = Aim(name: "Old Aim",
                         dayRange: 20.0..<366.0, habits: [
                            .init(name: "1", dayRange: 20.0..<366.0, preset: .sport),
                            .init(name: "2", dayRange: 23.0..<366.0, preset: .read),
                            .init(name: "3", dayRange: 25.0..<366.0, preset: .water)
        ])

        let todayAim = Aim(name: "Today Aim",
                           dayRange: 187.0..<366.0, habits: [
                            .init(name: "4", dayRange: 187.0..<366.0, preset: .water),
                            .init(name: "5", dayRange: 189.0..<366.0, preset: .read),
                            .init(name: "6", dayRange: 193.0..<366.0, preset: .sport)
        ])

        let futureAim = Aim(name: "Future Aim",
                            dayRange: 320.0..<366.0, habits: [
                                .init(name: "7", dayRange: 320.0..<366.0, preset: .sport),
                                .init(name: "8", dayRange: 326.0..<366.0, preset: .read),
                                .init(name: "9", dayRange: 338.0..<365.0, preset: .sport)
        ])

        return .init(aims: [oldAim, todayAim, futureAim])
    }
}

struct Data {
    var aims: [Aim]
}

struct Aim: Hashable {
    var name: String
    var dayRange: Range<Float>
    var habits: [Habit]
}

struct Habit: Hashable {
    var name: String
    var dayRange: Range<Float>
    var preset: HabitPreset
}

public enum HabitPreset: CaseIterable {
    case sport
    case read
    case water

    var title: String {
        switch self {
        case .sport:
            return "Sport"
        case .read:
            return "Read book"
        case .water:
            return "Drink water"
        }
    }

    var icon: String {
        switch self {
        case .sport:
            return "sport"
        case .read:
            return "read"
        case .water:
            return "water"
        }
    }
}
