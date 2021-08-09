//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class BinaryExpression: Expression
    {
    private let operation: Token.Symbol
    private let rhs: Expression
    private let lhs: Expression
    
    init(_ lhs:Expression,_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        }
        
    public override func findType() -> Class?
        {
        let leftType = self.lhs.findType()
        let rightType = self.rhs.findType()
        if leftType.isNil || rightType.isNil || leftType != rightType
            {
            return(nil)
            }
        self.annotatedType = leftType!
        return(leftType)
        }
        
    public override func realize(_ compiler:Compiler)
        {
        self.lhs.realize(compiler)
        self.rhs.realize(compiler)
        }
        
    public override func generateConstraints(into inferencer:TypeInferencer)
        {
        if let type1 = self.lhs.findType(),let type2 = self.rhs.findType()
            {
            inferencer.addConstraint(TypeInferencer.TypeConstraint.function("\(self.operation)",.named(type1),.named(type2)))
            }
        }
        
    public override func emitCode(into instance: MethodInstance,using generator: CodeGenerator)
        {
        var opcode:Instruction.Opcode = .nop
        switch(self.operation)
            {
            case .add:
                if self.annotatedType == ArgonModule.argonModule.float
                    {
                    opcode = .fadd
                    }
                else
                    {
                    opcode = .iadd
                    }
            case .sub:
                if self.annotatedType == ArgonModule.argonModule.float
                    {
                    opcode = .fsub
                    }
                else
                    {
                    opcode = .isub
                    }
            case .mul:
                if self.annotatedType == ArgonModule.argonModule.float
                    {
                    opcode = .fmul
                    }
                else
                    {
                    opcode = .imul
                    }
            case .div:
                if self.annotatedType == ArgonModule.argonModule.float
                    {
                    opcode = .fdiv
                    }
                else
                    {
                    opcode = .idiv
                    }
            case .modulus:
                if self.annotatedType == ArgonModule.argonModule.float
                    {
                    opcode = .fmod
                    }
                else
                    {
                    opcode = .imod
                    }
            default:
                break
            }
        self.lhs.emitCode(into: instance, using: generator)
        let lhsLocation = lhs.valueLocation
        self.rhs.emitCode(into: instance, using: generator)
        let rhsLocation = rhs.valueLocation
        let outputRegister = generator.registerFile.findRegister(for: nil, instance: instance)
        instance.append(opcode,lhsLocation,rhsLocation,.register(outputRegister))
        self.valueLocation = .register(outputRegister)
        }
    }
