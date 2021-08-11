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
    
//    public static func tokenPublisher() -> AnyPublisher<VisualToken,Never>
//        {
//        let subject = PassthroughSubject<VisualToken,Never>()
//        let newSubject:AnyPublisher<VisualToken,Never> = subject.map{$0.mapColors(systemClassNames: Self.systemClassNames)}.eraseToAnyPublisher()
//        return(newSubject)
//        }

    public var visualTokens: Array<VisualToken>
        {
        let values = self.parser?.visualTokens.values
        return(values.isNil ? [] : Array(values!))
        }
        
    internal private(set) var namingContext: NamingContext
    private var parser: Parser?
    internal var lastChunk: ParseNode?
    
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
        if source.isEmpty
            {
            return
            }
        self.parser = Parser(compiler: self)
        self.lastChunk = parser!.parseChunk(source)!
        if let chunk = self.lastChunk
            {
            Realizer.realize(chunk,in:self)
            SemanticAnalyzer.analyze(chunk,in:self)
            Optimizer.optimize(chunk,in:self)
            CodeGenerator.emit(into: chunk,in:self)
            }
        }

    }
