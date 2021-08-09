//
//  CodeGenerator.swift
//  CodeGenerator
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation


public struct CodeGenerator
    {
    private let compiler: Compiler
    public let registerFile = RegisterFile()
    
    public static func emit(into node:ParseNode,in compiler:Compiler)
        {
        let generator = CodeGenerator(compiler: compiler)
        generator.emitCode(into: node)
        
        }
        
    public init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    private func emitCode(into node: ParseNode)
        {
        for subnode in node.subNodes!
            {
            subnode.emitCode(into: subnode,using: self)
            }
        }
    }
