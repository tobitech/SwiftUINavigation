//
//  ItemView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import SwiftUI

struct ColorPickerView: View {
  // this environment variable figures out what binding is powering th presentation of that view.
  // calling dismiss call write false or nil out that binding in order to transition away.
  @Environment(\.dismiss) var dismiss
  @Binding var color: Item.Color?
  
  var body: some View {
    Form {
      Button(action: {
        self.color = nil
        self.dismiss()
      }) {
        HStack {
          Text("None")
          Spacer()
          if self.color == nil {
            Image(systemName: "checkmark")
          }
        }
      }
      
      Section(header: Text("Default colors")) {
        ForEach(Item.Color.defaults, id: \.name) { color in
          Button(action: {
            self.color = color
            self.dismiss()
          }) {
            HStack {
              Text(color.name)
              Spacer()
              if self.color == color {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
    }
  }
}

struct ItemView: View {
  @Binding var item: Item
  @State var nameIsDuplicate = false
  
  var body: some View {
    Form {
      TextField("Name", text: self.$item.name)
        .background(self.nameIsDuplicate ? Color.red.opacity(0.1) : nil)
        .onChange(of: self.item.name) { newName in
          print(newName)
          // TODO: some async validation logic
          Task { @MainActor in
            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 300)
            self.nameIsDuplicate = newName == "Keyboard"
          }
        }
      
//      Picker("Color", selection: self.$item.color) {
//        Text("None")
//          .tag(Item.Color?.none)
//
//        ForEach(Item.Color.defaults, id: \.name) { color in
//          Text(color.name)
//          // here we're making sure the type of color passed to the tag matches that of the first item of none above.
//            .tag(Optional(color))
//        }
//      }
      
      NavigationLink {
        ColorPickerView(color: self.$item.color)
      } label: {
        HStack {
          Text("Color")
          Spacer()
          if let color = self.item.color {
            Rectangle()
              .frame(width: 30, height: 30)
              .foregroundColor(color.swiftUIColor)
              .border(Color.black, width: 1)
          }
          Text(self.item.color?.name ?? "None")
            .foregroundColor(.gray)
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
  }
}

struct ItemView_Previews: PreviewProvider {
  
  struct WrapperView: View {
    
    @State var item: Item = Item(name: "", color: nil, status: .inStock(quantity: 1))
    
    var body: some View {
      ItemView(item: $item)
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
