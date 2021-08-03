//
//  HostedBitField.swift
//  HostedBitField
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

public protocol WordConvertible
    {
    static var bitWidth: Int { get }
    var word: Word { get }
    init(word: Word)
    }
    
extension WordConvertible where Self:RawRepresentable,Self.RawValue == Int
    {
    public var word: Word
        {
        Word(self.rawValue)
        }
        
    public init(word: Word)
        {
        self = Self.init(rawValue: Int(word))!
        }
    }
    
extension Word:WordConvertible
    {
    public var word: Word
        {
        return(self)
        }
        
    public init(word: Word)
        {
        self = word
        }
    }
    
public struct BitField<T>:Codable where T:WordConvertible
    {
    private let start:Int
    private let stop:Int
    private let width:Int
    private let mask: Word
    private let placeMask: Word
    
    init(start:Int,stop:Int)
        {
        self.start = start
        self.stop = stop
        self.width = stop - start
        self.mask = (1 << Word(self.width + 1)) - 1
        self.placeMask = mask << Word(start)
        }
        
    init(start:Int)
        {
        self.start = start
        self.width = T.bitWidth
        self.stop = start + width
        self.mask = (1 << Word(self.width)) - 1
        self.placeMask = mask << Word(start)
        }
        
    func encode(_ value:T,into base:inout Word)
        {
        let amount = value.word & self.mask
        let wordValue = amount << self.start
        base = (base & ~self.placeMask) | wordValue
        }
        
    func decode(from base:Word,as: T.Type) -> T
        {
        let amount = (base & self.placeMask) >> start
        return(T(word: amount))
        }
    }
