//
//  ClassPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerClassPointer:InnerPointer
    {
    public var name:String
        {
        return(InnerStringPointer(address: self.slotValue(atKey:"name")).string)
        }
        
    public var slotCount: Int
        {
        return(self.slots.count)
        }
        
    public var instanceSizeInBytes: Int
        {
        return(Int(self.slotValue(atKey:"instanceSizeInBytes")))
        }
        
    private static let kClassSizeInBytes = 152
    
    override init(address:Word)
        {
        super.init(address: address)
        self._classPointer = nil
        }
        
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kClassSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","extraSizeInBytes","hasBytes","instanceSizeInBytes","isValue","magicNumber","slots","superclasses"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }

    public var slots:InnerArrayPointer
        {
        return(InnerArrayPointer(address: self.slotValue(atKey:"slots")))
        }
        
    public func slot(atName:String) -> InnerSlotPointer
        {
        fatalError("Not implemented yet")
        return(InnerSlotPointer(address:0))
        }
        
    public func slot(atIndex:Int) -> InnerSlotPointer
        {
        let slots = InnerArrayPointer(address: self.slotValue(atKey:"slots"))
        return(InnerSlotPointer(address: slots[atIndex]))
        }

        
    public func makeInstance() -> InnerInstancePointer?
        {
        return(InnerInstancePointer(address: ManagedSegment.shared.allocateInstance(ofClass: self)))
        }
    }
