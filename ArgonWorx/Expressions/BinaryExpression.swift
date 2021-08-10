//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public enum TypeResult
    {
    case `class`(Class)
    case mismatch(Class,Class)
    case undefined
    
    public static func +(lhs:TypeResult,rhs:TypeResult) -> TypeResult
        {
        switch(lhs,rhs)
            {
            case (.class(let class1),.class(let class2)):
                if class1 == class2
                    {
                    return(.class(class1))
                    }
                return(.mismatch(class1,class2))
            case (.mismatch,_):
                fallthrough
            case (_,.mismatch):
                return(.undefined)
            case (.undefined,_):
                fallthrough
            case (_,.undefined):
                return(.undefined)
            default:
                return(.undefined)
            }
        }
        
    public static func ==(lhs:TypeResult,rhs:Class) -> Bool
        {
        switch(lhs)
            {
            case .class(let aClass):
                return(aClass == rhs)
            default:
                return(false)
            }
        }
        
    public func isSubclass(of: Class) -> Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isSubclass(of: of))
            default:
                return(false)
            }
        }
        
    public func isInclusiveSubclass(of: Class) -> Bool
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass.isInclusiveSubclass(of: of))
            default:
                return(false)
            }
        }
        
    public var `class`: Class?
        {
        switch(self)
            {
            case .class(let aClass):
                return(aClass)
            default:
                return(nil)
            }
        }
    
    }
    
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
        
    public override var resultType: TypeResult
        {
        let left = self.lhs.resultType
        let right = self.rhs.resultType
        return(left + right)
        }
        
    public override func realize(_ compiler:Compiler)
        {
        self.lhs.realize(compiler)
        self.rhs.realize(compiler)
        }
        
    public override func emitCode(into instance: MethodInstance,using generator: CodeGenerator)
        {
        var opcode:Instruction.Opcode = .nop
        switch(self.operation)
            {
            case .add:
                if self.resultType == ArgonModule.argonModule.float
                    {
                    opcode = .fadd
                    }
                else
                    {
                    opcode = .iadd
                    }
            case .sub:
                if self.resultType == ArgonModule.argonModule.float
                    {
                    opcode = .fsub
                    }
                else
                    {
                    opcode = .isub
                    }
            case .mul:
                if self.resultType == ArgonModule.argonModule.float
                    {
                    opcode = .fmul
                    }
                else
                    {
                    opcode = .imul
                    }
            case .div:
                if self.resultType == ArgonModule.argonModule.float
                    {
                    opcode = .fdiv
                    }
                else
                    {
                    opcode = .idiv
                    }
            case .modulus:
                if self.resultType == ArgonModule.argonModule.float
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
