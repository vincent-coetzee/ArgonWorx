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
    private var contextStack = Stack<NamingContext>()
    private var currentContext:NamingContext = Node(label: "")
    private var node:ParseNode?
    internal var visualToken = TokenRenderer()
    
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
        self.visualToken.currentToken = self.token
        self.tokenIndex += 1
        while self.token.isComment || self.token.isInvisible
            {
            self.token = self.tokens[self.tokenIndex]
            self.visualToken.currentToken = self.token
            self.tokenIndex += 1
            }
        print(token)
        return(self.token)
        }
        
    private func peekToken1() -> Token
        {
        return(self.peekToken(0))
        }
        
    private func peekToken2() -> Token
        {
        return(self.peekToken(1))
        }
        
    private func peekToken(_ index:Int) -> Token
        {
        let newToken = self.tokens[self.tokenIndex + index]
        if newToken.isComment || newToken.isInvisible
            {
            return(self.peekToken(index+1))
            }
        return(newToken)
        }
        
    private func pushContext(_ context:NamingContext)
        {
        var newSymbol = context
        var old:NamingContext? = self.currentContext
        while old != nil
            {
            if old!.index == context.index
                {
                newSymbol = ForwardingSymbol(label:"")
                break
                }
            old = old!.parent as? NamingContext
            }
        newSymbol.setParent(self.currentContext)
        self.contextStack.push(self.currentContext)
        self.currentContext = newSymbol
        }
        
    @discardableResult
    private func popContext() -> NamingContext
        {
        self.currentContext = self.contextStack.pop()
        return(self.currentContext)
        }
        
    private func initParser(source:String)
        {
        self.currentContext = TopModule.topModule
        let stream = TokenStream(source: source, context: self.reportingContext)
        self.tokens = stream.allTokens(withComments: true, context: self.reportingContext)
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
                    case .ENUMERATION:
                        self.parseEnumeration()
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
        let location = self.token.location
        self.nextToken()
        self.visualToken.kind = .module
        let label = self.parseLabel()
        var module:Module = ModuleInstance(label:"")
        module.addDeclaration(location)
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
                        case .ENUMERATION:
                            self.parseEnumeration()
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
        
    private func parseHashString() -> String
        {
        if self.token.isHashStringLiteral
            {
            let string = self.token.hashStringLiteral
            self.nextToken()
            return(string)
            }
        self.reportingContext.dispatchError(at: self.token.location, message: "A symbol was expected but \(self.token) was found.")
        self.nextToken()
        return("#HashString")
        }
        
    private func parseEnumeration()
        {
        self.nextToken()
        let location = self.token.location
        let label = self.parseLabel()
        let enumeration = Enumeration(label: label)
        enumeration.addDeclaration(location)
        self.currentContext.addSymbol(enumeration)
        if self.token.isGluon
            {
            self.nextToken()
            let type = self.parseType()
            enumeration.rawType = type
            }
        let someCases = self.parseBraces
            {
            () -> EnumerationCases in
            var cases = EnumerationCases()
            while !self.token.isRightBrace
                {
                self.parseComma()
                cases.append(self.parseEnumerationCase())
                }
            return(cases)
            }
        enumeration.cases = someCases
        }
        
    private func parseLiteral() -> LiteralExpression
        {
        var literal:LiteralExpression
        if self.token.isIntegerLiteral
            {
            literal = LiteralExpression(.integer(self.token.integerLiteral))
            }
        else if self.token.isStringLiteral
            {
            literal = LiteralExpression(.string(self.token.stringLiteral))
            }
        else if self.token.isHashStringLiteral
            {
            literal = LiteralExpression(.symbol(self.token.hashStringLiteral))
            }
        else
            {
            literal = LiteralExpression(.integer(0))
            self.reportingContext.dispatchError(at: self.token.location, message: "Integer, String or Symbol literal expected for rawValue of ENUMERATIONCASE")
            }
        self.nextToken()
        return(literal)
        }
        
    private func parseEnumerationCase() -> EnumerationCase
        {
        let location = self.token.location
        let name = self.parseHashString()
        var types = Array<Class>()
        let aCase = EnumerationCase(symbol: name,types: types)
        aCase.addDeclaration(location)
        if self.token.isLeftPar
            {
            self.parseParentheses
                {
                repeat
                    {
                    self.parseComma()
                    let type = self.parseType()
                    types.append(type)
                    }
                while self.token.isComma
                }
            }
        if self.token.isAssign
            {
            self.nextToken()
            aCase.rawValue = self.parseLiteral()
            }
        return(aCase)
        }
        
    private func parseSlot() -> Slot
        {
        self.nextToken()
        self.visualToken.kind = .classSlot
        let location = self.token.location
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
            aSlot.addDeclaration(location)
            aSlot.writeBlock = writeBlock
            aSlot.readBlock = readBlock
            slot = aSlot
            }
        else
            {
            slot = Slot(label: label,type: type ?? VoidClass.voidClass)
            slot?.addDeclaration(location)
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
        let location = self.token.location
        self.visualToken.kind = .class
        let label = self.parseLabel()
        let aClass = Class(label: label)
        aClass.addDeclaration(location)
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
        let location = self.token.location
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
        constant.addDeclaration(location)
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
        let location = self.token.location
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
        else if self.token.isLeftPar
            {
            return(self.parseMethodType())
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
        holder.addDeclaration(location)
        return(SymbolHolderClass(symbolHolder: holder))
        }
        
    private func parseMethodType() -> MethodType
        {
        let location = self.token.location
        let types = self.parseParentheses
            {
            () -> [Class] in
            var types = Classes()
            repeat
                {
                self.parseComma()
                let type = self.parseType()
                types.append(type)
                }
            while self.token.isComma
            return(types)
            }
        if !self.token.isRightArrow
            {
            self.reportingContext.dispatchError(at: location, message: "'->' was expected in a method reference type but '\(self.token)' was found.")
            }
        self.nextToken()
        let returnType = self.parseType()
        let reference = MethodType(label: Argon.nextName("1Method"),types: types,returnType: returnType)
        reference.addDeclaration(location)
        return(reference)
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
            repeat
                {
                self.parseComma()
                if !self.token.isRightPar
                    {
                    parameters.append(self.parseParameter())
                    }
                }
            while self.token.isComma && !self.token.isRightPar
            return(parameters)
            }
        return(list)
        }
        
    @discardableResult
    private func parseMethod() -> ArgonWorx.Method
        {
        self.nextToken()
        let location = self.token.location
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
            existingMethod!.addReference(location)
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
            method.addDeclaration(location)
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
        let location = self.token.location
        let expression = self.parseArrayExpression()
        expression.addDeclaration(location)
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
        let location = self.token.location
        var lhs = self.parseBooleanExpression()
        lhs.addDeclaration(location)
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
        
    private func parseBooleanExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseRelationalExpression()
        lhs.addDeclaration(location)
        while self.token.isAnd || self.token.isOr
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseRelationalExpression() -> Expression
        {
        let location = self.token.location
        let lhs = self.parseArithmeticExpression()
        lhs.addDeclaration(location)
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
        let location = self.token.location
        var lhs = self.parseMultiplicativeExpression()
        lhs.addDeclaration(location)
        while self.token.isAdd || self.token.isSub
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseMultiplicativeExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseBitExpression()
        lhs.addDeclaration(location)
        while self.token.isMul || self.token.isDiv || self.token.isModulus
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseBitExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseSlotExpression()
        lhs.addDeclaration(location)
        while self.token.isBitAnd || self.token.isBitOr || self.token.isBitXor
            {
            let symbol = token.symbol
            self.nextToken()
            lhs = lhs.operation(symbol,self.parseExpression())
            }
        return(lhs)
        }
        
    private func parseSlotExpression() -> Expression
        {
        let location = self.token.location
        var lhs = self.parseUnaryExpression()
        lhs.addDeclaration(location)
        while self.token.isRightArrow
            {
            self.nextToken()
            lhs = lhs.slot(self.parseSlotSelectorExpression())
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
            let location = self.token.location
            let term = self.parseTerm()
            term.addDeclaration(location)
            return(term)
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
            self.reportingContext.dispatchError(at: self.token.location, message: "This expression is invalid.")
            fatalError("Invalid parse state \(self.lastToken) \(self.token)")
            }
        }
        
    private func parseSlotSelectorExpression() -> Expression
        {
        self.visualToken.kind = .classSlot
        let location = self.token.location
        let first = self.parseLabel()
        let lhs = SlotSelectorExpression(selector: first)
        lhs.addDeclaration(location)
        return(lhs)
        }
        
    private func parseIdentifierTerm() -> Expression
        {
        let location = self.token.location
        let name = self.parseName()
        let aSymbol = self.currentContext.lookup(name: name)
        if let symbol = aSymbol as? Class
            {
            if self.token.isLeftPar
                {
                self.parseParentheses { }
                return(InstanciationTerm(class: symbol))
                }
//            else if self.token.isRightArrow
//                {
//                var lhs:Expression = LocalAccessExpression(name: name, location: self.token.location, context: self.currentContext, reportingContext: self.reportingContext)
//                while self.token.isRightArrow
//                    {
//                    self.nextToken()
//                    let slotExpression = self.parseSlotSelectorExpression()
//                    lhs = lhs.slot(slotExpression)
//                    }
//                lhs.addDeclaration(location)
//                return(lhs)
//                }
            else
                {
                let literal = LiteralExpression(.class(symbol))
                literal.addDeclaration(location)
                return(literal)
                }
            }
        else if let symbol = aSymbol as? Module
            {
//            if self.token.isRightArrow
//                {
//                let operation = self.token.symbol
//                var lhs:Expression = LiteralExpression(.module(symbol))
//                while self.token.isRightArrow
//                    {
//                    self.nextToken()
//                    let slotExpression = self.parseExpression()
//                    lhs = lhs.operation(operation,slotExpression)
//                    }
//                return(lhs)
//                }
//            else
//                {
                let module = LiteralExpression(.module(symbol))
                module.addDeclaration(location)
                return(module)
//                }
            }
        if self.token.isLeftPar
            {
            return(self.parseInvocationTerm(name))
            }
        else
            {
            print("NAME: \(name)")
            let read = LocalAccessExpression(name: name, location: self.token.location, context: self.currentContext, reportingContext: self.reportingContext)
            read.addDeclaration(location)
            return(read)
            }
        }
        
    private func parseClosureTerm() -> BlockExpression
        {
        let closure = ClosureBlock()
        let location = self.token.location
        self.parseBraces
            {
            if self.token.isWith
                {
                self.nextToken()
                closure.parameters = self.parseParameters()
                }
            if self.token.isRightArrow
                {
                self.nextToken()
                closure.returnType = self.parseType()
                }
            for parameter in closure.parameters
                {
                closure.addLocalSlot(parameter)
                }
            while !self.token.isRightBrace
                {
                self.parseBlock(into: closure)
                }
            }
        let block = BlockExpression(block: closure)
        block.addDeclaration(location)
        return(block)
        }
        
    private func parseInvocationTerm(method: Method) -> Expression
        {
        let location = self.token.location
        let args = self.parseParentheses
            {
            () -> Arguments in
            var arguments = Arguments()
            for parameter in method.proxyParameters
                {
                self.parseComma()
                var tag: String = ""
                if !parameter.isVisible
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
        let expression = MethodInvocationExpression(method: method,arguments: args)
        expression.addDeclaration(location)
        return(expression)
        }
        
    private func parseArgument() -> Argument
        {
        if self.token.isIdentifier && self.peekToken1().isGluon
            {
            let tag = token.identifier
            self.nextToken()
            self.nextToken()
            return(Argument(tag: tag, value: self.parseExpression()))
            }
        else if self.peekToken1().isComma || self.peekToken1().isRightPar
            {
            return(Argument(tag: nil, value: self.parseExpression()))
            }
        else
            {
            let expression = self.parseExpression()
            return(Argument(tag: nil, value: expression))
            }
        }
        
    private func parseInvocationTerm(_ name:Name) -> Expression
        {
        let location = self.token.location
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
                arguments.append(self.parseArgument())
                }
            return(arguments)
            }
        let expression = InvocationExpression(name: name,arguments: args, location: self.token.location,namingContext: self.currentContext, reportingContext: self.reportingContext)
        expression.addDeclaration(location)
        return(expression)
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
        let location = self.token.location
        let value = self.parseParentheses
            {
            return(self.parseExpression())
            }
        let selectBlock = SelectBlock(value: value)
        selectBlock.addDeclaration(location)
        block.addBlock(selectBlock)
        self.parseBraces
            {
            while !self.token.isRightBrace && !self.token.isOtherwise
                {
                if !self.token.isWhen
                    {
                    self.dispatchError("WHEN expected after SELECT clause")
                    self.nextToken()
                    }
                self.nextToken()
                let location1 = self.token.location
                let inner = self.parseParentheses
                    {
                    self.parseExpression()
                    }
                let when = WhenBlock(condition: inner)
                when.addDeclaration(location1)
                selectBlock.addWhen(block: when)
                self.parseBraces
                    {
                    self.parseBlock(into: when)
                    }
                }
            if self.token.isOtherwise
                {
                let otherwise = OtherwiseBlock()
                self.nextToken()
                self.parseBraces
                    {
                    self.parseBlock(into: otherwise)
                    }
                selectBlock.addOtherwise(block: otherwise)
                }
            }
        }
        
    private func parseElseIfBlock(into block: IfBlock)
        {
        self.nextToken()
        let location = self.token.location
        let expression = self.parseExpression()
        let statement = ElseIfBlock(condition: expression)
        block.elseBlock = statement
        statement.addDeclaration(location)
        self.parseBraces
            {
            self.parseBlock(into: statement)
            }
        if self.token.isElse && self.peekToken1().isIf
            {
            self.nextToken()
            self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            self.parseBraces
                {
                self.parseBlock(into: elseClause)
                }
            }
        }
        
    private func parseIfBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        let expression = self.parseExpression()
        let statement = IfBlock(condition: expression)
        block.addBlock(statement)
        statement.addDeclaration(location)
        self.parseBraces
            {
            self.parseBlock(into: statement)
            }
        if self.token.isElse && self.peekToken1().isIf
            {
            self.nextToken()
            self.parseElseIfBlock(into: statement)
            }
        if self.token.isElse
            {
            self.nextToken()
            let elseClause = ElseBlock()
            statement.elseBlock = elseClause
            self.parseBraces
                {
                self.parseBlock(into: elseClause)
                }
            }

        }
        
    private func parseLetBlock(into block: Block)
        {
        let location = self.token.location
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
        let statement = LetBlock(name: someVariable,slot:localSlot,location: self.token.location,namingContext: block,value: value)
        statement.addDeclaration(location)
        block.addBlock(statement)
        }
        
    private func parseReturnBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        let value = self.parseParentheses
            {
            self.parseExpression()
            }
        let returnBlock = ReturnBlock()
        returnBlock.addDeclaration(location)
        returnBlock.value = value
        block.addBlock(returnBlock)
        }
        
    private func parseWhileBlock(into block: Block)
        {
        let location = self.token.location
        self.nextToken()
        let expression = self.parseRelationalExpression()
        let statement = WhileBlock(condition: expression)
        statement.addDeclaration(location)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        }
        
    private func parseInductionVariable()
        {
        }
        
    private func parseForkBlock(into block: Block)
        {
        let location = self.token.location
        let variableName = self.parseLabel()
        self.parseInductionVariable()
        let statement = ForBlock(name: variableName)
        statement.addDeclaration(location)
        self.parseBlock(into: statement)
        block.addBlock(statement)
        }
        
    private func parseLoopBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        let (start,end,update) = self.parseLoopConstraints()
        let statement = LoopBlock(start: start,end: end,update: update)
        statement.addDeclaration(location)
        block.addBlock(statement)
        self.parseBlock(into: statement)
        }
        
    private func parseLoopConstraints() -> ([Expression],Expression,[Expression])
        {
        var start = Array<Expression>()
        var end:Expression = Expression()
        var update = Array<Expression>()
        self.parseParentheses
            {
            repeat
                {
                self.parseComma()
                start.append(self.parseExpression())
                }
            while self.token.isComma
            if !self.token.isGluon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "'::' was expected between LOOP clauses.")
                }
            self.nextToken()
            end = self.parseExpression()
            if !self.token.isGluon
                {
                self.reportingContext.dispatchError(at: self.token.location, message: "'::' was expected between LOOP clauses.")
                }
            self.nextToken()
            repeat
                {
                self.parseComma()
                update.append(self.parseExpression())
                }
            while self.token.isComma
            }
        return((start,end,update))
        }
        
    private func parseSignalBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        self.parseParentheses
            {
            if self.nextToken().isHashStringLiteral
                {
                let symbol = self.token.hashStringLiteral
                let signal = SignalBlock(symbol: symbol)
                signal.addDeclaration(location)
                block.addBlock(signal)
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
        let location = self.token.location
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
        let parameter = Parameter(label: tag, type: type,isVisible: isHidden,isVariadic: isVariadic)
        parameter.addDeclaration(location)
        return(parameter)
        }
        
    private func parseFunction()
        {
        self.nextToken()
        let location = self.token.location
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
        function.addDeclaration(location)
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
        let location = self.token.location
        self.visualToken.kind = .type
        let label = self.parseLabel()
        if !self.token.isIs
            {
            self.dispatchError("IS expeected after new name for type.")
            }
        self.nextToken()
        let type = self.parseType()
        let alias = TypeAlias(label: label,type: type)
        alias.addDeclaration(location)
        self.currentContext.addSymbol(alias)
        }
        
    private func parseHandleBlock(into block: Block)
        {
        self.nextToken()
        let location = self.token.location
        let handler = HandlerBlock()
        handler.addDeclaration(location)
        block.addBlock(handler)
        self.pushContext(handler)
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
        self.popContext()
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
