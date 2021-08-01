//
//  InstructionBuffer.swift
//  InstructionBuffer
//
//  Created by Vincent Coetzee on 1/8/21.
//

import Foundation
import SwiftUI

public class InstructionBuffer
    {
    public static let sample = InstructionBuffer()
        .append(Instruction(.make,address: ArgonModule.argonModule.array.memoryAddress,integer:1024,register: .r0))
        .append(Instruction.loadValue(ofSlotNamed: "instanceSizeInBytes",instanceType: ArgonModule.argonModule.class,instance: ArgonModule.argonModule.array.memoryAddress, into: .r1))
        .append(Instruction(.store,operand1:.register(.r1),result: .register(.fp)))
        .append(Instruction(.load,operand1:.integer(10),result:.register(.r4)))
        .append(.load,operand1: .integer(20), result:.register(.r5))
        .append(.iadd,operand1: .register(.r4),operand2:.register(.r5),result: .register(.r6))
    
    private var instructions:Array<Instruction> = []
    private var currentIndex:Int = -1
    
    public static func +=(lhs:InstructionBuffer,rhs:Instruction)
        {
        lhs.append(rhs)
        }
        
    @discardableResult
    public func append(_ instruction:Instruction) -> InstructionBuffer
        {
        self.instructions.append(instruction)
        return(self)
        }
        
    @discardableResult
    public func append(_ instructions:[Instruction]) -> InstructionBuffer
        {
        self.instructions.append(contentsOf: instructions)
        return(self)
        }
        
    @discardableResult
    public func append(_ opcode:Instruction.Opcode,operand1:Instruction.Operand? = nil,operand2:Instruction.Operand? = nil,result:Instruction.Operand?  = nil) -> InstructionBuffer
        {
        self.instructions.append(Instruction(opcode,operand1:operand1,operand2:operand2,result:result))
        return(self)
        }
        
    @discardableResult
    public func append(_ opcode:Instruction.Opcode,register1:Instruction.Register,register2:Instruction.Register,result:Instruction.Register) -> InstructionBuffer
        {
        self.instructions.append(Instruction(opcode,operand1:.register(register1),operand2:.register(register2),result:.register(result)))
        return(self)
        }
        
    public var allInstructions: Array<Instruction>
        {
        return(self.instructions)
        }
        
    public func packAllocatedPointer(in segment:Segment) -> Word
        {
        let bitEncoder = BitEncoder()
        for instruction in self.instructions
            {
            instruction.encode(in: bitEncoder)
            }
        let count = bitEncoder.words.count
        let array = InnerArrayPointer.allocate(arraySize: count, in: ManagedSegment.shared)
        var index = 1
        array[0] = Word(count)
        for word in bitEncoder.words
            {
            array[index] = word
            index += 1
            }
        return(0)
        }
        
    public func dump()
        {
        for instruction in self.instructions
            {
            instruction.dump()
            }
        }
        
    public func execute(in context:ExecutionContext) throws
        {
        for instruction in self.instructions
            {
            try instruction.execute(in: context)
            }
        }
        
    public func singleStep(in context:ExecutionContext) throws
        {
        if self.currentIndex == -1
            {
            self.currentIndex = 0
            }
        if self.currentIndex < self.instructions.count
            {
            var timer = Timer()
            try self.instructions[self.currentIndex].execute(in: context)
            print("Milliseconds to execute: \(timer.stop())")
            self.currentIndex += 1
            }
        }
    }
