//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public class Parser
    {
    private let source:String
    private let tokenStream:TokenStream
    public var token:Token = .none
    private var allTokens = Array<Token>()
    private var mainModule:Module?
    private var tokenIndex = 0
    private var markStack = Stack<Int>()
    internal let isDebugging: Bool
    private var symbolAttributesStack = Stack<SymbolAttributes>()
    private var currentSymbolAttributes = SymbolAttributes()
    internal let compiler:Compiler
    internal var braceDepth = 0
    private var currentDirectives:Array<String> = []
    private let reportingContext:ReportingContext = NullReportingContext.shared
    
    init(compiler:Compiler,debug: Bool = true,source:String)
        {
        self.compiler = compiler
        self.isDebugging = debug
        self.source = source
        self.tokenStream = TokenStream(source: source,context: compiler.reportingContext)
        var theToken = self.tokenStream.nextToken()
        while !theToken.isEnd
            {
            self.allTokens.append(theToken)
            theToken = self.tokenStream.nextToken()
            }
        self.allTokens.append(theToken)
        }

    public func dispatchError(at:Location,message:String)
        {
//        self.compiler.dispatchError(at: at,message: message)
        }
        
    public func pushToken(_ token:Token)
        {
        self.allTokens.insert(token,at:self.tokenIndex)
        }
        
    public func nextToken()
        {
        self.token = self.allTokens[self.tokenIndex]
        if self.token == .leftBrace
            {
            self.braceDepth += 1
            }
        else if self.token == .rightBrace
            {
            self.braceDepth -= 1
            }
//        if self.isDebugging
//            {
//            print("\(self.tokenIndex) \(self.token)")
//            }
        self.tokenIndex += 1
        }
    }
