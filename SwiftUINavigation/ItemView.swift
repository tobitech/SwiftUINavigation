//
//  ItemView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

struct ItemView: View {
  
  @State var item = Item(
    name: "",
    color: nil,
    status: .inStock(quantity: 1)
  )
  
  var body: some View {
    Form {
      TextField("Name", text: self.$item.name)
      
      Picker("Color", selection: self.$item.color) {
        Text("None")
          .tag(Item.Color?.none)
        
        ForEach(Item.Color.defaults, id: \.name) { color in
          Text(color.name)
          // here we're making sure the type of color passed to the tag matches that of the first item of none above.
            .tag(Optional(color))
        }
      }
      
      switch self.item.status {
      case let .inStock(quantity: quantity):
        Section(header: Text("In stock")) {
          Stepper(
            "Quantity: \(quantity)",
            value: Binding(
              get: { quantity },
              set: { self.item.status = .inStock(quantity: $0) }
            )
          )
          Button("Mark as sold out") {
            self.item.status = .outOfStock(isOnBackOrder: false)
          }
        }
        
      case let .outOfStock(isOnBackOrder: isOnBackOrder):
        Section(header: Text("In stock")) {
          Toggle(
            "Is on back order?",
            isOn: Binding(
              get: { isOnBackOrder },
              set: { self.item.status = .outOfStock(isOnBackOrder: $0) }
            )
          )
          Button("Is back in stock!") {
            self.item.status = .inStock(quantity: 1)
          }
        }
      }
      
    }
    .navigationTitle("Add new item")
  }
}

struct ItemView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ItemView()
    }
  }
}
