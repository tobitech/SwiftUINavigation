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
  @State var newColors: [Item.Color] = []
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
      
      if !self.newColors.isEmpty {
        Section(header: Text("New colors")) {
          ForEach(self.newColors, id: \.name) { color in
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
    // we could have use .onAppear but this new modifier was provided .task, which allows us to spin off some asychronous work that is tied to the life cycle of the view.
    .task {
      do {
        try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 500)
        self.newColors = [
          .init(name: "Pink", red: 1, green: 0.7, blue: 0.7)
        ]
      } catch {
        
      }
    }
  }
}

class ItemViewModel: Identifiable, ObservableObject {
  @Published var item: Item
  
  var id: Item.ID { self.item.id }
  
  init(item: Item) {
    self.item = item
  }
}


struct ItemView: View {
//  @Binding var item: Item
  @ObservedObject var viewModel: ItemViewModel
  @State var nameIsDuplicate = false
  
  var body: some View {
    Form {
      TextField("Name", text: self.$viewModel.item.name)
        .background(self.nameIsDuplicate ? Color.red.opacity(0.1) : nil)
        .onChange(of: self.viewModel.item.name) { newName in
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
        ColorPickerView(color: self.$viewModel.item.color)
      } label: {
        HStack {
          Text("Color")
          Spacer()
          if let color = self.viewModel.item.color {
            Rectangle()
              .frame(width: 30, height: 30)
              .foregroundColor(color.swiftUIColor)
              .border(Color.black, width: 1)
          }
          Text(self.viewModel.item.color?.name ?? "None")
            .foregroundColor(.gray)
        }
      }

      
      IfCaseLet(self.$viewModel.item.status, pattern: /Item.Status.inStock) { $quantity in
        Section(header: Text("In stock")) {
          Stepper("Quantity: \(quantity)", value: $quantity)
          Button("Mark as sold out") {
            self.viewModel.item.status = .outOfStock(isOnBackOrder: false)
          }
        }
      }
      
      IfCaseLet(self.$viewModel.item.status, pattern: /Item.Status.outOfStock) { $isOnBackOrder in
        Section(header: Text("In stock")) {
          Toggle("Is on back order?", isOn: $isOnBackOrder)
          Button("Is back in stock!") {
            self.viewModel.item.status = .inStock(quantity: 1)
          }
        }
      }
      
    }
  }
}

struct ItemView_Previews: PreviewProvider {
  
  static var previews: some View {
    NavigationView {
      ItemView(
        viewModel: .init(
          item: Item(
            name: "",
            color: nil,
            status: .inStock(quantity: 1)
          )
        )
      )
    }
  }
}
