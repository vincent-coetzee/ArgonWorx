//
//  InnerBlockPointer.swift
//  InnerBlockPointer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class InnerBlockPointer: InnerPointer
    {
    public static func allocate(arraySize:Int,in segment:ManagedSegment) -> InnerBlockPointer
        {
        let size = arraySize * 3 / 2
        let totalSize = Self.kBlockSizeInBytes + (size * 8)
        let address = segment.allocateObject(sizeInBytes: totalSize)
        let pointer = InnerBlockPointer(address: address)
        pointer.setSlotValue(size,atKey:"size")
        pointer.setSlotValue(0,atKey: "count")
        return(pointer)
        }
    
    public var count: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"count")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"count")
            }
        }
        
    public var size: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"size")))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"size")
            }
        }
        
    internal var basePointer:WordPointer
    
    override required init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.kArraySizeInBytes))!
        super.init(address: address)
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kBlockSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","count","nextBlock","size"]
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
    }
