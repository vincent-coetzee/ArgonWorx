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
        
    public override var sizeInBytes: Int
        {
        get
            {
            return(self.actualSize)
            }
        set
            {
            }
        }
        
    public override var startIndex: Int
        {
        0
        }
        
    public override var endIndex: Int
        {
        self.count - 1
        }
        
    public override var count: Int
        {
        get
            {
            return(self._count)
            }
        set
            {
            }
        }
        
    private var offset = 0
    private var bytePointer:UnsafeMutableRawPointer
    private var actualSize: Int = 0
    private var _count: Int = 0
    
    override init(address:Word)
        {
        self.bytePointer = UnsafeMutableRawPointer(bitPattern: UInt(address + Word(Self.kArraySizeInBytes)))!
        super.init(address: address)
        }
        
    public func append(_ opcode:Instruction.Opcode,operand1:Instruction.Operand = .none,operand2:Instruction.Operand = .none,result:Instruction.Operand = .none)
        {
        self.append(opcode)
        self.append(operand1)
        self.append(operand2)
        self.append(result)
        self._count += 1
        }
        
    public var instruction:Instruction
        {
        let opcode = Instruction.Opcode(rawValue: self.bytePointer.load(fromByteOffset: self.offset, as: Int.self))!
        self.offset += self.align(MemoryLayout<Instruction.Opcode>.size,to: 8)
        let op1 = self.bytePointer.load(fromByteOffset: self.offset, as: Instruction.Operand.self)
        self.offset += self.align(MemoryLayout<Instruction.Operand>.size,to: 8)
        let op2 = self.bytePointer.load(fromByteOffset: self.offset, as: Instruction.Operand.self)
        self.offset += self.align(MemoryLayout<Instruction.Operand>.size,to: 8)
        let result = self.bytePointer.load(fromByteOffset: self.offset, as: Instruction.Operand.self)
        self.offset += self.align(MemoryLayout<Instruction.Operand>.size,to: 8)
        self.actualSize = Swift.max(self.actualSize,self.offset)
        return(Instruction(opcode, operand1: op1, operand2: op2, result: result))
        }

    public func append(_ opcode:Instruction.Opcode)
        {
        self.bytePointer.storeBytes(of: opcode.rawValue, toByteOffset: self.offset, as: Int.self)
        self.offset += self.align(MemoryLayout<Instruction.Opcode>.size,to: 8)
        self.actualSize = Swift.max(self.actualSize,self.offset)
        }
        
    public func append(_ operand:Instruction.Operand)
        {
        self.bytePointer.storeBytes(of: operand, toByteOffset: self.offset, as: Instruction.Operand.self)
        self.offset += self.align(MemoryLayout<Instruction.Operand>.size,to: 8)
        self.actualSize = Swift.max(self.actualSize,self.offset)
        }
        
    public func append(_ instructions:Array<Instruction>)
        {
        self.rewind()
        for instruction in instructions
            {
            self.append(instruction.opcode)
            self.append(instruction.operand1)
            self.append(instruction.operand2)
            self.append(instruction.result)
            self._count += 1
            }
        }
        
    public func rewind()
        {
        self.offset = 0
        }
        
    public func align(_ size:Int,to align:Int) -> Int
        {
        return(((size / (align - 1)) + 1) * align)
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        return(self.instruction)
        }
    }
