//
//  ItemView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import SwiftUI

struct ItemView: View {
  
//  @State var item = Item(
//    name: "",
//    color: nil,
//    status: .inStock(quantity: 1)
//  )
  @Binding var item: Item
  
  let onSave: (Item) -> Void
  let onCancel: () -> Void
  
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
      
      IfCaseLet(self.$item.status, pattern: /Item.Status.inStock) { $quantity in
        Section(header: Text("In stock")) {
          Stepper("Quantity: \(quantity)", value: $quantity)
          Button("Mark as sold out") {
            self.item.status = .outOfStock(isOnBackOrder: false)
          }
        }
      }
      
      IfCaseLet(self.$item.status, pattern: /Item.Status.outOfStock) { $isOnBackOrder in
        Section(header: Text("In stock")) {
          Toggle("Is on back order?", isOn: $isOnBackOrder)
          Button("Is back in stock!") {
            self.item.status = .inStock(quantity: 1)
          }
        }
      }
      
    }
    .navigationTitle("Add new item")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          self.onCancel()
        }
      }
      ToolbarItem(placement: .primaryAction) {
        Button("Save") {
          self.onSave(self.item)
        }
      }
    }
  }
}

struct ItemView_Previews: PreviewProvider {
  
  struct WrapperView: View {
    
    @State var item: Item = Item(name: "", color: nil, status: .inStock(quantity: 1))
    
    var body: some View {
      ItemView(item: $item, onSave: { _ in }, onCancel: { })
    }
  }
  
  static var previews: some View {
    NavigationView {
      WrapperView()
//      ItemView(
//        item: .constant(Item(name: "", color: nil, status: .inStock(quantity: 1))),
//        onSave: { _ in },
//        onCancel: { }
//      )
    }
  }
}
