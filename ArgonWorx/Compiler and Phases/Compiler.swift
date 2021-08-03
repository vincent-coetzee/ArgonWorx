//
//  Compiler.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Compiler
    {
    internal private(set) var namingContext: NamingContext
    
    init()
        {
        self.namingContext = TopModule.topModule
        }
        
    public var reportingContext:ReportingContext
        {
        return(NullReportingContext.shared)
        }

    public func compileChunk(_ source:String)
        {
        let chunk = Parser.parseChunk(source,in:self)
        Realizer.realize(chunk,in:self)
        SemanticAnalyzer.analyze(chunk,in:self)
        Optimizer.optimize(chunk,in:self)
        CodeGenerator.emit(into: chunk,in:self)
        }

    }
