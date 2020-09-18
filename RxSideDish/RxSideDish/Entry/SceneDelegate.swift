//
//  SceneDelegate.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/07.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let menuListReactor = MenuListReactor()
        let naviController = window?.rootViewController as? UINavigationController
        if let menuListViewController =  naviController?.viewControllers.first as? MenuListViewController {
            menuListViewController.reactor = menuListReactor
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

