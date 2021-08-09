//
//  RawArrayPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerVectorPointer:InnerPointer,Collection
    {
    public typealias Element = Word
    public typealias Index = Int
    
    public class func allocate(arraySize:Int,in segment:ManagedSegment) -> InnerVectorPointer
        {
        let blockSize = arraySize * 5 / 2
        let block = InnerBlockPointer.allocate(arraySize: blockSize, in: segment)
        let address = segment.allocateObject(sizeInBytes: Self.kVectorSizeInBytes)
        let pointer = InnerVectorPointer(address: address)
        Self.allocatedArrays.insert(address)
        pointer.setSlotValue(ArgonModule.argonModule.vector.memoryAddress,atKey:"_classPointer")
        pointer.count = 0
        pointer.size = arraySize
        pointer.startBlockPointer = block
        pointer.assignSystemSlots(from: ArgonModule.argonModule.vector)
        return(pointer)
        }
        
    private static var allocatedArrays = Set<Word>()
    
    public var startIndex: Int
        {
        0
        }
        
    public var endIndex: Int
        {
        self.count - 1
        }
        
    public var count:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"count")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"count")
            }
        }
        
    public var size:Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"size")))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"size")
            }
        }
    
        
    public var startBlockPointer: InnerBlockPointer
        {
        get
            {
            return(self._startBlockPointer)
            }
        set
            {
            self._startBlockPointer = newValue
            self.setSlotValue(newValue.address,atKey:"startBlock")
            }
        }
        
    internal var _startBlockPointer: InnerBlockPointer = InnerBlockPointer(address: 1)
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kVectorSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count","elementType","size","blockCount","startBlock"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func index(after:Int) -> Int
        {
        return(after + 1)
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(self._startBlockPointer[index])
            }
        set
            {
            self._startBlockPointer[index] = newValue
            }
        }
        
    private func grow()
        {
        let newSize = self.size * 5 / 2
        let newBlock = InnerBlockPointer.allocate(arraySize: newSize, in: ManagedSegment.shared)
        newBlock.copy(from: self._startBlockPointer,count: self.size)
        self.startBlockPointer = newBlock
        self.size = newSize
        }
        
    public func append(_ word:Word)
        {
        let theCount = self.count
        if theCount + 1 >= self.size
            {
            self.grow()
            }
        self._startBlockPointer[theCount] = word
        self.count = theCount + 1
        }
        
    public func append(_ words:Array<Word>)
        {
        for word in words
            {
            self.append(word)
            }
        }
        
    public func contains(_ word:Word) -> Bool
        {
        let pointer = self._startBlockPointer.basePointer
        let theCount = self.count
        for index in 0..<theCount
            {
            if pointer[index] == word
                {
                return(true)
                }
            }
        return(false)
        }
    }
