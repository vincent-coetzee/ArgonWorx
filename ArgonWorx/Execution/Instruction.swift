//
//  Instruction.swift
//  Instruction
//
//  Created by Vincent Coetzee on 27/7/21.
//

import Foundation
import Interpreter

extension Word
    {
    init(float: Argon.Float)
        {
        self.init(float.bitPattern)
        }
        
    init(integer: Int)
        {
        self = Word(bitPattern: integer)
        }
    }
    
public struct ProcessorContext
    {
    public var stackAddress: Word
        {
        return(0)
        }
    }
    
public struct Instruction
    {
    public enum Opcode
        {
        case iadd,isub,imul,idiv,imod,ipow
        case fadd,fsub,fmul,fdiv,fmod,fpow
        case lsr,ssr,lcr,ltr,str,lar,sra
        }
        
    public enum Constant
        {
        case integer(Int)
        case float(Argon.Float)
        case string(Word)
        case address(Word)
        
        public var wordValue: Word
            {
            switch(self)
                {
                case .integer(let integer):
                    return(Word(integer: integer))
                case .float(let float):
                    return(Word(float: float))
                case .string(let address):
                    return(address)
                case .address(let address):
                    return(address)
                }
            }
            
        public var integerValue: Int
            {
            switch(self)
                {
                case .integer(let integer):
                    return(integer)
                case .float(let float):
                    return(Int(float))
                case .string(let address):
                    return(Int(address))
                case .address(let address):
                    return(Int(address))
                }
            }
            
        public var floatValue: Argon.Float
            {
            switch(self)
                {
                case .integer(let integer):
                    return(Argon.Float(integer))
                case .float(let float):
                    return(float)
                case .string(let address):
                    return(Argon.Float(address))
                case .address(let address):
                    return(Argon.Float(address))
                }
            }
        }
        
    public enum Operand
        {
        case none
        case slot(Word,Word)
        case stack(Word)
        case constant(Constant)
        
        public func value(in context:ProcessorContext) -> Word
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .slot(let address,let offset):
                    return(WordAtAddressAtOffset(address,offset))
                case .stack(let offset):
                    return(WordAtAddressAtOffset(context.stackAddress,offset))
                case .constant(let constant):
                    return(constant.wordValue)
                }
            }
            
        public func integerValue(in context:ProcessorContext) -> Int
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .slot(let address,let offset):
                    return(IntegerAtAddressAtOffset(address,offset))
                case .stack(let offset):
                    return(IntegerAtAddressAtOffset(context.stackAddress,offset))
                case .constant(let constant):
                    return(constant.integerValue)
                }
            }
            
        public func setIntegerValue(_ value:Int,in context:ProcessorContext)
            {
            switch(self)
                {
                case .none:
                    break
                case .slot(let address,let offset):
                    return(SetIntegerAtAddressAtOffset(value,address,offset))
                case .stack(let offset):
                    return(SetIntegerAtAddressAtOffset(value,context.stackAddress,offset))
                case .constant(let constant):
                    break
                }
            }
            
        public func floatValue(in context:ProcessorContext) -> Argon.Float
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .slot(let address,let offset):
                    return(FloatAtAddressAtOffset(address,offset))
                case .stack(let offset):
                    return(FloatAtAddressAtOffset(context.stackAddress,offset))
                case .constant(let constant):
                    return(constant.floatValue)
                }
            }
            
        public func setFloatValue(_ value:Argon.Float,in context:ProcessorContext)
            {
            switch(self)
                {
                case .none:
                    break
                case .slot(let address,let offset):
                    return(SetFloatAtAddressAtOffset(value,address,offset))
                case .stack(let offset):
                    return(SetFloatAtAddressAtOffset(value,context.stackAddress,offset))
                case .constant(let constant):
                    break
                }
            }
            
        }
        
    private let opcode:Opcode
    private let lhs:Operand
    private let rhs:Operand
    private let output:Operand
    
    init(opcode:Opcode,lhs:Operand,rhs:Operand,output:Operand)
        {
        self.opcode = opcode
        self.lhs = lhs
        self.rhs = rhs
        self.output = output
        }

    public func execute(in context:ProcessorContext)
        {
        switch(self.opcode)
            {
            case .iadd:
                self.output.setIntegerValue(self.lhs.integerValue(in: context) + self.rhs.integerValue(in: context),in: context)
            case .isub:
                self.output.setIntegerValue(self.lhs.integerValue(in: context) - self.rhs.integerValue(in: context),in: context)
            case .imul:
                self.output.setIntegerValue(self.lhs.integerValue(in: context) * self.rhs.integerValue(in: context),in: context)
            case .idiv:
                self.output.setIntegerValue(self.lhs.integerValue(in: context) / self.rhs.integerValue(in: context),in: context)
            case .imod:
                self.output.setIntegerValue(self.lhs.integerValue(in: context) % self.rhs.integerValue(in: context),in: context)
            case .fadd:
                self.output.setFloatValue(self.lhs.floatValue(in: context) + self.rhs.floatValue(in: context),in: context)
            case .fsub:
                self.output.setFloatValue(self.lhs.floatValue(in: context) - self.rhs.floatValue(in: context),in: context)
            case .fmul:
                self.output.setFloatValue(self.lhs.floatValue(in: context) * self.rhs.floatValue(in: context),in: context)
            case .fdiv:
                self.output.setFloatValue(self.lhs.floatValue(in: context) / self.rhs.floatValue(in: context),in: context)
            case .fmod:
                self.output.setFloatValue(self.lhs.floatValue(in: context).truncatingRemainder(dividingBy: self.rhs.floatValue(in: context)),in: context)
            default:
                break
            }
        }
    }
