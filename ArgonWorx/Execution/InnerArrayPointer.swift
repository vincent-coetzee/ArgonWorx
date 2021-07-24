//
//  RawArrayPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerArrayPointer:InnerPointer
    {
    struct Key
        {
        let name:String
        let offset:Int
        }
        
    private static let keyNames = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count","elementType","firstBlock","size"]
    private static let keys =
        {
        () -> Dictionary<String,Key> in
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in InnerArrayPointer.keyNames
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }()
    private static let sizeInBytes = 136
        
    public var name:String
        {
        return("")
        }
        
    public var count:Int
        {
        return(Int(self.slotValue(atKey:"count")))
        }
        
    public var size:Int
        {
        return(Int(self.slotValue(atKey:"size")))
        }
        
    private var basePointer: WordPointer
    
    override init(address:Word)
        {
        self.basePointer = WordPointer(address: address + Word(Self.sizeInBytes))!
        super.init(address: address)
        self.classPointer = nil
        }

    public func slot(atName:String) -> InnerSlotPointer
        {
        return(InnerSlotPointer(address:0))
        }
        
    private func slotValue(atKey:String) -> Word
        {
        let offset = Self.keys[atKey]!.offset
        return(self.wordPointer![offset/8])
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
