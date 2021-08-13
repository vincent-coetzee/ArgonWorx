//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public enum TypeResult
    {
    public var isMismatch: Bool
        {
        switch(self)
            {
            case .mismatch:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isUndefined: Bool
        {
        switch(self)
            {
            case .undefined:
                return(true)
            default:
                return(false)
            }
        }
        
    public var isClass: Bool
        {
        switch(self)
            {
            case .class:
                return(true)
            default:
                return(false)
            }
        }
        
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
        
    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    init(coder: NSCoder)
        {
        self.operation = coder.decodeObject(forKey: "operation") as! Token.Symbol
        self.lhs = coder.decodeObject(forKey:"lhs") as! Expression
        self.rhs = coder.decodeObject(forKey:"rhs") as! Expression
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.operation,forKey: "operation")
        coder.encode(self.lhs,forKey: "lhs")
        coder.encode(self.rhs,forKey: "rhs")
        }
        
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)BINARY EXPRESSION()")
        print("\(padding)\t\(self.operation)")
        lhs.dump(depth: depth + 1)
        rhs.dump(depth: depth + 1)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
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
        try self.lhs.emitCode(into: instance, using: generator)
        try self.rhs.emitCode(into: instance, using: generator)
        let outputRegister = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        instance.append(opcode,lhs.place,rhs.place,.register(outputRegister))
        self._place = .register(outputRegister)
        }
    }
