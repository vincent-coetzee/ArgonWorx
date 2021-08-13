//
//  LiteralExpression.swift
//  LiteralExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public indirect enum Literal
    {
    case `nil`
    case integer(Argon.Integer)
    case float(Argon.Float)
    case string(String)
    case boolean(Argon.Boolean)
    case symbol(Argon.Symbol)
    case array([Literal])
    case `class`(Class)
    case module(Module)
    }

public class LiteralExpression: Expression
    {
    public var isStringLiteral: Bool
        {
        switch(self.literal)
            {
            case .string:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isIntegerLiteral: Bool
        {
        switch(self.literal)
            {
            case .integer:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isSymbolLiteral: Bool
        {
        switch(self.literal)
            {
            case .symbol:
                return(true)
            default:
                return(false)
            }
        }
        
    public var symbolLiteral: Argon.Symbol
        {
        switch(self.literal)
            {
            case .symbol(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
    public var stringLiteral: String
        {
        switch(self.literal)
            {
            case .string(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
        
    public var integerLiteral: Argon.Integer
        {
        switch(self.literal)
            {
            case .integer(let symbol):
                return(symbol)
            default:
                fatalError("Should not have been called")
            }
        }
        
    private let literal:Literal

    public override var resultType: TypeResult
        {
        switch(self.literal)
            {
            case .nil:
                return(.class(ArgonModule.argonModule.nilClass))
            case .integer:
                return(.class(ArgonModule.argonModule.integer))
            case .float:
                return(.class(ArgonModule.argonModule.float))
            case .string:
                return(.class(ArgonModule.argonModule.string))
            case .boolean:
                return(.class(ArgonModule.argonModule.boolean))
            case .symbol:
                return(.class(ArgonModule.argonModule.symbol))
            case .array:
                return(.class(ArgonModule.argonModule.array))
            case .class:
                return(.class(ArgonModule.argonModule.class))
            case .module:
                return(.class(ArgonModule.argonModule.module))
            }
        }

        
    init(_ literal:Literal)
        {
        self.literal = literal
        super.init()
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)LITERAL EXPRESSION()")
        print("\(padding)\t \(self.literal)")
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let register = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        switch(self.literal)
            {
            case .nil:
                instance.append(.load,.address(0),.none,.register(register))
            case .integer(let integer):
                instance.append(.load,.integer(integer),.none,.register(register))
            case .float(let float):
                instance.append(.load,.float(float),.none,.register(register))
            case .string(let string):
                let address = ManagedSegment.shared.allocateString(string)
                instance.append(.load,.address(address),.none,.register(register))
            case .boolean(let boolean):
                instance.append(.load,.integer(boolean == .trueValue ? 1 : 0))
            case .symbol(let string):
                let address = ManagedSegment.shared.allocateString(string)
                instance.append(.load,.address(address),.none,.register(register))
            case .array:
                fatalError()
            case .class(let aClass):
                instance.append(.load,.address(aClass.memoryAddress),.none,.register(register))
            case .module(let module):
                instance.append(.load,.address(module.memoryAddress),.none,.register(register))
            }
        self._place = .register(register)
        }
    }
