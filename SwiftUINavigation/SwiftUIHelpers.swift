//
//  SwiftUIHelpers.swift
//  SwiftUINavigation
//
//  Created by Oluwatobi Omotayo on 03/07/2022.
//

import CasePaths
import SwiftUI

extension Binding {
  func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    .init(
      get: { self.wrappedValue != nil },
      set: { isPresented in
        if !isPresented {
          self.wrappedValue = nil
        }
      }
    )
  }
  
  // check to see if something is present within a case path.
  func isPresent<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Bool> where Value == Enum? {
    Binding<Bool>(
      get: {
        // we are using .some in the pattern matching to denote where the
        // value is not nil - because viewmodel.route is optional
//        if case .some(.deleteAlert) = self.viewModel.route {
        if let wrappedValue = self.wrappedValue,
            casePath.extract(from: wrappedValue) != nil {
          return true
        } else {
          return false
        }
      },
      set: { isPresented in
        if !isPresented {
          self.wrappedValue = nil
        }
      }
    )
  }
  
  func `case`<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Case?> where Value == Enum? {
    Binding<Case?>(
      get: {
        guard let wrappedValue = self.wrappedValue, let `case` = casePath.extract(from: wrappedValue) else { return nil }
        return `case`
      },
      set: { `case` in
        if let `case` = `case` {
          self.wrappedValue = casePath.embed(`case`)
        } else {
          self.wrappedValue = nil
        }
      }
    )
  }
}

extension View {
  func alert<A: View, M: View, T>(
    title: (T) -> Text,
    presenting data: Binding<T?>,
    @ViewBuilder actions: @escaping (T) -> A,
    @ViewBuilder message: @escaping (T) -> M
  ) -> some View {
    self.alert(
      data.wrappedValue.map(title) ?? Text(""),
      isPresented: data.isPresent(),
      presenting: data.wrappedValue,
      actions: actions,
      message: message
    )
  }
  
  func confirmationDialog<A: View, M: View, T>(
    title: (T) -> Text,
    titleVisibility: Visibility = .automatic,
    presenting data: Binding<T?>,
    @ViewBuilder actions: @escaping (T) -> A,
    @ViewBuilder message: @escaping (T) -> M
  ) -> some View {
    self.confirmationDialog(
      data.wrappedValue.map(title) ?? Text(""),
      isPresented: data.isPresent(),
      titleVisibility: titleVisibility,
      presenting: data.wrappedValue,
      actions: actions,
      message: message
    )
  }
}

struct IfCaseLet<Enum, Case, Content>: View where Content: View {
  
  let binding: Binding<Enum>
  let casePath: CasePath<Enum, Case>
  let content: (Binding<Case>) -> Content
  
  init(
    _ binding: Binding<Enum>,
    pattern casePath: CasePath<Enum, Case>,
    @ViewBuilder content: @escaping (Binding<Case>) -> Content
  ) {
    self.binding = binding
    self.casePath = casePath
    self.content = content
  }
  
  var body: some View {
    if let `case` = self.casePath.extract(from: self.binding.wrappedValue) {
      self.content(
        Binding(
          get: { `case` },
          set: { binding.wrappedValue = self.casePath.embed($0) }
        )
      )
    }
  }
  
}

// Apple provides a failable initialiser for Binding but currently has a bug which causes some crashing when used.
// So we decided to make our own that doesn't crash.
extension Binding {
  init?(unwrap binding: Binding<Value?>) {
    guard let wrappedValue = binding.wrappedValue else { return nil }
    self.init(
      get: { wrappedValue },
      set: { binding.wrappedValue = $0 }
    )
  }
}

extension View {
  func sheet<Value, Content>(
    unwrap optionalValue: Binding<Value?>,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
  ) -> some View where Value: Identifiable, Content: View {
    self.sheet(
      item: optionalValue
    ) { _ in
      if let value = Binding(unwrap: optionalValue) {
        content(value)
      }
    }
  }
  
  func popover<Value, Content>(
    unwrap optionalValue: Binding<Value?>,
    @ViewBuilder content: @escaping (Binding<Value>) -> Content
  ) -> some View where Value: Identifiable, Content: View {
    self.popover(
      item: optionalValue
    ) { _ in
      if let value = Binding(unwrap: optionalValue) {
        content(value)
      }
    }
  }
}
