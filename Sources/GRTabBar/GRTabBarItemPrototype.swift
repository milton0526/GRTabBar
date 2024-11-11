//
//  GRTabBarItemPrototype.swift
//
//  Created by Milton Liu on 2024/5/23.
//

import Foundation
import UIKit

public protocol GRTabBarItemPrototype: Hashable {
  var title: String? { get }
  var image: UIImage { get }
  var color: UIColor { get }
  var selectedImage: UIImage { get }
  var selectedColor: UIColor { get }
}

public extension GRTabBarItemPrototype {
  var color: UIColor {
    return .systemGray
  }
}
