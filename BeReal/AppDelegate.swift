//
//  AppDelegate.swift
//  BeReal
//
//  Created by Auden Huang on 2/13/23.
//

import UIKit

import ParseSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ParseSwift.initialize(applicationId: "LhyuWD8pPAx9nWTkMBqvwD9o20nVdN3DxW9ltV4g",clientKey: "82Wl8B3nZ6aVS2nL6hYg4QcWYug0y0wuHHZHTgWR", serverURL: URL(string: "https://parseapi.back4app.com")!)




        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// TODO: Pt 1 - Create Test Parse Object
// https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/1%20-%20Your%20first%20Object.xcplaygroundpage/Contents.swift#L33


  // Sample Usage
  //
  // var score = GameScore()
  // score.playerName = "Kingsley"
  // score.points = 13

  // OR Implement a custom initializer (OPTIONAL i.e. NOT REQUIRED)
  // It's recommended to place custom initializers in an extension
  // to preserve the memberwise initializer.


  // Sample Usage
  //
  // let score = GameScore(playerName: "Kingsley", points: 13)
