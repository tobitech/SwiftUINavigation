//
//  SwiftUINavigationApp.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

@main
struct SwiftUINavigationApp: App {
  
//  let keyboard = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
  
  var body: some Scene {
    WindowGroup {
      ContentView(
        viewModel: .init(
          inventoryViewModel: .init(
            inventory: [
              Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20)),
              Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true)),
              Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false)),
            ],
            itemToAdd: nil, // .init(name: "", color: nil, status: .inStock(quantity: 1)),
            itemToDelete: nil
          ),
          selectedTab: .inventory
        )
      )
    }
  }
}
