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
	@Published var isSaving = true
	
	enum Route: Equatable {
		case deleteAlert
		case duplicate(ItemViewModel)
		case edit(ItemViewModel)
		
		static func == (lhs: Self, rhs: Self) -> Bool {
			switch (lhs, rhs) {
			case (.deleteAlert, .deleteAlert):
				return true
			case let (.duplicate(lhs), .duplicate(rhs)):
				return lhs === rhs
			case let (.edit(lhs), .edit(rhs)):
				return lhs === rhs
			case (.deleteAlert, _), (.duplicate, _), (.edit, _):
				return false
			}
		}
	}
	
	var onDelete: () -> Void = {}
	var onDuplicate: (Item) -> Void = { _ in }
	
	var id: Item.ID { self.item.id }
	
	init(item: Item) {
		self.item = item
	}
	
	func deleteButtonTapped() {
		self.route = .deleteAlert
	}
	
	func deleteConfirmationButtonTapped() {
		self.onDelete()
		self.route = nil
	}
	
	//  func editButtonTapped() {
	//    self.route = .edit(self.item)
	//  }
	
	func setEditNavigation(isActive: Bool) {
		self.route = isActive ? .edit(.init(item: self.item)) : nil
	}
	
	func cancelButtonTapped() {
		self.route = nil
	}
	
	func duplicateButtonTapped() {
		self.route = .duplicate(.init(item: self.item.duplicate()))
	}
	
	func edit(item: Item) {
		self.isSaving = true
		Task { @MainActor in
			try await Task.sleep(nanoseconds: NSEC_PER_SEC)
			
			self.isSaving = false
			self.item = item
			self.route = nil
		}
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
		// Since we're not longer using the binding in the destination
		// We should switch to a NavigationLink initializer that returns a honest value just as we did with the .sheet and .popover.
		// SwiftUI doesn't provide one, check the episode exercise for how to do it.
		NavigationLink(
			unwrap: self.$viewModel.route,
			case: /ItemRowViewModel.Route.edit,
			onNavigate: self.viewModel.setEditNavigation(isActive:),
			destination: { $itemViewModel in
				ItemView(viewModel: itemViewModel)
					.navigationBarTitle("Edit")
					.navigationBarBackButtonHidden(true)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Cancel") {
								self.viewModel.cancelButtonTapped()
							}
						}
						
						ToolbarItem(placement: .primaryAction) {
							Button("Save") {
								self.viewModel.edit(item: itemViewModel.item)
							}
						}
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
			.popover(
				item: self.$viewModel.route.case(/ItemRowViewModel.Route.duplicate)
			) { itemViewModel in
				NavigationView {
					ItemView(viewModel: itemViewModel)
						.navigationTitle("Duplicate")
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button("Cancel") {
									self.viewModel.cancelButtonTapped()
								}
							}
							
							ToolbarItem(placement: .primaryAction) {
								HStack {
									if self.viewModel.isSaving {
										ProgressView()
									}
									Button("Save") {
										self.viewModel.duplicate(item: itemViewModel.item)
									}
								}
								.disabled(self.viewModel.isSaving)
							}
						}
				}
				.frame(minWidth: 300, minHeight: 500)
			}
		}
	}
}

