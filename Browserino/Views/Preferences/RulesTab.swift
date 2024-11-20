// RulesTab.swift
// Browserino
//
// Created by Cline on 27.04.2024.
//

import SwiftUI
import Foundation

public struct RulesTab: View {
    @AppStorage("rules") private var rulesData: Data = Data()
    @State private var rules: [Rule] = []
    @State private var showAddRule = false

    public var body: some View {
        VStack {
            List {
                ForEach(rules) { rule in
                    HStack {
                        Text(rule.domain)
                            .fontWeight(.bold)
                        Spacer()
                        Text(rule.browserURL.lastPathComponent)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteRules)
            }
            .listStyle(PlainListStyle())

            Button(action: {
                showAddRule = true
            }) {
                Label("Add Rule", systemImage: "plus.circle")
            }
            .padding()
            .sheet(isPresented: $showAddRule) {
                AddRuleView(rules: $rules, showAddRule: $showAddRule)
            }
        }
        .onAppear(perform: loadRules)
        .padding()
    }

    private func loadRules() {
        if let decoded = try? JSONDecoder().decode([Rule].self, from: rulesData) {
            rules = decoded
        }
    }

    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            rulesData = encoded
        }
    }

    private func deleteRules(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
        saveRules()
    }
}

public struct AddRuleView: View {
    @Binding var rules: [Rule]
    @Binding var showAddRule: Bool
    @State private var domain: String = ""
    @State private var browserPath: String = ""

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Domain")) {
                    TextField("e.g., github.com", text: $domain)
                        .disableAutocorrection(true)
                }

                Section(header: Text("Browser Path")) {
                    TextField("e.g., /Applications/Brave Browser.app", text: $browserPath)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Add New Rule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddRule = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let browserURL = URL(fileURLWithPath: browserPath)
                        let newRule = Rule(id: UUID(), domain: domain, browserURL: browserURL)
                        rules.append(newRule)
                        saveRules()
                        showAddRule = false
                    }
                    .disabled(domain.isEmpty || browserPath.isEmpty)
                }
            }
        }
    }

    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "rules")
        }
    }
}

#Preview {
    RulesTab()
}
