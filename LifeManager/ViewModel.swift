//
//  ViewModel.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import Foundation

struct Position: Identifiable, Hashable {
  let id = UUID().uuidString
  let name: String
}

final class ViewModel: ObservableObject {
  init(positions: [Position] = ViewModel.defaultPosition) {
    self.positions = positions
    self.selectedId = positions[0].id
  }
  @Published var positions: [Position]
  @Published var selectedId: String?
  static let defaultPosition: [Position] = ["Spendings", "Meals", "Other"].map({ Position(name: $0) })
}
