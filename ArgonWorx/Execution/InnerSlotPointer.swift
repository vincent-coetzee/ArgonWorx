//
//  SlotPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation


    
public class InnerSlotPointer:InnerPointer
    {
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
        
    private static let kSlotSizeInBytes = 80
    
    override init(address:Word)
        {
        super.init(address:address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kSlotSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","offset","slotClass"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
