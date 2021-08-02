//
//  StackSegment.swift
//  StackSegment
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class StackSegment: Segment
    {
    public static let shared = StackSegment(sizeInBytes: 1024 * 1024 * 10)
    
    public let base: UnsafeMutableRawPointer
    public let baseAddress: Word
    public let stackTop: Word
    public var stackPointer: Word
    
    public override init(sizeInBytes:Int)
        {
        self.base = malloc(sizeInBytes)
        self.baseAddress = Word(bitPattern: Int64(Int(bitPattern: self.base)))
        self.stackTop = self.baseAddress + Word(sizeInBytes)
        self.stackPointer = self.stackTop - Word(MemoryLayout<Word>.size)
        super.init(sizeInBytes: sizeInBytes)
        }
        
    public func push(_ word:Word)
        {
        WordPointer(address: self.stackPointer)!.pointee = word
        self.stackPointer -= Word(MemoryLayout<Word>.size)
        }
        
    public func pop() -> Word
        {
        self.stackPointer += Word(MemoryLayout<Word>.size)
        return(WordPointer(address: self.stackPointer)!.pointee)
        }
    }
