//
//  Instruction.swift
//  Instruction
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation
import Interpreter
import SwiftUI
    
public struct ExecutionError:Error
    {
    public let context:ExecutionContext
    public let errorType:ExecutionErrorType
    }

public enum ExecutionErrorType:Error
    {
    case invalidIntegerOperand
    case invalidFloatOperand
    case invalidWordOperand
    case invalidRegister
    }
    
public protocol RawConvertible
    {
    var rawValue: Int { get }
    }
    
public protocol BitCodable
    {
    func encode(in:BitEncoder)
    }
    
public class Instruction:Identifiable,Encodable,Decodable
    {
    public var id = UUID()
    
    public static func loadValue(ofSlotNamed:String,instanceType:Class,instance:Word,into:Instruction.Register) -> [Instruction]
        {
        let offset = instanceType.layoutSlot(atLabel: ofSlotNamed)!.offset
        var array = Array<Instruction>()
        array.append(Instruction(.load,operand1: .address(instance),result: .register(.r2)))
        array.append(Instruction(.load,operand1: .slot(.r2,Word(offset)),result: .register(into)))
        return(array)
        }
        
    public enum Register:Int,Comparable,CaseIterable,Identifiable,Encodable,Decodable
        {
        public static let bitWidth = 8
        
        public static func <(lhs:Register,rhs:Register) -> Bool
            {
            return(lhs.rawValue < rhs.rawValue)
            }
            
        case code = 0       /// This points to the current code segment
        case stack       /// Points to the current stack segment
        case fixed       /// Points to the fixed or static segment, we could not call it static because static is a reserved word
        case managed    /// Points to the current managed segment
        case cp           /// The code pointer points to the current routine been executed,
        case ip           /// the ip points to teh instruction being executed
        case sp           /// the sp points to the top of the stack
        case bp           /// the bp points to the base of the current stack frame
        case fp           /// the fp points to the next available slot in the fixed segment
        case mp          /// the mp points to the next avaialble slot in the managed segmeng
        case r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15
        case fr0,fr1,fr2,fr3,fr4,fr5,fr6,fr7,fr8,fr9,fr10,fr11,fr12,fr13,fr14,fr15
        
        public var isFloatingPoint: Bool
            {
            return(self >= .fr0 && self <= .fr15)
            }
            
        public var id:Int
            {
            return(self.rawValue)
            }
        }
        
    public enum Opcode:Int,Encodable,Decodable
        {
        public static let bitWidth = 8
        
        case nop = 0
        case iadd,isub,imul,idiv,imod,ipow
        case fadd,fsub,fmul,fdiv,fmod,fpow
        case load,store
        case br,breq,brneq
        case inc,dec
        case make
        case call,ret
        case push,pop
        case loopeq,loopneq,loopnz,loopz
        case scat,srev,scmp,scnt,scpy
        case rein
        case sig,hnd
        case zero
        }
        
    public enum Operand:Encodable,Decodable
        {
        case none
        case register(Register)
        case slot(Register,Word)
        case float(Argon.Float)
        case integer(Argon.Integer)
        case address(Word)
        case stack(Word)
        case array(Register,Word)
        case label(Argon.Integer)
        
        public var isNotNone: Bool
            {
            switch(self)
                {
                case .none:
                    return(false)
                default:
                    return(true)
                }
            }
            
    public var address: Word
        {
        switch(self)
            {
            case .address(let word):
                return(word)
            default:
                fatalError("Error")
            }
        }
            
        public var text: String
            {
            switch(self)
                {
                case .none:
                    return("")
                case .register(let register):
                    return("\(register)")
                case .slot(let register,let offset):
                    return("[\(register) + \(offset)]")
                case .float(let float):
                    return("\(float)")
                case .integer(let register):
                    return("\(register)")
                case .address(let register):
                    return("0x\(register.addressString)")
                case .stack(let register):
                    return("SS:[\(register)]")
                case .array(let register,let offset):
                    return("\(register)+\(offset)")
                case .label(let integer):
                    let label = integer >= 0 ? "+" : ""
                    return("IP \(label) \(integer)")
                }
            }

        public func floatValue(in context:ExecutionContext) throws -> Argon.Float
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .register(let register):
                    if !register.isFloatingPoint
                        {
                        throw(ExecutionErrorType.invalidRegister)
                        }
                    return(Argon.Float(bitPattern: context.registers[register.rawValue].withoutTag))
                case .slot(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(Argon.Float(bitPattern: pointer?.pointee.withoutTag ?? 0))
                case .float(let float):
                    return(float)
                case .integer:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .address:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .stack(let offset):
                    let value = context.bp + offset
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value))
                    return(Argon.Float(bitPattern: pointer?.pointee.withoutTag ?? 0))
                case .array(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(Argon.Float(bitPattern: pointer?.pointee.withoutTag ?? 0))
                case .label:
                    return(0)
                }
            }
            
        public func wordValue(in context:ExecutionContext) throws -> Word
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .register(let register):
                    return(context.registers[register.rawValue].withoutTag)
                case .slot(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer(let integer):
                    return(Word(bitPattern: integer))
                case .address(let word1):
                    return(word1)
                case .stack(let offset):
                    let value = context.bp + offset
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .array(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .label(let integer):
                    return(Word(bitPattern: integer))
                    
                }
            }
            
        public func value(in context:ExecutionContext) throws -> Word
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    return(context.registers[register.rawValue].withoutTag)
                case .slot(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .float(let float):
                    return(float.bitPattern.tagged(with:.float))
                case .integer(let integer):
                    return(Word(bitPattern: integer))
                case .address(let word1):
                    return(word1)
                case .stack(let offset):
                    let value = context.bp + offset
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .array(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Word>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee.withoutTag ?? 0)
                case .label(let integer):
                    return(Word(bitPattern: integer))
                }
            }
            
        public func intValue(in context:ExecutionContext) throws -> Argon.Integer
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidFloatOperand)
                case .register(let register):
                    return(Int64(bitPattern: UInt64(context.registers[register.rawValue])))
                case .slot(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Int64>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee ?? 0)
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer(let integer):
                    return(Int64(integer))
                case .address(let word1):
                    return(Int64(word1))
                case .stack(let offset):
                    let value = context.bp + offset
                    let pointer = UnsafePointer<Int64>(bitPattern: UInt(value))
                    return(pointer?.pointee ?? 0)
                case .array(let object,let offset):
                    let value = context.registers[object.rawValue]
                    let pointer = UnsafePointer<Int64>(bitPattern: UInt(value + offset))
                    return(pointer?.pointee ?? 0)
                case .label(let integer):
                    return(Argon.Integer(integer))
                }
            }
            
        public func setIntValue(_ value:Int64,in context:ExecutionContext) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .register(let register):
                    context.registers[register.rawValue] = UInt64(bitPattern: value)
                case .slot(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Int64>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .float:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .address(let word1):
                    break
                case .stack(let offset):
                    let location = context.bp + offset
                    let pointer = UnsafeMutablePointer<Int64>(bitPattern: UInt(location))
                    pointer?.pointee = value
                case .array(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Int64>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .label:
                    break
                }
            }
            
        public func setValue(_ value:Word,in context:ExecutionContext) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .register(let register):
                    context.setRegister(value,atIndex: register)
                case .slot(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .float:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .address:
                    throw(ExecutionErrorType.invalidWordOperand)
                case .stack(let offset):
                    let location = context.bp + offset
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(location))
                    pointer?.pointee = value
                case .array(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value
                case .label:
                    break
                }
            }
            
        public func setFloatValue(_ value:Argon.Float,in context:ExecutionContext) throws
            {
            switch(self)
                {
                case .none:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .register(let register):
                    if !register.isFloatingPoint
                        {
                        throw(ExecutionErrorType.invalidFloatOperand)
                        }
                    context.registers[register.rawValue] = value.bitPattern
                case .slot(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value.bitPattern.tagged(with: .float)
                case .float:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .integer:
                    throw(ExecutionErrorType.invalidIntegerOperand)
                case .address(let word1):
                    break
                case .stack(let offset):
                    let location = context.bp + offset
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(location))
                    pointer?.pointee = value.bitPattern.tagged(with: .float)
                case .array(let object,let offset):
                    let inner = context.registers[object.rawValue]
                    let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(inner + offset))
                    pointer?.pointee = value.bitPattern.tagged(with: .float)
                case .label:
                    break
                }
            }
        }

    public var operandText: String
        {
        var text = Array<String>()
        if self.operand1.isNotNone
            {
            text.append(self.operand1.text)
            }
        if self.operand2.isNotNone
            {
            text.append(self.operand2.text)
            }
        if self.result.isNotNone
            {
            text.append(self.result.text)
            }
        return(text.joined(separator: ","))
        }
        
    public let opcode:Opcode
    public let operand1:Operand
    public let operand2:Operand
    public let result:Operand
    
    public init(_ opcode:Opcode,operand1:Operand = .none,operand2:Operand = .none,result:Operand = .none)
        {
        self.opcode = opcode
        self.operand1 = operand1
        self.operand2 = operand2
        self.result = result
        }

    public func execute(in context:ExecutionContext) throws
        {
        switch(self.opcode)
            {
            case .nop:
                break
            case .iadd:
                try self.result.setIntValue(self.operand1.intValue(in: context) + self.operand2.intValue(in: context),in: context)
            case .isub:
                try self.result.setIntValue(self.operand1.intValue(in: context) - self.operand2.intValue(in: context),in: context)
            case .imul:
                try self.result.setIntValue(self.operand1.intValue(in: context) * self.operand2.intValue(in: context),in: context)
            case .idiv:
                try self.result.setIntValue(self.operand1.intValue(in: context) / self.operand2.intValue(in: context),in: context)
            case .imod:
                try self.result.setIntValue(self.operand1.intValue(in: context) % self.operand2.intValue(in: context),in: context)
            case .load:
                try self.result.setValue(self.operand1.value(in: context),in: context)
            case .store:
                try self.result.setValue(self.operand1.value(in: context),in: context)
            case .ipow:
                var value = try self.operand1.intValue(in: context)
                let mul = value
                var power = try self.operand2.intValue(in: context)
                while power > 0
                    {
                    value *= mul
                    power -= 1
                    }
                try self.result.setIntValue(value,in: context)
            case .fadd:
                try self.result.setFloatValue(self.operand1.floatValue(in: context) + self.operand2.floatValue(in: context),in: context)
            case .fsub:
                try self.result.setFloatValue(self.operand1.floatValue(in: context) - self.operand2.floatValue(in: context),in: context)
            case .fmul:
                try self.result.setFloatValue(self.operand1.floatValue(in: context) * self.operand2.floatValue(in: context),in: context)
            case .fdiv:
                try self.result.setFloatValue(self.operand1.floatValue(in: context) / self.operand2.floatValue(in: context),in: context)
            case .fmod:
            try self.result.setFloatValue(self.operand1.floatValue(in: context).truncatingRemainder(dividingBy: self.operand2.floatValue(in: context)),in: context)
            case .fpow:
                try self.result.setFloatValue(pow(self.operand1.floatValue(in: context),self.operand2.floatValue(in: context)),in: context)
            case .make:
                let targetClassPointer = InnerClassPointer(address: self.operand1.address)
                let extraBytes = try self.operand2.intValue(in: context)
                let address = context.managedSegment.allocateObject(sizeInBytes: targetClassPointer.sizeInBytes + Int(extraBytes))
                let pointer = InnerInstancePointer(address: address)
                pointer.classPointer = targetClassPointer
                pointer.magicNumber = targetClassPointer.magicNumber
                try self.result.setValue(pointer.address,in:context)
            case .push:
                context.stackSegment.push(try self.operand1.value(in: context))
            case .pop:
                try self.result.setValue(context.stackSegment.pop(),in: context)
            case .loopeq:
                let value = try self.operand1.value(in:context)
                if value == 1
                    {
                    let offset = try self.operand2.intValue(in: context)
                    context.ip = context.ip + Int(offset)
                    }
            case .inc:
                try  self.result.setIntValue(self.operand1.intValue(in: context) + 1,in:context)
            case .dec:
                try  self.result.setIntValue(self.operand1.intValue(in: context) - 1,in:context)
            case .scat:
                let address1 = try self.operand1.value(in: context)
                let address2 = try self.operand2.value(in: context)
                let pointer1 = InnerStringPointer(address: address1)
                let pointer2 = InnerStringPointer(address: address2)
                let string1 = pointer1.string
                let string2 = pointer2.string
                let newPointer = InnerStringPointer.allocateString(string1+string2, in: context.managedSegment)
                try self.result.setValue(newPointer.address,in: context)
            case .scpy:
                let address1 = try self.operand1.value(in: context)
                let pointer1 = InnerStringPointer(address: address1)
                let string1 = pointer1.string
                let newPointer = InnerStringPointer.allocateString(string1, in: context.managedSegment)
                try self.result.setValue(newPointer.address,in: context)
            case .rein:
                break
            case .zero:
                try self.result.setValue(0,in: context)
            default:
                fatalError("Unhandled instruction opcode \(self.opcode)")
            }
        }
        
    public func execute(in binding: Binding<ExecutionContext>) throws
        {
        let context = binding.wrappedValue
        try self.execute(in: context)
        binding.wrappedValue = context
        }
    private func encodeNilable<T>(_ value:T?,in encoder:BitEncoder)
        {
        if value.isNil
            {
            encoder.encode(value: 0,inWidth:1)
            }
        else
            {
            encoder.encode(value: 1,inWidth:2)
            }
        }
    }
