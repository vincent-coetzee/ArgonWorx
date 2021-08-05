//
//  InnerEnumerationPointer.swift
//  InnerEnumerationPointer
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class InnerEnumerationPointer: InnerPointer
    {
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kEnumerationSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","cases","valueType"]
        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
