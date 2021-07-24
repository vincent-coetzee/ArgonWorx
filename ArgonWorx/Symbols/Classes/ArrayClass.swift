//
//  ArrayClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class ArrayClass:ParameterizedSystemClass
    {
    public override var isArrayClass: Bool
        {
        return(true)
        }
        
    public func withElement(_ type:Type) -> ArrayClassInstance
        {
        let instance = ArrayClassInstance(label: Argon.nextName("_ARRAY"), sourceClass: self, types: [type])
        return(instance)
        }
        
   public override func of(_ type:Class) -> ArrayClassInstance
        {
        let instance = ArrayClassInstance(label: Argon.nextName("_ARRAY"), sourceClass: self, types: [type.type])
        instance.slotClassType = self.slotClassType
        return(instance)
        }
    }
