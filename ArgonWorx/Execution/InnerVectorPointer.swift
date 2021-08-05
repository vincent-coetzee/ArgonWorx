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
            return(InnerBlockPointer(address: self.slotValue(atKey:"startBlock")))
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"startBlock")
            }
        }
        
    internal var basePointer: WordPointer
    
    required init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.kArraySizeInBytes))!
        super.init(address: address)
        self._classPointer = nil
        }
        
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
            if index < self.size
                {
                return(self.basePointer[index])
                }
            fatalError("Invalid array index")
            }
        set
            {
            if index < self.size
                {
                self.basePointer[index] = newValue
                return
                }
            fatalError("Invalid array index")
            }
        }
        
    public func append(_ word:Word)
        {
        self[self.count] = word
        self.count += 1
        }
        
    public func append(_ words:Array<Word>)
        {
        for word in words
            {
            self[self.count] = word
            self.count += 1
            }
        }
    }
