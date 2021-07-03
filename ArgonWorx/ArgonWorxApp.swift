//
//  ArgonWorxApp.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import SwiftUI

@main
struct ArgonWorxApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ArgonWorxDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
