//
//  SwiftUINavigationApp.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

@main
struct SwiftUINavigationApp: App {
  
  let keyboard = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
  
  var body: some Scene {
    
    var editedKeyboard = keyboard
    editedKeyboard.name = "Bluetooth keyboard"
    editedKeyboard.status = .inStock(quantity: 1000)
    
    return WindowGroup {
      ContentView(
        viewModel: .init(
          inventoryViewModel: .init(
            inventory: [
              .init(item: keyboard),
              .init(item: Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20))),
              .init(item: Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true))),
              .init(item: Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false))),
            ],
            route: .add(editedKeyboard) // .init(name: "", color: nil, status: .inStock(quantity: 1)),
          ),
          selectedTab: .inventory
        )
      )
    }
  }
}
