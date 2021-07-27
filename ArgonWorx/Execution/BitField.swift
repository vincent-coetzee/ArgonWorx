//
//  BitField.swift
//  BitField
//
//  Created by Vincent Coetzee on 27/7/21.
//

import Foundation

public protocol BitField
    {
    var shift: Word { get }
    var width: Word { get }
    }
    
extension BitField
    {
    public var startBit: Word
        {
        self.shift
        }
        
    public var stopBit: Word
        {
        self.shift + self.width
        }
        
    public var mask: Word
        {
        (1 << self.width) - 1
        }
        
    public var fullMask: Word
        {
        self.mask << self.shift
        }
        
    public func setValue(_ value:Word,in word:inout Word)
        {
        word = (word & ~self.fullMask) | ((value & mask) << self.shift)
        }
        
    public func value(in word:Word) -> Word
        {
        (word & fullMask) >> self.shift
        }
        
    public func setTypeValue<T:RawRepresentable>(_ type:T,in word:inout Word) where T.RawValue == Int
        {
        self.setValue(Word(type.rawValue),in:&word)
        }
        
    public func typeValue<T:RawRepresentable>(in word:Word) -> T where T.RawValue == Int
        {
        return(T(rawValue: Int(self.value(in: word)))!)
        }
    }
