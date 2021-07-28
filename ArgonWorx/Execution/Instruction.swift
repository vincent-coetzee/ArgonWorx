//
//  Instruction.swift
//  Instruction
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

public class Instruction
    {
    public enum Register:Int
        {
        case none = 0
        case code,stack,fixed,managed
        case cp,ip,sp,bp,fp,mp
        case r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15
        case fr1,fr2,fr3,fr4,fr5,fr6,fr7,fr8,fr9,fr10,fr11,fr12,fr13,fr14,fr15
        }
        
    public enum Opcode:Int
        {
        case nop = 0
        case iadd,isub,imul,idiv,imod
        case fadd,fsub,fmul,fdiv,fmod
        }
        
    public enum Operand
        {
        case none
        case register(Register)
        case slot(Word,Word)
        case float(Argon.Float)
        case integer(Argon.Integer)
        case location(Word)
        case stack(Word)
        case array(Word,Word)
        
        fileprivate var rawValue: OperandField
            {
            switch(self)
                {
                case .none:
                    return(.none)
                case .register:
                    return(.register)
                case .slot:
                    return(.slot)
                case .float:
                    return(.float)
                case .integer:
                    return(.integer)
                case .location:
                    return(.location)
                case .stack:
                    return(.stack)
                case .array:
                    return(.array)
                }
            }
        }
        
    fileprivate enum OperandField:Int
        {
        case none
        case register
        case slot
        case float
        case integer
        case location
        case stack
        case array
        }
        
    public var opcode:Opcode = .nop
    public var operand1:Operand? = nil
    public var operand2:Operand? = nil
    public var result:Operand? = nil
    }
