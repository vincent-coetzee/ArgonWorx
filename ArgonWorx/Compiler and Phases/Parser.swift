//
//  Parser.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/9/21.
//

import Foundation

public class Parser
    {
    private var tokens = Array<Token>()
    private var tokenIndex = 0
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
        self.token = self.tokens[self.tokenIndex]
        self.tokenIndex += 1
        print(token)
        return(self.token)
        }
        
    private func peekToken() -> Token
        {
        return(self.tokens[self.tokenIndex])
        }
        
    public func parseChunk(_ source:String) -> ParseNode
        {
        let stream = TokenStream(source: source, context: self.reportingContext)
        self.tokens = stream.allTokens(withComments: false, context: self.reportingContext)
        self.nextToken()
        let item = self.parsePrivacyModifier
            {
            (scope:PrivacyScope?) -> ParseNode in
            var node:ParseNode = ErrorSymbol.shared
            if !self.token.isKeyword
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected")
                }
            else
                {
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
        return(item)
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
        else if self.token.isIdentifier
            {
            let name = Name(self.token.identifier)
            self.nextToken()
            return(name)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A name was expected but a \(self.token) was found.")
        return(Name("error"))
        }
        
    private func parsePrivacyModifier(_ closure: (PrivacyScope?) -> ParseNode) -> ParseNode
        {
        let modifier = self.token.isKeyword ? PrivacyScope(rawValue: self.token.keyword.rawValue) : nil
        if self.token.isPrivacyModifier
            {
            self.chompKeyword()
            }
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
        return(self.parseMethod())
        }
        
    private func parseMainModule() -> Module
        {
        self.nextToken()
        let label = self.parseLabel()
        let module = MainModule(label: label)
        self.parseModule(into: module)
        return(module)
        }
    
    private func parsePath() -> Token
        {
        if self.token.isPath
            {
            self.nextToken()
            return(self.lastToken)
            }
        self.dispatchError("Path expected for a library module but \(self.token) was found.")
        return(.path("",Location.zero))
        }
        
    private func parseModule() -> Module
        {
        let label = self.parseLabel()
        var module:Module
        if self.token.isLeftPar
            {
            let path = self.parsePath().path
            module = LibraryModule(label: label,path: path)
            }
        else
            {
            module = Module(label: label)
            }
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
                        case .FUNCTION:
                            let function = self.parseFunction()
                            module.addSymbol(function)
                        case .MAIN:
                            let symbol = self.parseMain() as! Symbol
                            module.addSymbol(symbol)
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
        
    private func parseParameters() -> Parameters
        {
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
        return(list)
        }
        
    private func parseMethod() -> MethodInstance
        {
        self.nextToken()
        let name = self.parseLabel()
        let list = self.parseParameters()
        var returnType: Type? = nil
        if self.token.isRightArrow
            {
            self.nextToken()
            returnType = self.parseType()
            }
        let instance = MethodInstance(label: name,parameters: list,returnType: returnType)
        self.parseBraces
            {
            self.parseBlock(into: instance.block)
            }
        return(instance)
        }
        
    private func parseStatements() -> Expressions
        {
        return(Expressions())
        }
        
    private func parseExpression() -> Expression
        {
        return(self.parseArrayExpression())
        }

    private func parseArrayExpression() -> Expression
        {
        var lhs = self.parseArithmeticExpression()
        while self.token.isLeftBracket
            {
            self.nextToken()
            let rhs = self.parseExpression()
            if !self.token.isRightBracket
                {
                self.dispatchError("']' expected but \(self.token) was found.")
                }
            self.nextToken()
            lhs = lhs.index(rhs)
            }
        return(lhs)
        }
        
    private func parseArithmeticExpression() -> Expression
        {
        var lhs = self.parseMultiplicativeExpression()
        while self.token.isAdd || self.token.isSub
            {
            lhs = lhs.operation(self.token.symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() -> Expression
        {
        var lhs = self.parseBitExpression()
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            lhs = lhs.operation(self.token.symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseBitExpression() -> Expression
        {
        var lhs = self.parseSlotExpression()
        while self.token.isBitAnd || self.token.isBitOr || self.token.isBitXor
            {
            lhs = lhs.operation(self.token.symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseSlotExpression() -> Expression
        {
        var lhs = self.parseUnaryExpression()
        while self.token.isRightArrow
            {
            lhs = lhs.operation(self.token.symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseUnaryExpression() -> Expression
        {
        if self.token.isSub || self.token.isBitNot || self.token.isNot
            {
            return(self.parseExpression().unary(self.token.symbol))
            }
        else
            {
            return(self.parseTerm())
            }
        }
        
    private func parseTerm() -> Expression
        {
        if self.token.isIntegerLiteral
            {
            self.nextToken()
            return(LiteralExpression(.integer(self.lastToken.integerLiteral)))
            }
        else if self.token.isFloatingPointLiteral
            {
            self.nextToken()
            return(LiteralExpression(.float(self.lastToken.floatingPointLiteral)))
            }
        else if self.token.isStringLiteral
            {
            self.nextToken()
            return(LiteralExpression(.string(self.lastToken.stringLiteral)))
            }
        else if self.token.isHashStringLiteral
            {
            self.nextToken()
            return(LiteralExpression(.symbol(self.lastToken.hashStringLiteral)))
            }
        else if self.token.isNilLiteral
            {
            self.nextToken()
            return(LiteralExpression(.nil))
            }
        else if self.token.isBooleanLiteral
            {
            self.nextToken()
            return(LiteralExpression(.boolean(self.lastToken.booleanLiteral)))
            }
        else if self.token.isIdentifier
            {
            return(self.parseIdentifierTerm())
            }
        else if self.token.isLeftPar
            {
            return(self.parseParentheses
                {
                return(self.parseExpression())
                })
            }
        else
            {
            fatalError("Invalid parse state")
            }
        }
        
    private func parseIdentifierTerm() -> Expression
        {
        let name = self.parseName()
        if self.token.isLeftPar
            {
            return(self.parseInvocationTerm(name))
            }
        else
            {
            return(SlotReadExpression(name: name,namingContext: self.namingContext, reportingContext: self.reportingContext))
            }
        }
        
    private func parseInvocationTerm(_ name:Name) -> Expression
        {
        let args = self.parseParentheses
            {
            () -> Arguments in
            var arguments = Arguments()
            while !self.token.isRightPar
                {
                self.parseComma()
                self.nextToken()
                var tag:String? = nil
                if self.token.isGluon
                    {
                    if !self.lastToken.isIdentifier
                        {
                        self.dispatchError("A gluon should have terminated an argument tag, it did not, this is an error")
                        }
                    tag = self.lastToken.identifier
                    self.nextToken()
                    }
                let value = self.parseExpression()
                arguments.append(Argument(tag: tag,value: value))
                }
            return(arguments)
            }
        return(InvocationExpression(name: name,arguments: args,namingContext: self.namingContext, reportingContext: self.reportingContext))
        }
        
    private func parseBlock(into block: Block)
        {
        while !self.token.isRightBrace
            {
            if self.token.isSelect
                {
                self.parseSelectBlock(into: block)
                }
            else if self.token.isIf
                {
                self.parseIfBlock(into: block)
                }
            else if self.token.isWhile
                {
                self.parseWhileBlock(into: block)
                }
            else if self.token.isFork
                {
                self.parseForkBlock(into: block)
                }
            else if self.token.isLoop
                {
                self.parseLoopBlock(into: block)
                }
            else if self.token.isSignal
                {
                self.parseSignalBlock(into: block)
                }
            else if self.token.isHandle
                {
                self.parseHandleBlock(into: block)
                }
            else if self.token.isIdentifier
                {
                self.parseIdentifierBlock(into: block)
                }
            else
                {
                self.dispatchError("Statement expected")
                self.nextToken()
                }
            }
        }
        
    private func parseSelectBlock(into block: Block)
        {
        }
        
    private func parseIfBlock(into block: Block)
        {
        }
        
    private func parseWhileBlock(into block: Block)
        {
        }
        
    private func parseForkBlock(into block: Block)
        {
        }
        
    private func parseLoopBlock(into block: Block)
        {
        }
        
    private func parseSignalBlock(into block: Block)
        {
        }
        
    private func parseHandleBlock(into block: Block)
        {
        }
        
    private func parseIdentifierBlock(into block: Block)
        {
        var expression = self.parseExpression()
        if self.token.isAssign
            {
            self.nextToken()
            let rhs = self.parseExpression()
            expression = expression.assign(rhs)
            }
        block.addBlock(ExpressionBlock(expression))
        }
        
    private func parseAssignmentBlock(into block: Block)
        {
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
        self.nextToken()
        let name = self.parseLabel()
        let cName = self.parseParentheses
            {
            () -> String in
            let string = self.parseLabel()
            return(string)
            }
        let parameters = self.parseParameters()
        let function = Function(label: name)
        function.cName = cName
        function.parameters = parameters
        if self.token.isRightArrow
            {
            self.nextToken()
            function.returnType = self.parseType()
            }
        return(function)
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
