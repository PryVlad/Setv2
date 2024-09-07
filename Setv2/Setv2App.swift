//
//  Setv2App.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 04.09.2024.
//

import SwiftUI

@main
struct Setv2App: App {
    @StateObject var game = SetGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: game)
        }
    }
}
