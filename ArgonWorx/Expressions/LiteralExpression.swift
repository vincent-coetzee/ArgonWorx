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
        
    public override func emitCode(into instance: MethodInstance,using generator: CodeGenerator)
        {
        let register = generator.registerFile.findRegister(for: nil, instance: instance)
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
        self.valueLocation = .register(register)
        }
    }
