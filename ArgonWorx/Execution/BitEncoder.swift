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
    
    public func encode<T:RawRepresentable>(value:T,inWidth width:Int) where T.RawValue == Int
        {
        self.encode(value:value.rawValue,inWidth:width)
        }
        
    public func encode(value:Int,inWidth width:Int)
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
        
    private var currentOffset = Word.bitWidth
    public private(set) var words: Array<Word> = []
    private var currentWord: Word = 0
    }
