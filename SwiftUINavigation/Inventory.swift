import IdentifiedCollections
import SwiftUI

struct Item: Equatable, Identifiable {
  let id = UUID()
  var name: String
  var color: Color?
  var status: Status
  
  enum Status: Equatable {
    case inStock(quantity: Int)
    case outOfStock(isOnBackOrder: Bool)
    
    var isInStock: Bool {
      guard case .inStock = self else { return false }
      return true
    }
  }
  
  struct Color: Equatable, Hashable {
    var name: String
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    static var defaults: [Self] = [
      .red,
      .green,
      .blue,
      .black,
      .yellow,
      .white,
    ]
    
    static let red = Self(name: "Red", red: 1)
    static let green = Self(name: "Green", green: 1)
    static let blue = Self(name: "Blue", blue: 1)
    static let black = Self(name: "Black")
    static let yellow = Self(name: "Yellow", red: 1, green: 1)
    static let white = Self(name: "White", red: 1, green: 1, blue: 1)
    
    var swiftUIColor: SwiftUI.Color {
      .init(red: self.red, green: self.green, blue: self.blue)
    }
  }
}

class InventoryViewModel: ObservableObject {
  @Published var inventory: IdentifiedArrayOf<Item>
  @Published var itemToAdd: Item?
  @Published var itemToDelete: Item?
  
  init(
    inventory: IdentifiedArrayOf<Item> = [],
    itemToAdd: Item? = nil,
    itemToDelete: Item? = nil
  ) {
    self.inventory = inventory
    self.itemToAdd = itemToAdd
    self.itemToDelete = itemToDelete
  }
  
  func add(item: Item) {
    withAnimation {
      _ = self.inventory.append(item)
      self.itemToAdd = nil
    }
  }
  
  func delete(item: Item) {
    withAnimation {
      _ = self.inventory.remove(id: item.id)
    }
  }
  
  func addButtonTapped() {
    self.itemToAdd = .init(
      name: "",
      color: nil,
      status: .inStock(quantity: 1)
    )
    
    // Let's simulate that we're doing some Machine Learning operations that we can use to predict what the user is going to fill in the form.
    // we will fire off a task
    // whenever you're running a Task like this, you don't know what thread it's running on, so you need to make sure to only update the @Published field of a view model in the main thread. or main actor.
    Task { @MainActor in
      try await Task.sleep(nanoseconds: 500 * NSEC_PER_MSEC)
      // assuming after 500 millisec, the AI told returns a predicted name to be added.
      self.itemToAdd?.name = "Bluetooth keyboard"
    }
  }
  
  func cancelButtonTapped() {
    self.itemToAdd = nil
  }
  
  func deleteButtonTapped(item: Item) {
    self.itemToDelete = item
  }
}

struct InventoryView: View {
  @ObservedObject var viewModel: InventoryViewModel
  // @State var addItemIsPresented = false
  
  var body: some View {
    List {
      ForEach(self.viewModel.inventory) { item in
        HStack {
          VStack(alignment: .leading) {
            Text(item.name)
            
            switch item.status {
            case let .inStock(quantity):
              Text("In stock: \(quantity)")
            case let .outOfStock(isOnBackOrder):
              Text("Out of stock" + (isOnBackOrder ? ": on back order" : ""))
            }
          }
          
          Spacer()
          
          if let color = item.color {
            Rectangle()
              .frame(width: 30, height: 30)
              .foregroundColor(color.swiftUIColor)
              .border(Color.black, width: 1)
          }
          
          Button(
            action: {
              self.viewModel.deleteButtonTapped(item: item)
            }
          ) {
            Image(systemName: "trash.fill")
          }
          .padding(.leading)
        }
        .buttonStyle(.plain)
        .foregroundColor(item.status.isInStock ? nil : Color.gray)
      }
    }
    .alert(
      title: { Text($0.name) },
      presenting: self.$viewModel.itemToDelete,
      actions: { item in
        Button("Delete", role: .destructive) {
          self.viewModel.delete(item: item)
        }
      },
      message: { _ in
        Text("Are you sure you want to delete this item?")
      }
    )
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button("Add") { self.viewModel.addButtonTapped() }
      }
    }
    .navigationBarTitle("Inventory")
    .sheet(unwrap: self.$viewModel.itemToAdd) { $itemToAdd in
      NavigationView {
        ItemView(item: $itemToAdd)
          .navigationTitle("Add")
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                self.viewModel.cancelButtonTapped()
              }
            }
            ToolbarItem(placement: .primaryAction) {
              Button("Save") {
                self.viewModel.add(item: itemToAdd)
              }
            }
          }
      }
    }
  }
}

struct InventoryView_Previews: PreviewProvider {
  static var previews: some View {
    
    NavigationView {
      InventoryView(
        viewModel: .init(
          inventory: [
            Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100)),
            Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20)),
            Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true)),
            Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false)),
          ],
//          itemToAdd: .init(name: "Mouse", color: nil, status: .inStock(quantity: 1)),
          itemToDelete: nil
        )
      )
    }
  }
}
