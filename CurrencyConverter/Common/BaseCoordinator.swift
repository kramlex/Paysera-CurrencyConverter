//
//  BaseCoordinator.swift
//  CurrencyConverter
//
//  Created by mdubkov on 12.08.2022.
//

import UIKit

class BaseCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
  /*
   * Array of child coordinators you can have
   */
  var childCoordinators: [Coordinator] = []
  
  /*
   * Completion when you need to configure what should happens when
   * coordinator is deiniting.
   */
  var completionHandler: (() -> Void)?
  fileprivate var clearHandler: (() -> Void)?
  
  /*
   * Main coordinator window
   */
  let window: UIWindow
  
  /*
   * Coordinator navigation controller
   */
  var navigationController: UINavigationController?
  
  init(window: UIWindow) {
    self.window = window
  }
  
  /*
   * Adds passed coordinator as a child to base one.
   *
   * Call this method when you need to display new feature-controller.
   */
  func addDependency<Child>(_ coordinator: Child, completion: (() -> Void)? = nil) -> Child where Child: BaseCoordinator {
    for element in childCoordinators.compactMap({ $0 as? Child }) {
      if element === coordinator { return element }
    }
    coordinator.completionHandler = { [weak self, weak coordinator] in
      self?.removeDependency(coordinator)
      completion?()
    }
    childCoordinators.append(coordinator)
    return coordinator
  }
  
  /*
   * Calls every child coordinator completion clear handler.
   *
   * Usually use it on logout or on deeplink handling.
   * Because if this isn't done, coordinators may remain in memory, which will lead to leaks.
   */
  func clear() {
    clearHandler?()
    childCoordinators.forEach {
      $0.clear()
    }
    childCoordinators.removeAll()
  }
  
  /*
   * Erases coordinators dependencies stack.
   */
  private func removeDependency(_ coordinator: Coordinator?) {
    clearHandler?()
    guard
      childCoordinators.isEmpty == false,
      let coordinator = coordinator
    else { return }
    
    for (index, element) in childCoordinators.enumerated() {
      if element === coordinator {
        childCoordinators.remove(at: index)
        break
      }
    }
  }
  
  /*
   * Implement this method in each inheritor as an initial method.
   *
   * You should also call it after adding coordinator to dependencies.
   */
  func start() {
    //
  }
  
  /*
   * Creates new navigation controller and makes it as a new root.
   *
   * Use it when you need to add new controller (based on design and business logic)
   * with its own navigation.
   */
  @discardableResult
  func beginInNewNavigation(_ controller: UIViewController) -> UINavigationController {
    let newNavigationController = UINavigationController()
    self.navigationController = newNavigationController
    
    newNavigationController.setViewControllers([controller], animated: false)
    
    self.window.rootViewController = newNavigationController
    
    self.clearHandler = { [weak self] in
      self?.popToRoot()
    }
    
    return newNavigationController
  }
  
  /*
   * Pushes passed view controller and saves currently displayed view
   * controller on the top of the stack to route back after new controller
   * will be erased.
   *
   * Use it when you need to add controller (based on design and business logic)
   * based on exists navigation.
   */
  func beginInExistNavigation(_ controller: UIViewController) {
    let prevController = self.navigationController?.topViewController
    self.clearHandler = { [weak self, weak prevController] in
      if let prev = prevController {
        self?.popToViewController(controller: prev)
      }
    }
    navigationController?.pushViewController(controller, animated: true)
  }
  
  /*
   * Go back to previous view controller
   */
  private func popToViewController(controller vc: UIViewController, animated: Bool = true) {
    navigationController?.popToViewController(vc, animated: animated)
  }
  
  /*
   * Go back to view controller of specific class
   */
  private func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = navigationController?.viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      navigationController?.popToViewController(vc, animated: animated)
    }
  }
  
  /*
   * Pop to root view controller
   */
  private func popToRoot() {
    navigationController?.popToRootViewController(animated: true)
  }
}
