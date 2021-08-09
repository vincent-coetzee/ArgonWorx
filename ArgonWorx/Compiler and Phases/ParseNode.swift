//
//  ParseNode.swift
//  ParseNode
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public protocol ParseNode
    {
    var subNodes: Array<ParseNode>? { get }
    var type: Class { get }
    var privacyScope: PrivacyScope? { get set }
    func emitCode(into: ParseNode,using: CodeGenerator)
    func realize(_ compiler:Compiler)
    func realizeSuperclasses()
    func analyzeSemantics(_ compiler:Compiler)
    }
