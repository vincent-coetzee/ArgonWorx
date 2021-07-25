//
//  InnerPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerPointer
    {
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
        
    public func word(atOffset:Int) -> Word
        {
        return(self.wordPointer?[atOffset/8] ?? 0)
        }
        
    public func setWord(_ word:Word,atOffset:Int)
        {
        self.wordPointer?[atOffset/8] = word
        }
        
    public func slotValue(atName:String) -> Word
        {
        let slot = self.classPointer.slot(atName:atName)
        return(self.wordPointer?[slot.offset] ?? 0)
        }
        
    public func setSlotValue(_ value:Word,atName:String)
        {
        let slot = self.classPointer.slot(atName:atName)
        self.wordPointer?[slot.offset] = value
        }
        
    public func slotValue(atKey:String) -> Word
        {
        let offset = self.keys[atKey]!.offset
        return(self.wordPointer![offset/8])
        }
        
    public func setSlotValue(_ value:Word,atKey:String)
        {
        let offset = self.keys[atKey]!.offset
        self.wordPointer![offset/8] = value
        }
        
    public func setSlotValue(_ value:Int,atKey:String)
        {
        let offset = self.keys[atKey]!.offset
        self.wordPointer![offset/8] = Word(bitPattern: Int64(value))
        }
    }
