//
//  ContentView.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import SwiftUI

struct ContentView: View {
  
  @State var selection = 1
  
  var body: some View {
    TabView(selection: self.$selection) {
      Button("Go to Tab 2") {
        self.selection = 2
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
    ContentView(selection: 3)
  }
}

struct ContainerView: View {
  
  var selectedTab = 1
  
  var body: some View {
    ContentView(selection: selectedTab)
  }
}
