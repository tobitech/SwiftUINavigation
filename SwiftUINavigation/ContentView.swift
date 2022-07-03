//
//  ContentView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

class AppViewModel: ObservableObject {
  @Published var selectedTab: Int
  
  init(selectedTab: Int = 1) {
    self.selectedTab = selectedTab
  }
}

struct ContentView: View {
  
  @ObservedObject var viewModel: AppViewModel
  
  var body: some View {
    TabView(selection: self.$viewModel.selectedTab) {
      Button("Go to Tab 2") {
        self.viewModel.selectedTab = 2
      }
        .tabItem { Text("One") }
        .tag(1)
      
      Text("Two")
        .tabItem { Text("Two") }
        .tag(2)
      
      Text("Three")
        .tabItem { Text("Three") }
        .tag(3)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(viewModel: .init())
  }
}
