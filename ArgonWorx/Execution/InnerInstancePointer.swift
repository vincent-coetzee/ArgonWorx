//
//  InnerInstancePointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerInstancePointer:InnerPointer
    {
    struct Key
        {
        let name:String
        let offset:Int
        }
        
    private static let keyNames = ["_header","_magicNumber","_classPointer"]
    private static let keys =
        {
        () -> Dictionary<String,Key> in
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in InnerInstancePointer.keyNames
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }()
    private static var sizeInBytes = 24
    
    override init(address:Word)
        {
        super.init(address:address)
        self.classPointer = InnerClassPointer(address: self.slotValue(atKey: "_classPointer"))
        Self.sizeInBytes = self.classPointer!.instanceSizeInBytes
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
        
    public var magicNumber: Int
        {
        get
            {
            return(Int(self.slotValue(atKey:"_magicNumber")))
            }
        set
            {
            self.setSlotValue(Word(bitPattern: newValue),atKey:"_magicNumber")
            }
        }
    }
