//
//  InnerDictionaryPointer.swift
//  InnerDictionaryPointer
//
//  Created by Vincent Coetzee on 2/8/21.
//

import Foundation

public class InnerDictionaryPointer: InnerPointer
    {
    internal override func initKeys()
        {
        self.sizeInBytes = Self.kDictionarySizeInBytes
        let names = ["_header","_magicNumber","_classPointer","_CollectionHeader","_CollectionMagicNumber","_CollectionClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","_IterableHeader","_IterableMagicNumber","_IterableClassPointer","count"]
        var offset = 0
        for name in names
            {
            self.keys[name] = Key(name:name,offset:offset)
            offset += 8
            }
        }
    }
