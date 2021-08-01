//
//  BitEncoder.swift
//  BitEncoder
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

public class BitEncoder
    {
    private static let kWordSizeInBits = 64
    
    ///
    ///
    /// If you pass in a enum value to be encoded you must always add an extra bit
    /// to allow for the encoding of a nil value
    ///
    ///
    public func encode<T:RawRepresentable>(value:T,inWidth width: Int) where T.RawValue == Int
        {
         self.encode(value:value.rawValue,inWidth: width)
        }
        
    public func encode<T:RawConvertible>(value:T,inWidth width:Int)
        {
        self.encode(value:value.rawValue + 1,inWidth: width)
        }
        
    public func encode(value:Word,inWidth width:Int)
        {
        print("    VALUE: \(Word(value).bitString)")
        let spaceRemaining = self.currentOffset
        if width <= spaceRemaining
            {
            let mask = (Word(1) << Word(width)) - 1
            print("    MASK: \(mask.bitString)")
            self.currentOffset -= width
            self.currentWord |= (Word(value) & mask) << self.currentOffset
            print(" CURRENT: \(self.currentWord.bitString)")
            }
        else
            {
            print(" CURRENT: \(self.currentWord.bitString)")
            let extra = width - spaceRemaining
            let mask =  (Word(1) << extra) - 1
            print("    MASK: \(mask.bitString)")
            let extraBits = (Word(value) & mask) << (Self.kWordSizeInBits - extra)
            print("   EXTRA: \(extraBits.bitString)")
            self.currentWord |= (Word(value) >> Word(extra))
            print(" CURRENT: \(self.currentWord.bitString)")
            self.words.append(self.currentWord)
            self.currentWord = extraBits
            print(" CURRENT: \(self.currentWord.bitString)")
            self.currentOffset = Self.kWordSizeInBits - extra
            self.currentOffset = Word.bitWidth - extra
            }
        }
        
    public func encode<T>(value:T?,inWidth:Int) where T:BitCodable
        {
        self.encode(value: value.isNil ? 0 : 1,inWidth:inWidth)
        value?.encode(in: self)
        }
        
    public func encode(value:Int,inWidth width:Int)
        {
        self.encode(value: Word(bitPattern: value),inWidth: width)
        }
        
    private var currentOffset = Word.bitWidth
    public private(set) var words: Array<Word> = []
    private var currentWord: Word = 0
    }
