//
//  CodeGenerator.swift
//  CodeGenerator
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation


public struct CodeGenerator
    {
    internal let compiler: Compiler
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
        do
            {
            try node.emitCode(using: self)
            }
        catch let error
            {
            compiler.reportingContext.dispatchError(at: .zero, message: "Code generation error: \(error)")
            }
        }
    }
