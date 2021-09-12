//
//  ViewControllerExtension.swift
//  ApplePayIntegeration
//
//  Created by Faraz Haider on 12/09/2021.
//

import UIKit

@objc extension UIViewController{
    
    /// Returns the most recently presented UIViewController (visible).
    @objc public func findLastPresentedViewController() -> UIViewController? {
        func findTopLevelViewController(_ viewController: UIViewController) -> UIViewController? {
            if let vc = viewController.presentedViewController {
                return findTopLevelViewController(vc)
            } else if let vc = viewController as? UISplitViewController  {
                if let vc = vc.viewControllers.last {
                    return findTopLevelViewController(vc)
                }
                return vc
            } else if let vc = viewController as? UINavigationController {
                if let vc = vc.topViewController {
                    return findTopLevelViewController(vc)
                }
                return vc
            } else if let vc = viewController as? UITabBarController {
                if let vc = vc.selectedViewController {
                    return findTopLevelViewController(vc)
                }
                return vc
            } else {
                return viewController
            }
        }

        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            return findTopLevelViewController(rootViewController)
        }

        return nil
    }
    
    
    public func show(_ viewController: UIViewController) {
        navigationController?.show(viewController, sender: self)
    }
    
    public func backToPrevious(animated: Bool = true) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: animated, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: animated)
        }
    }
    
    public func backToRoot(animated: Bool = true) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: animated, completion: nil)
        } else {
            _ = navigationController?.popToRootViewController(animated: animated)
        }
    }
    
    public func present(_ viewControllerToPresent: UIViewController, completion: @escaping (() -> ())) {
        present(viewControllerToPresent, animated: true, completion: completion)
    }

    public func present(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
//    public func presentTranslucent(_ viewController: UIViewController, modalTransitionStyle: UIModalTransitionStyle = .coverVertical, animated flag: Bool = true, completion: (() -> ())? = nil) {
//        viewController.modalPresentationStyle = .custom
//        viewController.modalTransitionStyle = UIDevice.iOS8x ? modalTransitionStyle : .crossDissolve
//        // Very important
//        view.window?.rootViewController?.modalPresentationStyle = UIDevice.iOS8x ? .fullScreen : .currentContext
//        present(viewController, animated: flag, completion: completion)
//    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
    
    public func dismissToTop(animated: Bool = true, completion: (() -> Void)? = nil) {
        var presentedViewController = self
        while let presentingViewController = presentedViewController.presentingViewController {
            presentedViewController = presentingViewController
        }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
    

    public func addChild(asChildViewController viewController: UIViewController, diseredView : UIView) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        diseredView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = diseredView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }

    
    private func removeChild(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
 }
