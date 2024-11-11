//
//  GRTabBarViewController.swift
//
//  Created by Milton Liu on 2024/5/23.
//

import UIKit

open class GRTabBarViewController<TabItem>: UIViewController, UINavigationControllerDelegate where TabItem: GRTabBarItemPrototype {

  // MARK: Properties
  private var tabItems: [TabItem: Int] = [:]
  public private(set) var viewControllers: [UIViewController] = []
  private(set) var tabBarButtons: [GRTabBarButton<TabItem>] = []

  public private(set) var selectedTab: TabItem? {
    willSet { selectedViewController?.remove() }
    didSet { updateChildViewController() }
  }

  public var selectedViewController: UIViewController? {
    return getViewController(from: selectedTab)
  }

  public weak var delegate: GRTabBarControllerDelegate?

  // MARK: View
  private let containerView = UIView()
  private let tabContainerView = UIView()

  private let topBorder: UIView = {
    let view = UIView()
    view.backgroundColor = .lightGray
    return view
  }()

  private let tabBarView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.alignment = .center
    stackView.layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 2, right: 0)
    stackView.isLayoutMarginsRelativeArrangement = true
    return stackView
  }()

  private lazy var tabBarHiddenConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
  private lazy var tabBarShownConstraint = containerView.bottomAnchor.constraint(equalTo: tabContainerView.topAnchor)

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(containerView)
    view.addSubview(tabContainerView)
    tabContainerView.addSubview(topBorder)
    tabContainerView.addSubview(tabBarView)

    containerView.translatesAutoresizingMaskIntoConstraints = false
    tabContainerView.translatesAutoresizingMaskIntoConstraints = false
    topBorder.translatesAutoresizingMaskIntoConstraints = false
    tabBarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: view.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tabBarShownConstraint,

      tabContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tabContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tabContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      topBorder.topAnchor.constraint(equalTo: tabContainerView.topAnchor),
      topBorder.heightAnchor.constraint(equalToConstant: 0.5),
      topBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      tabBarView.topAnchor.constraint(equalTo: topBorder.bottomAnchor),
      tabBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tabBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      tabBarView.heightAnchor.constraint(equalToConstant: 52)
    ])

    tabContainerView.backgroundColor = .white
  }

  public func setViewControllers(tabItems: [TabItem]?, viewControllers: [UIViewController]?) {
    guard let tabItems = tabItems, let viewControllers = viewControllers else { return }
    tabBarView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    tabItems.enumerated().forEach { index, tabItem in
      let tabButton = GRTabBarButton<TabItem>(tabItem: tabItem) { [weak self] in
        guard let self = self else { return }
        switchTab(tabItem)
      }

      tabBarButtons.append(tabButton)
      tabBarView.addArrangedSubview(tabButton)
      self.tabItems.updateValue(index, forKey: tabItem)
    }

    self.viewControllers = viewControllers
    tabBarView.layoutIfNeeded()
    switchTab(tabItems.first)
  }

  public func switchTab(_ tabItem: TabItem?) {
    guard
      tabItem != selectedTab,
      let selectVC = getViewController(from: tabItem)
    else { return }

    if delegate?.grTabBar(shouldSelect: selectVC) == false { return }

    DispatchQueue.main.async { [weak self] in
      self?.selectedTab = tabItem
    }
  }

  public func setBadgeValue(_ value: String?, on tab: TabItem) {
    guard let index = tabItems[tab] else { return }

    DispatchQueue.main.async { [weak self] in
      self?.tabBarButtons[index].badgeValue = value
    }
  }

  public func setTabBarColor(_ color: UIColor) {
    tabContainerView.backgroundColor = color
  }

  public func getViewController(from tabItem: TabItem?) -> UIViewController? {
    guard
      let tabItem = tabItem,
      let index = tabItems[tabItem] else { return nil }
    return viewControllers[index]
  }

  private func updateChildViewController() {
    guard let child = selectedViewController else { return }
    add(child)

    child.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
      child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])

    tabBarButtons.forEach { button in
      if button.tabItem == selectedTab {
        button.touchState = .touch
      } else {
        button.touchState = .idle
      }
    }

    delegate?.grTabBar(didSelect: child)
  }

  public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    let isTabBarHidden = navigationController.viewControllers
      .map { $0.hidesBottomBarWhenPushed }
      .contains(true)
    tabBarHiddenConstraint.isActive = isTabBarHidden
    tabBarShownConstraint.isActive = !isTabBarHidden
    view.layoutIfNeeded()
  }
}
