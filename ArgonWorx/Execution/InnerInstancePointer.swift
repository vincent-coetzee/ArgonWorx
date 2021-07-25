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
        
    private class func keyNames() -> Array<String>
        {
        ["_header","_magicNumber","_classPointer"]
        }
        
    private class func keys() -> Dictionary<String,Key>
        {
        var dict = Dictionary<String,Key>()
        var offset = 0
        for name in self.keyNames()
            {
            dict[name] = Key(name:name,offset:offset)
            offset += 8
            }
        return(dict)
        }
        
    private static var sizeInBytes = 24
    
    override init(address:Word)
        {
        super.init(address:address)
        self._classPointer = InnerClassPointer(address: self.slotValue(atKey: "_classPointer"))
        Self.sizeInBytes = self.classPointer.instanceSizeInBytes
        }
        
    public override func slotValue(atKey:String) -> Word
        {
        let offset = Self.keys()[atKey]!.offset
        return(self.wordPointer![offset/8])
        }
        
    public override func setSlotValue(_ value:Word,atKey:String)
        {
        let offset = Self.keys()[atKey]!.offset
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
