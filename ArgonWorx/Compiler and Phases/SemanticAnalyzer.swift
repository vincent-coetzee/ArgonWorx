//
//  SemanticAnalyzer.swift
//  SemanticAnalyzer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public struct SemanticAnalyzer
    {
    internal let compiler:Compiler
    
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
        node.analyzeSemantics(using: self)
        }
    }

public class TypeInferencer
    {
    public class Environment
        {
        private var types:[String:LocalType] = [:]
        }
        
    public indirect enum LocalType
        {
        case named(Class)
        case variable(String)
        case function(String,LocalType,LocalType)
        }
        
    private var nextVariable = 0
    
    public func infer(expression: Expression) -> LocalType
        {
        if expression is LiteralExpression
            {
            let literal = expression as! LiteralExpression
            return(.named(literal.resultType.class!))
            }
        else if expression is LocalAccessExpression
            {
            let local = expression as! LocalAccessExpression
            let localSlot = local.localSlot
            return(.named(localSlot.type))
            }
        return(.named(ArgonModule.argonModule.void))
        }
    }
