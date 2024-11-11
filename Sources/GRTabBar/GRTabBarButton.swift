//
//  GRTabBarButton.swift
//
//  Created by Milton Liu on 2024/5/22.
//

import UIKit

class GRTabBarButton<ItemModel>: UIControl where ItemModel: GRTabBarItemPrototype {

  let tabItem: ItemModel
  private let action: () -> Void

  enum TouchState {
    case touch
    case idle
  }

  var touchState: TouchState = .idle {
    didSet {
      guard touchState != oldValue else { return }

      switch touchState {
      case .touch:
        updateTouchAppearance()
      case .idle:
        updateIdleAppearance()
      }
    }
  }

  var badgeValue: String? {
    didSet { updateBadge() }
  }

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = tabItem.title
    label.font = .systemFont(ofSize: 10, weight: .bold)
    label.adjustsFontSizeToFitWidth = true
    return label
  }()

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(image: tabItem.image)
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 4
    stackView.isUserInteractionEnabled = false
    return stackView
  }()

  private lazy var badgeView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemRed
    view.isUserInteractionEnabled = false
    return view
  }()

  private lazy var badgeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 10, weight: .semibold)
    label.layer.masksToBounds = true
    return label
  }()

  init(tabItem: ItemModel, action: @escaping () -> Void) {
    self.tabItem = tabItem
    self.action = action
    super.init(frame: .zero)

    addSubview(stackView)
    addSubview(badgeView)
    badgeView.addSubview(badgeLabel)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    badgeView.translatesAutoresizingMaskIntoConstraints = false
    badgeLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

      imageView.widthAnchor.constraint(equalToConstant: 26),
      imageView.heightAnchor.constraint(equalToConstant: 26),

      badgeView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -2),
      badgeView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),

      badgeLabel.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: 3),
      badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 3),
      badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -3),
      badgeLabel.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: -3),
      badgeLabel.widthAnchor.constraint(greaterThanOrEqualTo: badgeLabel.heightAnchor)
    ])

    addTarget(self, action: #selector(didTouchTabItem), for: .touchUpInside)
    updateIdleAppearance()
    updateBadge()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    badgeView.layer.cornerRadius = badgeView.bounds.height / 2
  }

  @objc private func didTouchTabItem(_ sender: Any) {
    action()
  }

  private func updateTouchAppearance() {
    imageView.image = tabItem.selectedImage
    imageView.tintColor = tabItem.selectedColor
    titleLabel.textColor = tabItem.selectedColor
  }

  private func updateIdleAppearance() {
    imageView.image = tabItem.image
    imageView.tintColor = tabItem.color
    titleLabel.textColor = tabItem.color
  }

  private func updateBadge() {
    guard let badgeValue = badgeValue else {
      badgeLabel.text = nil
      badgeView.isHidden = true
      return
    }

    guard let badgeNum = Int(badgeValue) else {
      badgeLabel.text = badgeValue.count > 3
      ? badgeValue.prefix(3) + "..."
      : badgeValue
      badgeView.isHidden = false
      return
    }

    let displayCount: String?
    switch badgeNum {
    case 1...99:
      displayCount = "\(badgeNum)"
    case 100...:
      displayCount = "99+"
    default:
      displayCount = nil
    }

    badgeLabel.text = displayCount
    badgeView.isHidden = displayCount == nil
  }
}
