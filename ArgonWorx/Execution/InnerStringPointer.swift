//
//  InnerStringPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerStringPointer:InnerPointer
    {
    private static let kBitsByte = UInt8(Argon.Tag.bits.rawValue) << 4
    
    struct Key
        {
        let name:String
        let offset:Int
        }
        
    private static let keyNames = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","count"]
    private static let keys =
        {
        () -> Dictionary<String,Key> in
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in InnerStringPointer.keyNames
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }()
    private static let sizeInBytes = 64
        
    public var string:String
        {
        get
            {
            if self.address.isZero
                {
                return("nil")
                }
            let offset = UInt(address) + UInt(Self.sizeInBytes)
            let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
            let count = self.count
            var string = ""
            var position = 0
            var done = 0
            while done < count
                {
                if position % 7 == 0
                    {
                    position += 1
                    }
                else
                    {
                    let byte = bytePointer[position]
                    let character = UnicodeScalar(byte)
                    string += character
                    position += 1
                    done += 1
                    }
                }
            return(string)
            }
        set
            {
            if self.address.isZero
                {
                return
                }
            let offset = UInt(address) + UInt(Self.sizeInBytes)
            let bytePointer = UnsafeMutablePointer<UInt8>(bitPattern: offset)!
            self.count = newValue.utf8.count
            let string = newValue.utf8
            var position = 0
            var index = string.startIndex
            var count = string.count
            while position < count
                {
                if position % 7 == 0
                    {
                    bytePointer[position] = Self.kBitsByte
                    position += 1
                    count += 1
                    }
                else
                    {
                    bytePointer[position] = string[index]
                    position += 1
                    index = string.index(after: index)
                    }
                }
            }
        }
        
    public var count:Int
        {
        get
            {
            return(Int(bitPattern: UInt(self.slotValue(atKey:"count"))))
            }
        set
            {
            self.setSlotValue(Word(newValue),atKey:"count")
            }
        }
        
    public var offset:Int
        {
        return(Int(bitPattern: UInt(self.slotValue(atKey:"offset"))))
        }
        
    public var name:String
        {
        return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
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
        
    private func setSlotValue(_ value:Word,atKey:String)
        {
        let offset = Self.keys[atKey]!.offset
        self.wordPointer![offset/8] = value
        }
    }
