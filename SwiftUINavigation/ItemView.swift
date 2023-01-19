//
//  ItemView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import SwiftUI

// Creating a ViewModel for this view would be the correct
// and ideal thing to do. check the exercise for how to.
struct ColorPickerView: View {
	@ObservedObject var viewModel: ItemViewModel
	
	// this environment variable figures out what binding is powering th presentation of that view.
	// calling dismiss call write false or nil out that binding in order to transition away.
	@Environment(\.dismiss) var dismiss
	//  @State var newColors: [Item.Color] = []
	//  @Binding var color: Item.Color?
	
	var body: some View {
		Form {
			Button(action: {
				self.viewModel.item.color = nil
				self.dismiss()
			}) {
				HStack {
					Text("None")
					Spacer()
					if self.viewModel.item.color == nil {
						Image(systemName: "checkmark")
					}
				}
			}
			
			Section(header: Text("Default colors")) {
				ForEach(Item.Color.defaults, id: \.name) { color in
					Button(action: {
						self.viewModel.item.color = color
						self.dismiss()
					}) {
						HStack {
							Text(color.name)
							Spacer()
							if self.viewModel.item.color == color {
								Image(systemName: "checkmark")
							}
						}
					}
				}
			}
			
			if !self.viewModel.newColors.isEmpty {
				Section(header: Text("New colors")) {
					ForEach(self.viewModel.newColors, id: \.name) { color in
						Button(action: {
							self.viewModel.item.color = color
							self.dismiss()
						}) {
							HStack {
								Text(color.name)
								Spacer()
								if self.viewModel.item.color == color {
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
			await self.viewModel.loadColors()
		}
	}
}

class ItemViewModel: Identifiable, ObservableObject {
	@Published var item: Item
	@Published var nameIsDuplicate = false
	@Published var newColors: [Item.Color] = []
	@Published var route: Route?
	
	var id: Item.ID { self.item.id }
	
	enum Route {
		// if we had implemented a dedicated view model for the colour picker
		// the enum case would hold associated data of the view model.
		// case colorPicker(ColorPickerViewModel)
		case colorPicker
	}
	
	init(item: Item, route: Route? = nil) {
		self.item = item
		self.route = route
		
		// we need to listen for changes in the item name to perform the asynchronous operation in this view model.
		// this is how we would do it pre-iOS 15
		// self.$item.sink(receiveValue: <#T##((Item) -> Void)##((Item) -> Void)##(Item) -> Void#>)
		// new iOS 15 API to turn any publisher to an async sequence
		// this for loop will be executed everytime `item` publisher emits
		// but we have to do await inside a funtion that supported concurrency, that's why we're wrapping it in a Task {}.
		// whether we need to do some memory management here we're not sure. we will expolore it some other time.
		Task { @MainActor in
			for await item in self.$item.values {
				try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 300)
				self.nameIsDuplicate = item.name == "Keyboard"
			}
		}
	}
	
	@MainActor
	func loadColors() async {
		do {
			try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 500)
			self.newColors = [
				.init(name: "Pink", red: 1, green: 0.7, blue: 0.7)
			]
		} catch let error {
			print(error.localizedDescription)
		}
	}
	
	func setColorPickerNavigation(isActive: Bool) {
		self.route = isActive ? .colorPicker : nil
	}
}


struct ItemView: View {
	//  @Binding var item: Item
	@ObservedObject var viewModel: ItemViewModel
	// @State var nameIsDuplicate = false
	
	var body: some View {
		Form {
			TextField("Name", text: self.$viewModel.item.name)
				.background(self.viewModel.nameIsDuplicate ? Color.red.opacity(0.1) : nil)
			//        .onChange(of: self.viewModel.item.name) { newName in
			//          print(newName)
			//          // TODO: some async validation logic
			//          Task { @MainActor in
			//            try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 300)
			//            self.nameIsDuplicate = newName == "Keyboard"
			//          }
			//        }
			
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
			
			NavigationLink(
				unwrap: self.$viewModel.route,
				case: /ItemViewModel.Route.colorPicker,
				// the onNavigate is the closure that is invoked when someone taps on the navigation link or when someone does something that should cause navigation to pop such as hitting the default back button or swipe from left edge
				// we can hand it over to our view model and let it decide how it wants to active or deactive navigation.
				onNavigate: self.viewModel.setColorPickerNavigation(isActive:),
				destination: { _ in ColorPickerView(viewModel: self.viewModel) },
				label: {
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
			)
			
			// This is currently a fire and forget version of the NavigationLink initializer, which means we can't deep link into it.
			// To remedy that we need to properly model the state of whether or not we're navigated to the colour picker.
			// right now, there is only one destination but we will assume there will be more in the future so we will model it as a first class enum.
			//      NavigationLink {
			//        ColorPickerView(viewModel: self.viewModel)
			//      } label: {
			//        HStack {
			//          Text("Color")
			//          Spacer()
			//          if let color = self.viewModel.item.color {
			//            Rectangle()
			//              .frame(width: 30, height: 30)
			//              .foregroundColor(color.swiftUIColor)
			//              .border(Color.black, width: 1)
			//          }
			//          Text(self.viewModel.item.color?.name ?? "None")
			//            .foregroundColor(.gray)
			//        }
			//      }
			
			
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
