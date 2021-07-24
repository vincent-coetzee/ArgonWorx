//
//  Cobalt.swift
//  CobaltX
//
//  Created by Vincent Coetzee on 2020/02/25.
//  Copyright © 2020 Vincent Coetzee. All rights reserved.
//

import Foundation

public struct Argon
    {
    private static var nextIndexNumber = 0
    private static var uuidIndex:UInt8 = 64
    
    public static func nextName(_ prefix:String) -> String
        {
        return("\(prefix)_\(Argon.nextSymbolIndex())")
        }
        
    public static func nextSymbolIndex() -> Int
        {
        let index = self.nextIndexNumber
        self.nextIndexNumber += 1
        return(index)
        }
        
    public static func nextUUIDIndex() -> UInt8
        {
        let index = self.uuidIndex
        self.uuidIndex += 1
        return(index)
        }
    
    public typealias Integer = Int64
    public typealias UInteger = UInt64
    public typealias Integer32 = Int32
    public typealias UInteger32 = UInt32
    public typealias Integer16 = Int16
    public typealias UInteger16 = UInt16
    public typealias Integer8 = Int8
    public typealias UInteger8 = UInt8
    public typealias Integer64 = Int64
    public typealias UInteger64 = UInt64
    public typealias Float = Float64
    public typealias Float64 = Swift.Double
    public typealias Float32 = Swift.Float
    public typealias Float16 = Swift.Float
    public typealias Character = UInt16
    public typealias Address = UInt64
    public typealias Symbol = Swift.String
    public typealias String = Swift.String
    public typealias Byte = UInt8
    public typealias Date = ArgonDate
    public typealias DateTime = ArgonDateTime
    public typealias Time = ArgonTime
//    public typealias Range = ArgonRange
//    public typealias FullRange = ArgonFullRange
//    public typealias HalfRange = ArgonHalfRange
    public typealias Word = UInt64
    
    public enum Tag:UInt64
        {
        case integer =      0b0000  // PACK, COPY AND DON'T FOLLOW
        case float =        0b0001  // PACK, COPY AND DON'T FOLLOW
        case byte =         0b0010  // PACK, COPY AND DON'T FOLLOW
        case character =    0b0011  // PACK, COPY AND DON'T FOLLOW
        case boolean =      0b0100  // PACK, COPY AND DON'T FOLLOW
        case bits =         0b0101  // PACK, COPY AND DON'T FOLLOW
        case header =       0b0110  // HANDLE
        case pointer =      0b0111  // FOLLOW
        }
        
    public enum Boolean:Argon.Integer8
        {
        case trueValue = 1
        case falseValue = 0
        }
        
//    public class Tuple:Equatable
//        {
//        public static func ==(lhs:Tuple,rhs:Tuple) -> Bool
//            {
//            fatalError("This function \(#function) should not have been called")
//            }
//
//        internal var elements = Array<Element>()
//
//        internal enum Element
//            {
//            case string(Argon.String?,Argon.String)
//            case integer(Argon.String?,Argon.Integer)
//            case float(Argon.String?,Argon.Float)
//            case boolean(Argon.String?,Argon.Boolean)
//            case character(Argon.String?,Argon.Character)
//            }
//        }
    }

//extension Argon.String:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int8)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.string)
//        }
//        
//    public init?(_ token:Token)
//        {
//        if token.isStringLiteral
//            {
//            self = token.stringLiteral
//            }
//        return(nil)
//        }
//    }
//    
//extension Argon.Integer:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int64)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.integer)
//        }
//        
//        
//    public init?(_ token:Token)
//        {
//        if token.isIntegerLiteral
//            {
//            self = token.integerLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Date:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int64)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.date)
//        }
//        
//    public static let distantPast = Argon.Date(day: 1, month: 1, year: -Int(UInt32.max - 1))
//    public static let distantFuture = Argon.Date(day: 1, month: 1, year: Int(UInt32.max - 1))
//    
//    public init?(_ token:Token)
//        {
//        if token.isDateLiteral
//            {
//            self = token.dateLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Time:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int64)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.time)
//        }
//        
//    public static let distantPast = Argon.Time(hour: -(Int(Swift.UInt32.max - 1)), minute: 0, second: 0)
//    public static let distantFuture = Argon.Time(hour: (Int(Swift.UInt32.max - 1)), minute: 0, second: 0)
//    
//    public init?(_ token:Token)
//        {
//        if token.isTimeLiteral
//            {
//            self = token.timeLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Boolean:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int8)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.boolean)
//        }
//        
//    public static func <(lhs:Argon.Boolean,rhs:Argon.Boolean) -> Bool
//        {
//        return(lhs == .falseValue && rhs == .trueValue)
//        }
//        
//    public init?(_ token:Token)
//        {
//        if token.isBooleanLiteral
//            {
//            self = token.booleanLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//
//extension Argon.UInteger:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int64)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.uInteger)
//        }
//        
//    public init?(_ token:Token)
//        {
//        if token.isIntegerLiteral
//            {
//            self = UInt64(abs(token.integerLiteral))
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Float:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.FloatType.double)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.float)
//        }
//        
//    public static let min = -Double.greatestFiniteMagnitude
//    public static let max = Double.greatestFiniteMagnitude
//    
//    public init?(_ token:Token)
//        {
//        if token.isFloatingPointLiteral
//            {
//            self = token.floatingPointLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Byte:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int8)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.byte)
//        }
//        
//    public init?(_ token:Token)
//        {
//        if token.isByteLiteral
//            {
//            self = token.byteLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }
//    
//extension Argon.Character:TypeKind
//    {
//    public static var llvmType:LLVM.IRType
//        {
//        return(LLVM.IntType.int16)
//        }
//        
//    public static var typeCode:PrimitiveClass.PrimitiveCode
//        {
//        return(.character)
//        }
//        
//    public init?(_ token:Token)
//        {
//        if token.isCharacterLiteral
//            {
//            self = token.characterLiteral
//            }
//        return(nil)
//        }
//        
//    public var displayString:String
//        {
//        return("\(self)")
//        }
//    }


    

    
