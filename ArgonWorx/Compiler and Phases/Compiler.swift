//
//  Compiler.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import Combine

public class Compiler
    {
    public static let systemClassNames = ArgonModule.argonModule.classes.map{$0.label}
    
    public static func tokenPublisher() -> AnyPublisher<VisualToken,Never>
        {
        let subject = PassthroughSubject<VisualToken,Never>()
        let newSubject:AnyPublisher<VisualToken,Never> = subject.map{$0.mapColors(systemClassNames: Self.systemClassNames)}.eraseToAnyPublisher()
        return(newSubject)
        }

    internal private(set) var namingContext: NamingContext
    internal var visualTokens: Array<VisualToken> = []
    
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
        let parser = Parser(compiler: self)
        let chunk = parser.parseChunk(source)!
        self.visualTokens = parser.visualTokens
        Realizer.realize(chunk,in:self)
        SemanticAnalyzer.analyze(chunk,in:self)
        Optimizer.optimize(chunk,in:self)
        CodeGenerator.emit(into: chunk,in:self)
        }

    }
