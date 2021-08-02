//
//  InnerInstructionPointer.swift
//  InnerInstructionPointer
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation
import StickyEncoding

public class InnerInstructionArrayPointer:InnerArrayPointer
    {
    typealias Element = Instruction
    
    public override class func allocate(arraySize:Int,in segment:ManagedSegment)  -> InnerInstructionArrayPointer
        {
        let pointer = super.allocate(arraySize: arraySize, in: segment)
        return(InnerInstructionArrayPointer(address: pointer.address))
        }
        
    public func encode<T>(value: T, inWidth width: Int) where T : RawConvertible
        {
        print("halt")
        }
        
    public override var startIndex: Int
        {
        0
        }
        
    public override var endIndex: Int
        {
        self.count - 1
        }
        
    private var offset = 0
    private var bytePointer:UnsafeMutableRawPointer
    private var currentIndex = 0
    
    override init(address:Word)
        {
        self.bytePointer = UnsafeMutableRawPointer(bitPattern: UInt(address + Word(Self.kArraySizeInBytes)))!
        super.init(address: address)
        }
        
    public func append(_ opcode:Instruction.Opcode,operand1:Instruction.Operand = .none,operand2:Instruction.Operand = .none,result:Instruction.Operand = .none)
        {
        let instruction = Instruction(opcode,operand1:operand1,operand2:operand2,result:result)
        self.append(instruction)
        }
        
    public func append(_ instruction:Instruction)
        {
        let encoder = BinaryEncoder()
        let output = try! encoder.encode(instruction)
        let array = InnerByteArrayPointer.with(output)
        self[self.count] = array.address
        self.count += 1
        }
        
    public func instruction(at index:Int) -> Instruction?
        {
        if index < 0 || index >= count
            {
            return(nil)
            }
        let bytes = InnerByteArrayPointer(address: self[index]).bytes
        let decoder = BinaryDecoder()
        let instruction = try? decoder.decode(Instruction.self, from: bytes)
        return(instruction)
        }

    public func append(_ instructions:Array<Instruction>) -> Self
        {
        for instruction in instructions
            {
            self.append(instruction)
            }
        return(self)
        }
        
    public var currentInstructionId: UUID?
        {
        return(self.instruction(at: self.currentIndex)?.id)
        }
        
    public func singleStep(in context:ExecutionContext) throws
        {
        if self.currentIndex >= self.count
            {
            return
            }
        try self.instruction(at: self.currentIndex)?.execute(in: context)
        self.currentIndex += 1
        }
        
    public func rewind() -> Self
        {
        self.currentIndex = 0
        return(self)
        }
    }
