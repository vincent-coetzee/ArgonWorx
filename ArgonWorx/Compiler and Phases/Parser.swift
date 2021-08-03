//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public class Parser
    {
    private var tokenStream = TokenStream(source: "", context: NullReportingContext.shared)
    internal private(set) var token:Token = .none
    private var lastToken:Token = .none
    private let compiler:Compiler
    private var namingContext: NamingContext
    
    public static func parseChunk(_ source:String,in compiler:Compiler) -> ParseNode
        {
        Parser(compiler: compiler).parseChunk(source)
        }
        
    init(compiler:Compiler)
        {
        self.compiler = compiler
        self.namingContext = compiler.namingContext
        }
        
    public var reportingContext:ReportingContext
        {
        return(NullReportingContext.shared)
        }
        
    @discardableResult
    public func nextToken() -> Token
        {
        self.lastToken = self.token
        self.token = self.tokenStream.nextToken()
        return(self.token)
        }
        
    public func parseChunk(_ source:String) -> ParseNode
        {
        self.tokenStream = TokenStream(source: source, context: self.reportingContext)
        self.nextToken()
        let node = self.parsePrivacyModifier
            {
            (scope:PrivacyScope?) -> ParseNode in
            if !self.token.isKeyword
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected")
                }
            else
                {
                var node:ParseNode = ErrorSymbol.shared
                switch(self.token.keyword)
                    {
                    case .MAIN:
                        node = self.parseMain()
                    case .MODULE:
                        node = self.parseModule()
                    case .CLASS:
                        node = self.parseClass()
                    case .CONSTANT:
                        node = self.parseConstant()
                    case .METHOD:
                        node = self.parseMethod()
                    case .FUNCTION:
                        node = self.parseFunction()
                    case .TYPE:
                        node = self.parseTypeAlias()
                    case .HANDLE:
                        node = self.parseHandler()
                    default:
                        break
                    }
                }
            return(node)
            }
        return(node)
        }
        
    private func chompKeyword()
        {
        if self.token.isKeyword
            {
            self.nextToken()
            }
        }
        
    private func parseLabel() -> String
        {
        if !self.token.isIdentifier
            {
            self.reportingContext.dispatchWarning(at: self.token.location, message: "Label identifier expected here")
            return(Argon.nextName("LABEL"))
            }
        let string = self.token.identifier
        self.nextToken()
        return(string)
        }
        
    private func parseName() -> Name
        {
        if self.token.isName
            {
            let name = self.token.nameLiteral
            self.nextToken()
            return(name)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A name was expected but a \(self.token) was found.")
        return(Name("error"))
        }
        
    private func parsePrivacyModifier(_ closure: (PrivacyScope?) -> ParseNode) -> ParseNode
        {
        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
        self.chompKeyword()
        var value = closure(modifier)
        value.privacyScope = modifier
        return(value)
        }
        
    internal func parseBraces<T>(_ closure: () -> T) -> T
        {
        if !self.token.isLeftBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'{' expected but a '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        let result = closure()
        if !self.token.isRightBrace
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'}' expected but a '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        return(result)
        }
        
    private func parseMain() -> ParseNode
        {
        self.nextToken()
        if self.token.isModule
            {
            return(self.parseMainModule())
            }
        else if token.isMethod
            {
            return(self.parseMainMethod())
            }
        else
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "MAIN must prefix either MODULE or METHOD instead of \(self.token)")
            return(ErrorSymbol.shared)
            }
        }
    
    private func parseMainMethod() -> MethodInstance
        {
        self.nextToken()
        let label = self.parseLabel()
        let instance = MethodInstance(label: label)
        return(instance)
        }
        
    private func parseMainModule() -> Module
        {
        let label = self.parseLabel()
        let module = MainModule(label: label)
        self.parseModule(into: module)
        return(module)
        }
        
    private func parseModule() -> Module
        {
        let label = self.parseLabel()
        let module = Module(label: label)
        self.parseModule(into: module)
        return(module)
        }
        
    private func parseModule(into module:Module)
        {
        self.parseBraces
            {
            while !self.token.isRightBrace
                {
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found")
                    }
                else
                    {
                    switch(self.token.keyword)
                        {
                        case .MODULE:
                            let inner = self.parseModule()
                            module.addSymbol(inner)
                        case .CLASS:
                            let aClass = self.parseClass()
                            module.addSymbol(aClass)
                        case .TYPE:
                            let type = self.parseTypeAlias()
                            module.addSymbol(type)
                        case .METHOD:
                            let instance = self.parseMethod()
                            module.addSymbol(instance)
                        case .CONSTANT:
                            let constant = self.parseConstant()
                            module.addSymbol(constant)
                        case .SCOPED:
                            let scoped = self.parseScopedSlot()
                            module.addSymbol(scoped)
                        case .SLOT:
                            let slot = self.parseSlot()
                            module.addSymbol(slot)
                        case .INTERCEPTOR:
                            let interceptor = self.parseInterceptor()
                            module.addSymbol(interceptor)
                        default:
                            self.reportingContext.dispatchError(at: self.token.location, message: "A declaration for a module element was expected but \(self.token) was found.")
                        }
                    }
                
                }
            }
        }
        
    private func parseInterceptor() -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type:ArgonModule.argonModule.integer.type))
        }
        
    private func parseSlot() -> Slot
        {
        return(Slot(label:"Slot",type:ArgonModule.argonModule.integer.type))
        }
        
    private func parseClass() -> Class
        {
        return(Class(label:"Class"))
        }
        
    private func parseConstant() -> Constant
        {
        return(Constant(label:"$Constant"))
        }
        
    private func dispatchError(_ message:String)
        {
        self.reportingContext.dispatchError(at: self.token.location,message: message)
        }
        
    internal func parseParentheses<T>(_ closure: () -> T)  -> T
        {
        if !self.token.isLeftPar
            {
            self.dispatchError("'(' was expected but \(self.token) was found.")
            }
        else
            {
            self.nextToken()
            }
        let value = closure()
        if !self.token.isRightPar
            {
            self.dispatchError("')' was expected but \(self.token) was found.")
            }
        else
            {
            self.nextToken()
            }
        return(value)
        }
        
    private func parseComma()
        {
        if self.token.isComma
            {
            self.nextToken()
            }
        }
        
    private func parseGluon()
        {
        if !self.token.isGluon
            {
            self.dispatchError("'::' was expected but '\(self.token)' was found.")
            }
        else
            {
            self.nextToken()
            }
        }
        
    private func parseType() -> Type
        {
        var name:Name
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            let lastPart = self.token.identifier
            name = Name("\\\\Argon\\" + lastPart)
            }
        else if self.token.isIdentifier
            {
            name = Name(self.token.identifier)
            }
        else if self.token.isName
            {
            name = self.token.nameLiteral
            }
        else
            {
            self.dispatchError("A type name was expected but \(self.token) was found.")
            name = Name()
            }
        self.nextToken()
        if name == Name("\\\\Argon\\Array")
            {
            ///
            ///
            /// At this stage do nothing but at a later stage we need to add
            /// in the parsing of the more exotic array dimensions
            ///
            ///
            }
        let parameters = self.parseTypeParameters()
        let holder = SymbolHolder(name: name, location: self.token.location, namingContext: self.namingContext, reporter: self.reportingContext, types: parameters)
        return(SymbolHolderType(symbolHolder: holder))
        }
        
    private func parseTypeParameters() -> Types
        {
        if self.token.isLeftBrocket
            {
            let list = self.parseBrockets
                {
                () -> Types in
                var list = Types()
                while !self.token.isRightBrocket
                    {
                    self.parseComma()
                    list.append(self.parseType())
                    }
                return(list)
                }
            return(list)
            }
        return([])
        }
        
    internal func parseBrockets<T>(_ closure: () -> T) -> T
        {
        if self.token.isLeftBrocket
            {
            self.nextToken()
            }
        else
            {
            self.dispatchError("'<' was expected but \(self.token) was found.")
            }
        let value = closure()
        if self.token.isRightBrocket
            {
            self.nextToken()
            }
        else
            {
            self.dispatchError("'>' was expected but \(self.token) was found.")
            }
        return(value)
        }
        
    private func parseMethod() -> MethodInstance
        {
        self.nextToken()
        let name = self.parseLabel()
        let list = self.parseParentheses
            {
            () -> Parameters in
            var parameters = Parameters()
            while !self.token.isRightPar
                {
                self.parseComma()
                parameters.append(self.parseParameter())
                }
            return(parameters)
            }
        var returnType: Type? = nil
        if self.token.isRightArrow
            {
            self.nextToken()
            returnType = self.parseType()
            }
        let statements = self.parseBraces
            {
            self.parseStatements()
            }
        return(MethodInstance(label: name,parameters: list,returnType: returnType,expressions: statements))
        }
        
    private func parseStatements() -> Expressions
        {
        return(Expressions())
        }
        
    private func parseParameter() -> Parameter
        {
        var isHidden = false
        if self.token.isAssign
            {
            isHidden = true
            self.nextToken()
            }
        let tag = self.parseLabel()
        self.parseGluon()
        let type = self.parseType()
        let parameter = Parameter(label: tag, type: type,isHidden: isHidden)
        return(parameter)
        }
        
    private func parseFunction() -> Function
        {
        return(Function(label:"Function"))
        }
        
    private func parseTypeAlias() -> TypeAlias
        {
        return(TypeAlias(label:"TypeAlias"))
        }
        
    private func parseHandler() -> Handler
        {
        return(Handler(label:"Handler"))
        }
    }
