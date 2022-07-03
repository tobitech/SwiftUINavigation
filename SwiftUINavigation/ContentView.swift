//
//  ContentView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

// Selection can be represented with any type that supports Hashable.
enum Tab {
  case one, two, three
}

class AppViewModel: ObservableObject {
  @Published var selectedTab: Tab
  
  init(selectedTab: Tab = .one) {
    self.selectedTab = selectedTab
  }
}

struct ContentView: View {
  
  @ObservedObject var viewModel: AppViewModel
  
  var body: some View {
    TabView(selection: self.$viewModel.selectedTab) {
      Button("Go to Tab 2") {
        self.viewModel.selectedTab = .two
      }
        .tabItem { Text("One") }
        .tag(Tab.one)
      
      Text("Two")
        .tabItem { Text("Two") }
        .tag(Tab.two)
      
      Text("Three")
        .tabItem { Text("Three") }
        .tag(Tab.three)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(viewModel: .init(selectedTab: .two))
  }
}
