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
  @Published var inventory: IdentifiedArrayOf<ItemRowViewModel>
  @Published var itemToAdd: Item?
  
  init(
    inventory: IdentifiedArrayOf<ItemRowViewModel> = [],
    itemToAdd: Item? = nil
  ) {
    self.inventory = inventory
    self.itemToAdd = itemToAdd
  }
  
  func add(item: Item) {
    withAnimation {
      let viewModel = ItemRowViewModel(item: item)
      viewModel.onDelete = { [weak self] in
        self?.delete(item: item)
      }
      _ = self.inventory.append(viewModel)
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
}

struct InventoryView: View {
  @ObservedObject var viewModel: InventoryViewModel
  // @State var addItemIsPresented = false
  
  var body: some View {
    List {
      ForEach(
        self.viewModel.inventory,
        content: ItemRowView.init(viewModel:)
      )
    }
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
    
    let keyboard = Item(name: "Keyboard", color: .blue, status: .inStock(quantity: 100))
    
    NavigationView {
      InventoryView(
        viewModel: .init(
          inventory: [
            .init(item: keyboard),
            .init(item: Item(name: "Charger", color: .yellow, status: .inStock(quantity: 20))),
            .init(item: Item(name: "Phone", color: .green, status: .outOfStock(isOnBackOrder: true))),
            .init(item: Item(name: "Headphones", color: .green, status: .outOfStock(isOnBackOrder: false))),
          ]
//          itemToAdd: .init(name: "Mouse", color: nil, status: .inStock(quantity: 1)),
        )
      )
    }
  }
}
