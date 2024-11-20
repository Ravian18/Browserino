//  BrowserUtil.swift
//  Browserino
//
//  Created by byt3m4st3r.
//  

import AppKit
import Foundation
import SwiftUI

public struct Rule: Identifiable, Codable, Hashable {
    public let id: UUID
    public var domain: String
    public var browserURL: URL

    public init(id: UUID = UUID(), domain: String, browserURL: URL) {
        self.id = id
        self.domain = domain
        self.browserURL = browserURL
    }
}

class BrowserUtil {
    @AppStorage("directories") private static var directories: [Directory] = []
    @AppStorage("rules") private static var rulesData: Data = Data()

    static func loadBrowsers() -> [URL] {
        // Convert directories to valid paths
        let validDirectories = directories.map { $0.directoryPath }

        guard let url = URL(string: "https:") else {
            return []
        }

        // Fetch all applications that can open the https scheme
        let urlsForApplications = NSWorkspace.shared.urlsForApplications(toOpen: url)

        // Filter the browsers to include only those in the specified browser search directories (/Applications default)
        var filteredUrlsForApplications = urlsForApplications.filter { urlsForApplication in
            validDirectories.contains { urlsForApplication.path.hasPrefix($0) }
        }

        // Remove Browserino from the browser list
        if let browserino = NSWorkspace.shared.urlForApplication(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "xyz.alexstrnik.Browserino") {
            if filteredUrlsForApplications.contains(browserino) {
                filteredUrlsForApplications.removeAll { $0 == browserino }
            }
        }

        // Always include Safari by adding it explicitly if not already present
        if let safari = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") {
            if !filteredUrlsForApplications.contains(safari) {
                filteredUrlsForApplications.append(safari)
            }
        }

        return filteredUrlsForApplications
    }

    static func loadRules() -> [Rule] {
        if let decoded = try? JSONDecoder().decode([Rule].self, from: rulesData) {
            return decoded
        }
        return []
    }

    static func browserFor(url: URL) -> URL? {
        let rules = loadRules()
        guard let host = url.host else { return nil }
        for rule in rules {
            if host.contains(rule.domain) {
                return rule.browserURL
            }
        }
        return nil
    }

    static func open(url: URL) {
        if let browserURL = browserFor(url: url) {
            do {
                let configuration = NSWorkspace.OpenConfiguration()
                try NSWorkspace.shared.open([url], withApplicationAt: browserURL, configuration: configuration)
            } catch {
                print("Failed to open URL with specified browser: \(error)")
                // Fallback to default behavior if needed
                openWithPrompt(url: url)
            }
        } else {
            // Default behavior, show prompt to select browser
            openWithPrompt(url: url)
        }
    }

    private static func openWithPrompt(url: URL) {
        // Assuming PromptManager is responsible for showing the prompt
        DispatchQueue.main.async {
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.application(NSApplication.shared, open: [url])
            }
        }
    }
}
