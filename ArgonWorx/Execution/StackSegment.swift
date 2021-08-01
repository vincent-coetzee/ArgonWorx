//
//  StackSegment.swift
//  StackSegment
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class StackSegment: Segment
    {
    public let base: UnsafeMutableRawPointer
    public let baseAddress: Word
    public let stackTop: Word
    public let stackPointer: Word
    
    public override init(sizeInBytes:Int)
        {
        self.base = malloc(sizeInBytes)
        self.baseAddress = Word(bitPattern: self.base)
        self.stackPointer = self.baseAddress
        self.stackTop = self.baseAddress + sizeInBytes
        super.init(sizeInBytes: sizeInBytes)
        }
        
    public func push(_ word:Word)
        {
        
        }
    }
