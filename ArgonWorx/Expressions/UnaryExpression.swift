//
//  UnaryExpression.swift
//  UnaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class UnaryExpression: Expression
    {
    private let operation: Token.Symbol
    private let rhs: Expression
    
    init(_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        super.init()
        }
        
    public override var resultType: TypeResult
        {
        return(self.rhs.resultType)
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.rhs.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.rhs.emitCode(into: instance, using: using)
        var opcode:Instruction.Opcode = .nop
        switch(self.operation)
            {
            case .sub:
                if self.resultType == ArgonModule.argonModule.integer
                    {
                    opcode = .ineg
                    }
                else
                    {
                    opcode = .fneg
                    }
            case .bitNot:
                opcode = .iBitNot
            case .not:
                opcode = .not
            default:
                break
            }
        let register = using.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        instance.append(opcode,rhs.place,.none,.register(register))
        self._place = .register(register)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)UNARY EXPRESSION()")
        print("\(padding)\t\(self.operation)")
        self.rhs.dump(depth: depth + 1)
        }
    }
