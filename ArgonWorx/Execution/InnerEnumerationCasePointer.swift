//
//  InnerEnumerationCasePointer.swift
//  InnerEnumerationCasePointer
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class InnerEnumerationCasePointer: InnerPointer
    {
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kEnumerationCaseSizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","associatedTypes","enumeration","symbol","value"]

        var offset = 0
        for name in names
            {
            self._keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
