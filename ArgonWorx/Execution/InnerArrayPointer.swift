//
//  RawArrayPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerArrayPointer:InnerPointer
    {
    private static var allocatedArrays = Set<Word>()
    
    public var count:Int
        {
        return(Int(self.slotValue(atKey:"count")))
        }
        
    public var size:Int
        {
        return(Int(self.slotValue(atKey:"size")))
        }

    private static let kArraySizeInBytes = 136
    
    private var basePointer: WordPointer
    
    override init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.kArraySizeInBytes))!
        super.init(address: address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kArraySizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count","elementType","firstBlock","size"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(self.basePointer[index])
            }
        set
            {
            self.basePointer[index] = newValue
            }
        }
        
    public static func allocate(arraySize:Int,in segment:ManagedSegment) -> InnerArrayPointer
        {
        let extra = arraySize * MemoryLayout<Word>.size
        let totalSize = Self.kArraySizeInBytes + extra
        let address = segment.allocateObject(sizeInBytes: totalSize)
        let pointer = InnerArrayPointer(address: address)
        Self.allocatedArrays.insert(address)
        pointer.setSlotValue(ArgonModule.argonModule.array.memoryAddress,atKey:"_classPointer")
        return(InnerArrayPointer(address: address))
        }
    }
