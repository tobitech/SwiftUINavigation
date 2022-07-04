//
//  ItemRow.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import SwiftUI

class ItemRowViewModel: Identifiable, ObservableObject {
  @Published var item: Item
  
  // this is optional because there is a situtation that we don't need to present
  // any of the routes.
  @Published var route: Route?
  
  enum Route: Equatable {
    case deleteAlert
    case duplicate(Item)
    case edit(Item)
  }
  
  var onDelete: () -> Void = {}
  var onDuplicate: (Item) -> Void = { _ in }
  
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
  
//  func editButtonTapped() {
//    self.route = .edit(self.item)
//  }
  
  func setEditNavigation(isActive: Bool) {
    self.route = isActive ? .edit(self.item) : nil
  }
  
  func cancelButtonTapped() {
    self.route = nil
  }
  
  func duplicateButtonTapped() {
    self.route = .duplicate(self.item.duplicate())
  }
  
  func edit(item: Item) {
    self.item = item
    self.route = nil
  }
  
  func duplicate(item: Item) {
    self.onDuplicate(item)
    self.route = nil
  }
}

extension Item {
  func duplicate() -> Self {
    .init(name: self.name, color: self.color, status: self.status)
  }
}

struct ItemRowView: View {
  
  @ObservedObject var viewModel: ItemRowViewModel
  
  var body: some View {
    NavigationLink(
      isActive: Binding(
        get: {
          guard case .edit = self.viewModel.route else {
            return false
          }
          return true
        },
        set: self.viewModel.setEditNavigation(isActive:)
      ),
      destination: {
        // we're using this custom Binding initializer we made so that we can get a honest value from the route case.
        // instead of an optional binding.
        if let $item = Binding(unwrap: self.$viewModel.route.case(/ItemRowViewModel.Route.edit)) {
          ItemView(item: $item)
        }
      }
    ) {
      
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
        
        Button(action: { self.viewModel.duplicateButtonTapped() }) {
          Image(systemName: "square.fill.on.square.fill")
        }
        .padding(.leading)
        
        //      Button(action: { self.viewModel.editButtonTapped() }) {
        //        Image(systemName: "pencil")
        //      }
        //      .padding(.leading)
        
        Button(action: { self.viewModel.deleteButtonTapped() }) {
          Image(systemName: "trash.fill")
        }
        .padding(.leading)
      }
      .buttonStyle(.plain)
      .foregroundColor(self.viewModel.item.status.isInStock ? nil : Color.gray)
      .alert(
        self.viewModel.item.name,
        isPresented: self.$viewModel.route.isPresent(/ItemRowViewModel.Route.deleteAlert),
        actions: {
          Button("Delete", role: .destructive) {
            self.viewModel.deleteConfirmationButtonTapped()
          }
        },
        message: {
          Text("Are you sure you want to delete this item?")
        }
      )
      //    .sheet(unwrap: self.$viewModel.route.case(/ItemRowViewModel.Route.edit)) { $item in
      //      NavigationView {
      //        ItemView(item: $item)
      //          .navigationTitle("Edit")
      //          .toolbar {
      //            ToolbarItem(placement: .cancellationAction) {
      //              Button("Cancel") {
      //                self.viewModel.cancelButtonTapped()
      //              }
      //            }
      //
      //            ToolbarItem(placement: .primaryAction) {
      //              Button("Save") {
      //                self.viewModel.edit(item: item)
      //              }
      //            }
      //          }
      //      }
      //    }
      .popover(unwrap: self.$viewModel.route.case(/ItemRowViewModel.Route.duplicate)) { $item in
        NavigationView {
          ItemView(item: $item)
            .navigationTitle("Duplicate")
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                  self.viewModel.cancelButtonTapped()
                }
              }
              
              ToolbarItem(placement: .primaryAction) {
                Button("Add") {
                  self.viewModel.duplicate(item: item)
                }
              }
            }
        }
        .frame(minWidth: 300, minHeight: 500)
      }
    }
  }
}

