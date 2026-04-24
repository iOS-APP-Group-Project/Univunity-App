//
//  HapticManager.swift
//  Univinity
//
//  Created by Sara Kanu on 4/23/26.
//
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func notifySuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func notifyWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
