//
//  Nexoft_TestCaseApp.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI
import SwiftData

@main
struct Nexoft_TestCaseApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserEntity.self
        ])
        
        let container = try! ModelContainer(for: schema)
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
