//
//  GRTabBarControllerDelegate.swift
//
//
//  Created by Macbook-iOS on 2024/5/27.
//

import Foundation
import UIKit

public protocol GRTabBarControllerDelegate: AnyObject {

  func grTabBar(shouldSelect viewController: UIViewController) -> Bool

  func grTabBar(didSelect viewController: UIViewController)
}

public extension GRTabBarControllerDelegate {

  func grTabBar(shouldSelect viewController: UIViewController) -> Bool {
    return true
  }

  func grTabBar(didSelect viewController: UIViewController) { }
}
