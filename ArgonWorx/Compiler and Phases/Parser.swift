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
    private var symbolStack = Stack<Symbol>()
    private var currentContext:Symbol = Symbol(label:"")
    private var node:ParseNode?
    private var visualToken = VisualToken(token: .none)
    internal var visualTokens = Dictionary<Int,VisualToken>()
    
    public static func parseChunk(_ source:String,in compiler:Compiler) -> ParseNode?
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
        self.visualToken = self.visualTokens[self.token.id]!
        self.visualToken.remapTokenToColors()
        self.tokenIndex += 1
        while self.token.isComment || self.token.isInvisible
            {
            self.token = self.tokens[self.tokenIndex]
            self.visualToken = self.visualTokens[self.token.id]!
            self.visualToken.remapTokenToColors()
            self.tokenIndex += 1
            }
        print(token)
        return(self.token)
        }
        
    private func pushContext(_ symbol:Symbol)
        {
        var newSymbol = symbol
        var old:Symbol? = self.currentContext
        while old != nil
            {
            if old == symbol
                {
                newSymbol = ForwardingSymbol(label:"")
                break
                }
            old = old!.parent as? Symbol
            }
        newSymbol.setParent(self.currentContext)
        self.symbolStack.push(self.currentContext)
        self.currentContext = newSymbol
        }
        
    @discardableResult
    private func popContext() -> Symbol
        {
        self.currentContext = self.symbolStack.pop()
        return(self.currentContext)
        }
        
    private func peekToken() -> Token
        {
        return(self.tokens[self.tokenIndex])
        }
        
    private func initParser(source:String)
        {
        self.currentContext = TopModule.topModule
        let stream = TokenStream(source: source, context: self.reportingContext)
        self.tokens = stream.allTokens(withComments: true, context: self.reportingContext)
        for aToken in self.tokens
            {
            let newToken = VisualToken(token: aToken)
            newToken.remapTokenToColors()
            self.visualTokens[aToken.id] = newToken
            }
        self.nextToken()
        }
        
    public func parseChunk(_ source:String) -> ParseNode?
        {
        self.initParser(source: source)
        let result = self.parsePrivacyModifier
            {
            (scope:PrivacyScope?) -> ParseNode in
            if !self.token.isKeyword
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "KEYWORD expected")
                }
            else
                {
                switch(self.token.keyword)
                    {
                    case .MAIN:
                        self.parseMain()
                    case .MODULE:
                        self.parseModule()
                    case .CLASS:
                        self.parseClass()
                    case .CONSTANT:
                        self.parseConstant()
                    case .METHOD:
                        self.parseMethod()
                    case .FUNCTION:
                        self.parseFunction()
                    case .TYPE:
                        self.parseTypeAlias()
                    default:
                        break
                    }
                }
            return(self.node!)
            }
        return(result)
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
        
    private func parseMain()
        {
        self.nextToken()
        if self.token.isModule
            {
            self.parseMainModule()
            }
        else
            {
            self.parseMainMethod()
            }
        }
    
    private func parseMainMethod()
        {
        let method = self.parseMethod()
        method.isMain = true
        }
        
    private func parseMainModule()
        {
        self.nextToken()
        let label = self.parseLabel()
        let module = MainModule(label: label)
        self.currentContext.addSymbol(module)
        self.pushContext(module)
        self.parseModule(into: module)
        self.popContext()
        self.node = module
        }
    
    private func parsePath() -> Token
        {
        if self.token.isPath
            {
            self.visualToken.kind = .path
            self.nextToken()
            return(self.lastToken)
            }
        self.dispatchError("Path expected for a library module but \(self.token) was found.")
        return(.path("",Location.zero))
        }
        
    private func parseModule()
        {
        self.nextToken()
        self.visualToken.kind = .module
        let label = self.parseLabel()
        var module:Module = ModuleInstance(label:"")
        if self.token.isLeftPar
            {
            self.parseParentheses
                {
                let path = self.parsePath().path
                module = LibraryModule(label: label,path: path)
                }
            }
        else
            {
            module = ModuleInstance(label: label)
            }
        self.currentContext.addSymbol(module)
        self.parseModule(into: module)
        self.node = module
        }
        
    private func parseModule(into module:Module)
        {
        self.pushContext(module)
        self.parseBraces
            {
            while !self.token.isRightBrace
                {
                if !self.token.isKeyword
                    {
                    self.reportingContext.dispatchError(at: self.token.location, message: "Keyword expected but \(self.token) found")
                    self.nextToken()
                    }
                else
                    {
                    switch(self.token.keyword)
                        {
                        case .FUNCTION:
                            self.parseFunction()
                        case .MAIN:
                            self.parseMain()
                        case .MODULE:
                            self.parseModule()
                        case .CLASS:
                            self.parseClass()
                        case .TYPE:
                            self.parseTypeAlias()
                        case .METHOD:
                            self.parseMethod()
                        case .CONSTANT:
                            self.parseConstant()
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
                            self.nextToken()
                        }
                    }
                
                }
            }
        self.popContext()
        }
        
    private func parseInterceptor() -> Interceptor
        {
        return(Interceptor(label:"Interceptor",parameters: []))
        }
        
    private func parseScopedSlot() -> ScopedSlot
        {
        return(ScopedSlot(label:"Slot",type:ArgonModule.argonModule.integer))
        }
        
    private func parseSlot() -> Slot
        {
        self.nextToken()
        self.visualToken.kind = .classSlot
        let label = self.parseLabel()
        var type: Class?
        if self.token.isGluon
            {
            self.nextToken()
            type = self.parseType()
            }
        var initialValue:Expression?
        if self.token.isAssign
            {
            self.nextToken()
            initialValue = self.parseExpression()
            }
        var readBlock:VirtualReadBlock?
        var writeBlock:VirtualWriteBlock?
        if self.token.isLeftBrace
            {
            self.parseBraces
                {
                if self.token.isRead
                    {
                    readBlock = VirtualReadBlock()
                    self.parseBlock(into: readBlock!)
                    }
                if self.token.isWrite
                    {
                    writeBlock = VirtualWriteBlock()
                    self.parseBlock(into: writeBlock!)
                    }
                }
            }
        var slot: Slot?
        if readBlock.isNotNil
            {
            let aSlot = VirtualSlot(label: label,type: type ?? VoidClass.voidClass)
            aSlot.writeBlock = writeBlock
            aSlot.readBlock = readBlock
            slot = aSlot
            }
        else
            {
            slot = Slot(label: label,type: type ?? VoidClass.voidClass)
            }
        slot!.initialValue = initialValue
        return(slot!)
        }
        
    private func parseClassSlot() -> Slot
        {
        self.nextToken()
        let slot = self.parseSlot()
        slot.isClassSlot = true
        return(slot)
        }
        
    private func parseClass()
        {
        self.nextToken()
        self.visualToken.kind = .class
        let label = self.parseLabel()
        let aClass = Class(label: label)
        self.currentContext.addSymbol(aClass)
        self.pushContext(aClass)
        if self.token.isGluon
            {
            self.nextToken()
            repeat
                {
                self.parseComma()
                self.visualToken.kind = .class
                let otherClass = self.parseName()
                let holder = SymbolHolder(name: otherClass, location: self.token.location, namingContext: self.currentContext, reporter: self.reportingContext)
                aClass.superclassHolders.append(holder)
                }
            while self.token.isComma
            }
        self.parseBraces
            {
            while self.token.isSlot || self.token.isClass
                {
                if self.token.isSlot
                    {
                    let slot = self.parseSlot()
                    aClass.addSymbol(slot)
                    }
                else if self.token.isClass
                    {
                    let slot = self.parseClassSlot()
                    aClass.metaclass.addSymbol(slot)
                    }
                }
            }
        self.popContext()
        self.node = aClass
        }
        
    private func parseConstant()
        {
        self.nextToken()
        self.visualToken.kind = .constant
        let label = self.parseLabel()
        var type:Class = VoidClass.voidClass
        if self.token.isGluon
            {
            self.parseGluon()
            type = self.parseType()
            }
        if !self.token.isAssign
            {
            self.reportingContext.dispatchError(at: self.token.location, message: "'=' expected to follow the declaration of a CONSTANT.")
            }
        self.nextToken()
        let value = self.parseExpression()
        let constant = Constant(label: label,type: type,value: value)
        self.currentContext.addSymbol(constant)
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
        
    private func parseType() -> Class
        {
        var name:Name
        if self.token.isIdentifier && self.token.isSystemClassName
            {
            self.visualToken.kind = .type
            let lastPart = self.token.identifier
            name = Name("\\\\Argon\\" + lastPart)
            }
        else if self.token.isIdentifier
            {
            self.visualToken.kind = .type
            name = Name(self.token.identifier)
            }
        else if self.token.isName
            {
            self.visualToken.kind = .type
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
        
    private func parseTypeParameters() -> Classes
        {
        if self.token.isLeftBrocket
            {
            let list = self.parseBrockets
                {
                () -> Classes in
                var list = Classes()
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
        
    @discardableResult
    private func parseMethod() -> ArgonWorx.Method
        {
        self.nextToken()
        self.visualToken.kind = .method
        let name = self.parseLabel()
        let existingMethod = self.currentContext.lookup(label: name) as? Method
        let list = self.parseParameters()
        var returnType: Class? = nil
        if self.token.isRightArrow
            {
            self.nextToken()
            returnType = self.parseType()
            }
        if existingMethod.isNotNil
            {
            if list.count != existingMethod!.proxyParameters.count
                {
                self.dispatchError("The multimethod '\(existingMethod!.label)' is already defined and this parameter set is not coherent with the existing parameter set.")
                }
            if returnType != existingMethod!.returnType
                {
                self.dispatchError("The multimethod '\(existingMethod!.label)' is already defined and has a different return tupe from this return type.")
                }
            for (yours,mine) in zip(list,existingMethod!.proxyParameters)
                {
                if yours.tag != mine.tag
                    {
                    self.dispatchError("The multimethod '\(existingMethod!.label)' has a tag '\(mine.tag)' where the tag '\(yours.tag)' appears, parameter tags must match on multimethod instances.")
                    }
                if yours.isHidden != mine.isHidden
                    {
                    self.dispatchError("The multimethod '\(existingMethod!.label)' has a tag '\(mine.tag)' which differs in visibility from the tag '\(yours.tag)'.")
                    }
                }
            }
        let instance = MethodInstance(label: name,parameters: list,returnType: returnType)
        if existingMethod.isNotNil
            {
            existingMethod?.addInstance(instance)
            }
        else
            {
            let method = Method(label: name)
            self.currentContext.addSymbol(method)
            method.addInstance(instance)
            }
        self.parseBraces
            {
            self.pushContext(instance)
            self.parseBlock(into: instance.block)
            self.popContext()
            }
        return(instance.method)
        }
        
    private func parseStatements() -> Expressions
        {
        return(Expressions())
        }
        
    private func parseExpression() -> Expression
        {
        let expression = self.parseArrayExpression()
        if self.token.isPlusPlus || self.token.isMinusMinus
            {
            let symbol = self.token.operator
            self.nextToken()
            return(SuffixExpression(expression,symbol))
            }
        return(expression)
        }

    private func parseArrayExpression() -> Expression
        {
        var lhs = self.parseRelationalExpression()
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
        
    private func parseRelationalExpression() -> Expression
        {
        let lhs = self.parseArithmeticExpression()
        if self.token.isLeftBrocket || self.token.isLeftBrocketEquals || self.token.isEquals || self.token.isRightBrocket || self.token.isRightBrocketEquals
            {
            let symbol = self.token.symbol
            self.nextToken()
            let rhs = self.parseExpression()
            return(lhs.operation(symbol,rhs))
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
        let lhs = self.parseUnaryExpression()
        while self.token.isRightArrow
            {
            self.nextToken()
            let slotExpression = self.parseSlotMemberExpression([])
            slotExpression.instance(lhs)
            return(slotExpression)
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
        else if self.token.isLeftBrace
            {
            return(self.parseClosureTerm())
            }
        else
            {
            fatalError("Invalid parse state \(self.lastToken) \(self.token)")
            }
        }
        
    private func parseSlotMemberExpression(_ list:[String]) -> SlotMemberExpression
        {
        self.visualToken.kind = .classSlot
        let first = self.parseLabel()
        if self.token.isRightArrow
            {
            self.nextToken()
            return(self.parseSlotMemberExpression([first]))
            }
        return(SlotMemberExpression(self.currentContext,list + [first]))
        }
        
    private func parseIdentifierTerm() -> Expression
        {
        let name = self.parseName()
        let aSymbol = self.currentContext.lookup(name: name)
        if let symbol = aSymbol as? Class
            {
            if self.token.isLeftPar
                {
                self.parseParentheses { }
                return(InstanciationTerm(class: symbol))
                }
            else if self.token.isRightArrow
                {
                let operation = self.token.symbol
                var lhs:Expression = NameExpression(name: name, location: self.token.location, context: self.currentContext, reportingContext: self.reportingContext)
                while self.token.isRightArrow
                    {
                    self.nextToken()
                    let slotExpression = self.parseExpression()
                    lhs = lhs.operation(operation,slotExpression)
                    }
                return(lhs)
                }
            else
                {
                return(LiteralExpression(.class(symbol)))
                }
            }
        else if let symbol = aSymbol as? Module
            {
            if self.token.isRightArrow
                {
                let operation = self.token.symbol
                var lhs:Expression = LiteralExpression(.module(symbol))
                while self.token.isRightArrow
                    {
                    self.nextToken()
                    let slotExpression = self.parseExpression()
                    lhs = lhs.operation(operation,slotExpression)
                    }
                return(lhs)
                }
            else
                {
                return(LiteralExpression(.module(symbol)))
                }
            }
        if self.token.isLeftPar
            {
            return(self.parseInvocationTerm(name))
            }
        else
            {
            return(LocalReadExpression(name: name, location: self.token.location,namingContext: self.currentContext, reportingContext: self.reportingContext))
            }
        }
        
    private func parseClosureTerm() -> BlockExpression
        {
        let closure = ClosureBlock()
        self.parseBraces
            {
            if self.token.isWith
                {
                self.nextToken()
                closure.parameters = self.parseParentheses
                    {
                    self.parseParameters()
                    }
                if self.token.isRightArrow
                    {
                    closure.resultType = self.parseType()
                    }
                }
            while !self.token.isRightBrace
                {
                self.parseBlock(into: closure)
                }
            }
        return(BlockExpression(block: closure))
        }
        
    private func parseInvocationTerm(method: Method) -> Expression
        {
        let args = self.parseParentheses
            {
            () -> Arguments in
            var arguments = Arguments()
            for parameter in method.proxyParameters
                {
                self.parseComma()
                var tag: String = ""
                if !parameter.isHidden
                    {
                    if !self.token.isIdentifier
                        {
                        self.dispatchError("Argument tag '\(parameter.tag)' was expected, but \(self.token) was found.")
                        self.nextToken()
                        tag = "TAG"
                        }
                    else
                        {
                        tag = self.token.identifier
                        self.nextToken()
                        }
                    self.parseGluon()
                    let value = self.parseExpression()
                    arguments.append(Argument(tag: tag,value: value))
                    }
                else
                    {
                    let value = self.parseExpression()
                    arguments.append(Argument(tag: "",value: value))
                    }
                }
            return(arguments)
            }
        method.validateInvocation(location: self.token.location, arguments: args, reportingContext: self.reportingContext)
        return(MethodInvocationExpression(method: method,arguments: args))
        }
        
    private func parseInvocationTerm(_ name:Name) -> Expression
        {
        self.visualToken.kind = .methodInvocation
        let method = self.currentContext.lookup(name: name) as? Method
        if method.isNotNil
            {
            return(self.parseInvocationTerm(method: method!))
            }
        let args = self.parseParentheses
            {
            () -> Arguments in
            var arguments = Arguments()
            while !self.token.isRightPar
                {
                self.parseComma()
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
        return(InvocationExpression(name: name,arguments: args, location: self.token.location,namingContext: self.currentContext, reportingContext: self.reportingContext))
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
            else if self.token.isReturn
                {
                self.parseReturnBlock(into: block)
                }
            else if self.token.isLet
                {
                self.parseLetBlock(into: block)
                }
            else
                {
                self.dispatchError("A statement was expected but \(self.token) was found.")
                self.nextToken()
                }
            }
        }
        
    private func parseSelectBlock(into block: Block)
        {
        self.nextToken()
        let value = self.parseParentheses
            {
            return(self.parseExpression())
            }
        let selectBlock = SelectBlock(value: value)
        block.addBlock(selectBlock)
        self.parseBraces
            {
            while !self.token.isRightBrace
                {
                if !self.token.isWhen
                    {
                    self.dispatchError("WHEN expected after SELECT clause")
                    self.nextToken()
                    }
                let inner = self.parseParentheses
                    {
                    self.parseExpression()
                    }
                let when = WhenBlock(condition: inner)
                selectBlock.addWhen(block: when)
                self.parseBraces
                    {
                    self.parseBlock(into: when)
                    }
                }
            }
        }
        
    private func parseIfBlock(into block: Block)
        {
        self.nextToken()
        let expression = self.parseRelationalExpression()
        let statement = IfBlock(condition: expression)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        }
        
    private func parseLetBlock(into block: Block)
        {
        self.nextToken()
        let someVariable = self.parseName()
        if !self.token.isAssign
            {
            self.dispatchError("'=' expected after LET clause.")
            }
        self.nextToken()
        let value = self.parseExpression()
        let aClass = value.resultType.class ?? VoidClass.voidClass
        print(aClass)
        let localSlot = LocalSlot(label: someVariable.last, type: value)
        block.addLocalSlot(localSlot)
        block.addBlock(LetBlock(name: someVariable,slot:localSlot,location: self.token.location,namingContext: block,value: value))
        }
        
    private func parseReturnBlock(into block: Block)
        {
        self.nextToken()
        let value = self.parseParentheses
            {
            self.parseExpression()
            }
        let returnBlock = ReturnBlock()
        returnBlock.value = value
        block.addBlock(returnBlock)
        }
        
    private func parseWhileBlock(into block: Block)
        {
        self.nextToken()
        let expression = self.parseRelationalExpression()
        let statement = WhileBlock(condition: expression)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        }
        
    private func parseInductionVariable()
        {
        }
        
    private func parseForkBlock(into block: Block)
        {
        let variableName = self.parseLabel()
        self.parseInductionVariable()
        let statement = ForBlock(name: variableName)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        }
        
    private func parseLoopBlock(into block: Block)
        {
        }
        
    private func parseSignalBlock(into block: Block)
        {
        self.nextToken()
        self.parseParentheses
            {
            if self.nextToken().isHashStringLiteral
                {
                let symbol = self.token.hashStringLiteral
                block.addBlock(SignalBlock(symbol: symbol))
                self.nextToken()
                }
            else
                {
                self.dispatchError("Symbol expected but \(self.token) was found instead.")
                }
            }
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
        var isVariadic = false
        if self.token.isFullRange
            {
            self.nextToken()
            isVariadic = true
            }
        let parameter = Parameter(label: tag, type: type,isHidden: isHidden,isVariadic: isVariadic)
        return(parameter)
        }
        
    private func parseFunction()
        {
        self.nextToken()
        self.visualToken.kind = .function
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
        self.currentContext.addSymbol(function)
        }
        
    private func parseTypeAlias()
        {
        self.nextToken()
        self.visualToken.kind = .type
        let label = self.parseLabel()
        if !self.token.isIs
            {
            self.dispatchError("IS expeected after new name for type.")
            }
        self.nextToken()
        let type = self.parseType()
        let alias = TypeAlias(label: label,type: type)
        self.currentContext.addSymbol(alias)
        }
        
    private func parseHandleBlock(into block: Block)
        {
        self.nextToken()
        let handler = HandlerBlock()
        self.parseParentheses
            {
            repeat
                {
                self.parseComma()
                if !self.token.isHashStringLiteral
                    {
                    self.dispatchError("A symbol was expected in the handler clause, but \(self.token) was found.")
                    }
                let symbol = self.token.isHashStringLiteral ? self.token.hashStringLiteral : "#SYMBOL"
                self.nextToken()
                handler.symbols.append(symbol)
                }
            while self.token.isComma
            }
        self.parseBraces
            {
            if !self.token.isWith
                {
                self.dispatchError("WITH expected in first line of HANDLE clause, but \(self.token) was found.")
                }
            self.nextToken()
            var name:String = ""
            self.parseParentheses
                {
                if !self.token.isIdentifier
                    {
                    self.dispatchError("The name of an induction variable to contain the symbol this handler is receiving was expected but \(self.token) was found.")
                    }
                name = self.token.isIdentifier ? self.token.identifier : "VariableName"
                handler.addParameter(label: name,type: ArgonModule.argonModule.symbol)
                self.nextToken()
                }
            self.parseBlock(into: handler)
            }
        block.addBlock(handler)
        }
    }

extension Array where Element == Parameter
    {
    public func parameterIfAvailable(_ index:Int) -> Element?
        {
        if index < self.count
            {
            return(self[index])
            }
        return(nil)
        }
    }
