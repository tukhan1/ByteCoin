//
//  SceneDelegate.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let manager: CoinProtocol = MockCoinManager()//CoinManager(apiKey: "92143236-BED0-4E67-9FA1-C8E0FB161020")
        /*"92143236-BED0-4E67-9FA1-C8E0FB161020" "759E9A9B-E140-465D-B47B-90DF2EAA17FC" "D209ABE8-CFA8-44F7-9E19-42CC3E665B24" "7EF6C5DA-C57D-44C1-BE2B-777B3B9C7332"*/
         
           let window = UIWindow(windowScene: windowScene)
           window.rootViewController = UINavigationController(rootViewController: CurrencyVC(coinManager: manager))
        
           window.makeKeyAndVisible()
           self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

