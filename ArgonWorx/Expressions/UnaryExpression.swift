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
        
    public override func realize(_ compiler:Compiler)
        {
        self.rhs.realize(compiler)
        }
        
    public override func emitCode(into instance: MethodInstance, using: CodeGenerator)
        {
        self.rhs.emitCode(into: instance, using: using)
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
        let register = using.registerFile.findRegister(for: nil, instance: instance)
        instance.append(opcode,rhs.valueLocation,.none,.register(register))
        }
    }
