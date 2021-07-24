//
//  ArrayPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public struct ArrayPointer
    {
    private let address:Word
    private let wordPointer:WordPointer?
    private let theClass:Class
    private let countOffset:Int
    private let sizeOffset:Int
    private let baseSize:Int
    
    public var count:Int
        {
        get
            {
            return(Int(self.wordPointer?[self.countOffset] ?? 0))
            }
        set
            {
            self.wordPointer?[self.countOffset] = Word(newValue)
            }
        }
        
    public var size:Int
        {
        get
            {
            return(Int(self.wordPointer?[self.sizeOffset] ?? 0))
            }
        set
            {
            self.wordPointer?[self.sizeOffset] = Word(newValue)
            }
        }
        
    init(address:Word)
        {
        self.address = address
        self.wordPointer = WordPointer(address: address)
        self.theClass = ArgonModule.argonModule.array
        self.countOffset = theClass.layoutSlot(atLabel: "count")!.offset / MemoryLayout<Word>.size
        self.sizeOffset = theClass.layoutSlot(atLabel: "size")!.offset / MemoryLayout<Word>.size
        self.baseSize = theClass.sizeInBytes
        }
        
    public mutating func append(_ word:Word)
        {
        let offset = self.baseSize + (self.count * MemoryLayout<Word>.size)
        self.wordPointer?[offset / MemoryLayout<Word>.size] = word
        self.count = self.count + 1
        }
        
    public mutating func append(_ words:Words)
        {
        for element in words
            {
            self.append(element)
            }
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            let base = self.baseSize + index * MemoryLayout<Word>.size
            return(self.wordPointer![base])
            }
        set
            {
            let base = self.baseSize + index * MemoryLayout<Word>.size
            self.wordPointer?[base] = newValue
            }
        }
    }
