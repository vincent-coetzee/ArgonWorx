//
//  String+Extensions.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public typealias Label = String

extension String
    {
    public enum Alignment
        {
        case left
        case centre
        case right
        }
        
    public var djb2Hash: Int
        {
        var hash:UInt64 = 5381
        for char in self
            {
            hash = ((hash << 5) &+ hash) &+ UInt64(char.asciiValue!)
            }
        let mask = ~Word(bitPattern: 1<<63)
        return(Int(hash & mask))
        }
        
    public var polynomialRollingHash:Int
        {
        let p:Int64 = 31
        let m:Int64 = Int64(1e9) + 9
        var powerOfP:Int64 = 1
        var hashValue:Int64 = 0
        let aValue = Int64(Character("A").asciiValue!)
        
        for char in self
            {
            hashValue = (hashValue + (Int64(char.asciiValue!) - aValue + 1) * powerOfP) % m
            powerOfP = (powerOfP * p) % m
            }
        return(Int(hashValue))
        }
        
    public func aligned(_ alignment:Alignment,in width:Int) -> String
        {
        let length = max(width - self.count,0)
        let padding = String(repeating: " ", count: length)
        if alignment == .left
            {
            return(self + padding)
            }
        return(padding + self)
        }
    }
