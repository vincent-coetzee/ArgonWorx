//
//  SlotPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation


    
public class InnerSlotPointer:InnerPointer
    {
    struct Key
        {
        let name:String
        let offset:Int
        }
        
    private static let keyNames = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","offset","slotClass"]
    private static let keys =
        {
        () -> Dictionary<String,Key> in
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in InnerSlotPointer.keyNames
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }()
        
    public var offset:Int
        {
        return(Int(bitPattern: UInt(self.slotValue(atKey:"offset"))))
        }
        
    public var name:String
        {
        return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
        }
        
    public var slotClassPointer:InnerClassPointer
        {
        return(InnerClassPointer(address: self.slotValue(atKey:"slotClass")))
        }
        
    override init(address:Word)
        {
        super.init(address:address)
        self.classPointer = InnerClassPointer(address: ArgonModule.argonModule.slot.memoryAddress)
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
    }
