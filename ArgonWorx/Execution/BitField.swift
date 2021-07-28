//
//  HostedBitField.swift
//  HostedBitField
//
//  Created by Vincent Coetzee on 28/7/21.
//

import Foundation

public protocol BitFielding
    {
    var width:Int { get }
    var shift:Int { get }
    }

extension BitFielding
    {
    private var mask: Word
        {
        (Word(width) * 4) - 1
        }
        
    private var fullMask: Word
        {
        self.mask << Word(self.shift)
        }
        
    public func _setValue(_ value:Word,in word:inout Word)
        {
        let newValue = value & mask
        word = (word & ~self.fullMask) | (newValue << Word(self.shift))
        }
        
    public func _value(in word:Word) -> Word
        {
        (word & self.fullMask) >> Word(self.shift)
        }
    }

public protocol BitKeeper:AnyObject
    {
    var bits: Word { get set }
    }
    
public class BitField<T>:BitFielding
    {
    public var width: Int
        {
        self._width
        }
        
    public var shift: Int
        {
        self._shift
        }
    
    var value:T
        {
        get
            {
            return(self.getter!())
            }
        set
            {
            self.setter!(newValue)
            }
        }

    private typealias GetterFunction = () -> T
    private typealias SetterFunction = (T) -> Void
    
    private var getter: GetterFunction?
    private var setter: SetterFunction?
    private let _width: Int
    private let _shift: Int
    private var bitKeeper: BitKeeper
    
    public init(shift: Int,width: Int,bitKeeper: BitKeeper) where T:RawRepresentable,T.RawValue == Int
        {
        self._width = width
        self._shift = shift
        self.bitKeeper = bitKeeper
        self.getter =
            {
            () -> T in
            return(T(rawValue: Int(self._value(in: bitKeeper.bits)))!)
            }
        self.setter =
            {
            (argument) -> Void in
            var bits = bitKeeper.bits
            self._setValue(Word(argument.rawValue),in: &bits)
            bitKeeper.bits = bits
            }
        }
    
    public init(shift: Int,width: Int,bitKeeper: BitKeeper) where T == Int
        {
        self._width = width
        self._shift = shift
        self.bitKeeper = bitKeeper
        self.getter =
            {
            () -> T in
            return(Int(self._value(in: bitKeeper.bits)))
            }
        self.setter =
            {
            (argument) -> Void in
            var bits = bitKeeper.bits
            self._setValue(Word(argument),in: &bits)
            bitKeeper.bits = bits
            }
        }
        
    public init(shift: Int,width: Int,bitKeeper: BitKeeper,initialValue:T) where T == Int
        {
        self._width = width
        self._shift = shift
        self.bitKeeper = bitKeeper
        self.getter =
            {
            () -> T in
            return(Int(self._value(in: bitKeeper.bits)))
            }
        self.setter =
            {
            (argument) -> Void in
            var bits = bitKeeper.bits
            self._setValue(Word(argument),in: &bits)
            bitKeeper.bits = bits
            }
        self.value = initialValue
        }
    }

