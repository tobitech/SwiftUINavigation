//
//  SwiftUINavigationTests.swift
//  SwiftUINavigationTests
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import XCTest
@testable import SwiftUINavigation

class SwiftUINavigationTests: XCTestCase {
  func testAddItem() throws {
    let viewModel = InventoryViewModel()
    viewModel.addButtonTapped()
    
    // XCTAssertNotNil(viewModel.itemToAdd)
    
    let itemToAdd = try XCTUnwrap(viewModel.itemToAdd)
    
    viewModel.add(item: itemToAdd)
    
    XCTAssertNil(viewModel.itemToAdd)
    XCTAssertEqual(viewModel.inventory.count, 1)
    XCTAssertEqual(viewModel.inventory[0].item, itemToAdd)
  }
  
  func testDeleteItem() {
    let viewModel = InventoryViewModel(
      inventory: [
        .init(item: Item(name: "Keyboard", color: .yellow, status: .inStock(quantity: 1)))
      ]
    )
    
    viewModel.inventory[0].deleteButtonTapped()
    
    XCTAssertEqual(viewModel.inventory[0].route, .deleteAlert)
    
    viewModel.inventory[0].deleteConfirmationButtonTapped()
    
    XCTAssertEqual(viewModel.inventory.count, 0)
  }
  
  func testDuplicate() throws {
    let item = Item(name: "Keyboard", color: .yellow, status: .inStock(quantity: 1))
    let viewModel = InventoryViewModel(
      inventory: [
        .init(item: item)
      ]
    )
    
    viewModel.inventory[0].duplicateButtonTapped()
    
    // the below assertion fails because of difference in id
    // we will test something else until we can control that dependency.
//    XCTAssertEqual(viewModel.inventory[0].route, .duplicate(item))
    
    // We can hide some of the messiness of this in a helper.
    // Check the episode's exercise for this.
    XCTAssertNotNil(
      (/ItemRowViewModel.Route.duplicate).extract(from: try XCTUnwrap(viewModel.inventory[0].route))
    )
    
    let dupe = item.duplicate()
    viewModel.inventory[0].duplicate(item: dupe)
    
    XCTAssertEqual(viewModel.inventory.count, 2)
    XCTAssertEqual(viewModel.inventory[0].item, item)
    XCTAssertEqual(viewModel.inventory[1].item, dupe)
    XCTAssertNil(viewModel.inventory[0].route)
  }
}
