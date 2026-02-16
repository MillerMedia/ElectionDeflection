//
//  ElectionDeflectionApp.swift
//  ElectionDeflection
//
//  Created by Matt Miller on 9/1/24.
//

import SwiftUI

@main
struct ElectionDeflectionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await StoreKitService.shared.loadProducts()
                    await StoreKitService.shared.checkEntitlements()
                }
                .task {
                    await StoreKitService.shared.listenForTransactionUpdates()
                }
        }
    }
}
