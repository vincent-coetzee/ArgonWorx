//
//  InnerPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerPointer
    {
    public static let kClassSizeInBytes = 152
    public static let kSlotSizeInBytes = 88
    public static let kArraySizeInBytes = 136
    public static let kStringSizeInBytes = 64
    
    public var classPointer:InnerClassPointer
        {
        get
            {
            if self._classPointer.isNil
                {
                self._classPointer = InnerClassPointer(address: self.slotValue(atKey:"_classPointer"))
                }
            return(self._classPointer!)
            }
        set
            {
            self._classPointer = newValue
            self.setSlotValue(newValue.address,atKey:"_classPointer")
            self.setSlotValue(newValue.magicNumber,atKey:"_magicNumber")
            }
        }
        
    internal struct Key
        {
        let name:String
        let offset:Int
        }

    internal var sizeInBytes:Int = 0
    internal var keys:Dictionary<String,Key> = [:]
    var _classPointer:InnerClassPointer?
    let address:Word
    var wordPointer:WordPointer?

    init(address:Word)
        {
        self._classPointer = nil
        self.address = address
        self.wordPointer = WordPointer(address:address)
        self.initKeys()
        }
        
    internal func initKeys()
        {
        self.sizeInBytes = 24
        let names = ["_header","_magicNumber","_classPointer"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
        
    public func hasSlot(atKey:String) -> Bool
        {
        return(self.keys[atKey] != nil)
        }
        
    public func word(atOffset:Int) -> Word
        {
        return((self.wordPointer?[atOffset/8] ?? 0).tagDropped)
        }
        
    public func setWord(_ word:Word,atOffset:Int)
        {
        self.wordPointer?[atOffset/8] = word
        }
        
    public func slotValue(atName:String) -> Word
        {
        let slot = self.classPointer.slot(atName:atName)
        return((self.wordPointer?[slot.offset] ?? 0).tagDropped)
        }
        
    public func setSlotValue(_ value:Word,atName:String)
        {
        let slot = self.classPointer.slot(atName:atName)
        self.wordPointer?[slot.offset] = value
        }
        
    public func slotValue(atKey:String) -> Word
        {
        if let offset = self.keys[atKey]?.offset
            {
            return((self.wordPointer?[offset/8].tagDropped) ?? Word.nilValue)
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:Word,atKey:String)
        {
        if let offset = self.keys[atKey]?.offset
            {
            self.wordPointer![offset/8] = value
            return
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:Bool,atKey:String)
        {
        if let offset = self.keys[atKey]?.offset
            {
            var word = Word(value ? 1 : 0)
            word.tag = .boolean
            self.wordPointer![offset/8] = word
            return
            }
        fatalError("Slot at key \(atKey) not found")
        }
        
    public func setSlotValue(_ value:String,in segment:ManagedSegment,atKey:String)
        {
        let stringPointer = InnerStringPointer.allocateString(value,in:segment)
        let offset = self.keys[atKey]!.offset
        var word = stringPointer.address
        word.tag = .pointer
        self.wordPointer![offset/8] = word
        }
        
    public func setSlotValue(_ value:Int,atKey:String)
        {
        let offset = self.keys[atKey]!.offset
        self.wordPointer![offset/8] = Word(bitPattern: Int64(value))
        }
        
    public func assignSystemSlots(from aClass:Class)
        {
        var aKey = "_\(aClass.label)Header"
        if self.hasSlot(atKey: aKey)
            {
            var header = Header(0)
            header.tag = .header
            header.hasBytes = aClass.hasBytes
            header.isForwarded = false
            header.flipCount = 1
            header.sizeInWords = aClass.sizeInBytes / 8
            self.setSlotValue(header, atKey: aKey)
            }
        aKey = "_\(aClass.label)MagicNumber"
        if self.hasSlot(atKey: aKey)
            {
            self.setSlotValue(aClass.magicNumber,atKey: aKey)
            }
        aKey = "_\(aClass.label)ClassPointer"
        if self.hasSlot(atKey: aKey)
            {
            self.setSlotValue(aClass.memoryAddress,atKey: aKey)
            }
        for superclass in aClass.superclasses
            {
            self.assignSystemSlots(from: superclass)
            }
        }
    }
