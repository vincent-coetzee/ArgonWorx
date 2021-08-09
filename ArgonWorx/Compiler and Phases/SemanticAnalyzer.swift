//
//  SemanticAnalyzer.swift
//  SemanticAnalyzer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public struct SemanticAnalyzer
    {
    private let compiler:Compiler
    
    public static func analyze(_ node:ParseNode,in compiler:Compiler)
        {
        let analyzer = SemanticAnalyzer(compiler: compiler)
        analyzer.analyze(node)
        }
        
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    private func analyze(_ node:ParseNode)
        {
        node.analyzeSemantics(self.compiler)
        }
    }

public class TypeInferencer
    {
    public class Environment
        {
        private var types:[String:TypeConstraint] = [:]
        }
        
    public indirect enum TypeConstraint
        {
        case named(Class)
        case variable(String)
        case function(String,TypeConstraint,TypeConstraint)
        }
        
    private var nextVariable = 0
    
    private var constraints = Array<TypeConstraint>()
    
    public func addConstraint(_ constraint:TypeConstraint)
        {
        self.constraints.append(constraint)
        }
    }
