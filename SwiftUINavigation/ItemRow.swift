//
//  ItemRow.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

class ItemRowViewModel: Identifiable, ObservableObject {
  @Published var item: Item
  
  // this is optional because there is a situtation that we don't need to present
  // any of the routes.
  @Published var route: Route?
  
  enum Route {
    case deleteAlert
    case duplicate(Item)
    case edit(Item)
  }
  
  var onDelete: () -> Void = {}
  
  var id: Item.ID { self.item.id }
  
  init(item: Item, route: Route? = nil) {
    self.item = item
    self.route = route
  }
  
  func deleteButtonTapped() {
    self.route = .deleteAlert
  }
  
  func deleteConfirmationButtonTapped() {
    self.onDelete()
  }
}

struct ItemRowView: View {
  
  @ObservedObject var viewModel: ItemRowViewModel
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(self.viewModel.item.name)
        
        switch self.viewModel.item.status {
        case let .inStock(quantity):
          Text("In stock: \(quantity)")
        case let .outOfStock(isOnBackOrder):
          Text("Out of stock" + (isOnBackOrder ? ": on back order" : ""))
        }
      }
      
      Spacer()
      
      if let color = self.viewModel.item.color {
        Rectangle()
          .frame(width: 30, height: 30)
          .foregroundColor(color.swiftUIColor)
          .border(Color.black, width: 1)
      }
      
      Button(action: { self.viewModel.deleteButtonTapped() }) {
        Image(systemName: "trash.fill")
      }
      .padding(.leading)
    }
    .buttonStyle(.plain)
    .foregroundColor(self.viewModel.item.status.isInStock ? nil : Color.gray)
    .alert(
      self.viewModel.item.name,
      isPresented: Binding(
        get: {
          // we are using .some in the pattern matching to denote where the
          // value is not nil - because viewmodel.route is optional
          if case .some(.deleteAlert) = self.viewModel.route {
            return true
          } else {
            return false
          }
        },
        set: { isPresented in
          if !isPresented {
            self.viewModel.route = nil
          }
        }
      ),
      actions: {
        Button("Delete", role: .destructive) {
          self.viewModel.deleteConfirmationButtonTapped()
        }
      },
      message: {
        Text("Are you sure you want to delete this item?")
      }
    )
  }
}

