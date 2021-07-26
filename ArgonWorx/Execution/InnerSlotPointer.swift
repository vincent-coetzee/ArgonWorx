//
//  SlotPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation


    
public class InnerSlotPointer:InnerPointer
    {
    private static var allocatedSlots = Set<Word>()
    
    public static func allocate(in segment:ManagedSegment) -> InnerSlotPointer
        {
        let address = segment.allocateObject(sizeInBytes: Self.kSlotSizeInBytes)
        let pointer = InnerSlotPointer(address: address)
        Self.allocatedSlots.insert(address)
        pointer.setSlotValue(ArgonModule.argonModule.slot.memoryAddress,atKey:"_classPointer")
        pointer.assignSystemSlots(from: ArgonModule.argonModule.slot)
        return(pointer)
        }
        
    public var offset:Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.slotValue(atKey:"offset"))))
            }
        set
            {
            self.setSlotValue(newValue,atKey:"offset")
            }
        }
        
    public var slotClass:InnerClassPointer
        {
        get
            {
            return(InnerClassPointer(address:self.slotValue(atKey:"slotClass")))
            }
        set
            {
            self.setSlotValue(newValue.address,atKey:"slotClass")
            }
        }
        
    public var name:String
        {
        return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
        }
        
    public var typeCode: Int
        {
        return(Int(bitPattern: UInt(self.slotValue(atKey:"typeCode"))))
        }
    
    override init(address:Word)
        {
        super.init(address:address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kSlotSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","offset","slotClass","typeCode"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func format(value:Word) -> String
        {
        switch(self.typeCode)
            {
            case 1:
                return("\(value)")
            case 7:
                return(InnerStringPointer(address: value).string)
            case 13:
                return(value.addressString)
            case 14:
                return(value.addressString)
            case 17:
                let arrayPointer = InnerArrayPointer(address: value)
                let count = arrayPointer.count
                let size = arrayPointer.size
                return("Array @ 0x\(value.addressString) \(count)/\(size)")
            default:
                return("\(value)")
            }
        }
    }
