//
//  ClassPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerClassPointer:InnerPointer
    {
    struct Key
        {
        let name:String
        let offset:Int
        }
        
    private static let keyNames = ["_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","extraSizeInBytes","hasBytes","instanceSizeInBytes","isValue","magicNumber","slots","superclasses"]
    private static let keys =
        {
        () -> Dictionary<String,Key> in
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in InnerClassPointer.keyNames
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }()
        
    public var name:String
        {
        return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
        }
        
    public var instanceSizeInBytes: Int
        {
        return(Int(self.slotValue(atKey:"instanceSizeInBytes")))
        }
        
    override init(address:Word)
        {
        super.init(address: address)
        self.classPointer = nil
        }
        
    public var slots:InnerArrayPointer
        {
        return(InnerArrayPointer(address: self.slotValue(atKey:"slots")))
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
        
    private func setSlotValue(_ word:Word,atKey:String)
        {
        let offset = Self.keys[atKey]!.offset
        self.wordPointer![offset/8] = word
        }
        
    public func new() -> InnerInstancePointer?
        {
        return(InnerInstancePointer(address: ManagedSegment.shared.allocateInstance(ofClass: self)))
        }
    }
