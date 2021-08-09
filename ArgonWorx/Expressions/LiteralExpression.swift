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
    }

public class LiteralExpression: Expression
    {
    private let literal:Literal
    
    public override func findType() -> Class?
        {
        self.annotatedType = self.lookupType()
        return(self.annotatedType)
        }
        
    public func lookupType() -> Class?
        {
        switch(self.literal)
            {
            case .nil:
                return(nil)
            case .integer:
                return(ArgonModule.argonModule.integer)
            case .float:
                return(ArgonModule.argonModule.float)
            case .string:
                return(ArgonModule.argonModule.string)
            case .boolean:
                return(ArgonModule.argonModule.boolean)
            case .symbol:
                return(ArgonModule.argonModule.symbol)
            case .array:
                return(ArgonModule.argonModule.array)
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
            }
        self.valueLocation = .register(register)
        }
    }
