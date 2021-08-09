//
//  Type.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import FFI

public class Type:Equatable
    {
    public static let nilType = Type(label:"nil")
    public static let integerType = Type(label:"integer")
    public static let stringType = Type(label:"string")
    public static let floatType = Type(label:"float")
    public static let symbolType = Type(label:"symbol")
    public static let arrayType = Type(label:"array")
    public static let booleanType = Type(label:"boolean")
    
    public static func ==(lhs:Type,rhs:Type) -> Bool
        {
        if lhs is ClassType && rhs is ClassType
            {
            return((lhs as! ClassType).clazz == (rhs as! ClassType).clazz)
            }
        return(false)
        }
        
    public var typeClass: Class
        {
        fatalError("Should have been overridden")
        }
        
    public var displayName: String
        {
        self.label
        }
        
    public var isArrayType: Bool
        {
        return(false)
        }
        
    public var isStringType: Bool
        {
        return(false)
        }
        
    public var ffiType: ffi_type
        {
        return(ffi_type_uint64)
        }
        
    public var isVoidType: Bool
        {
        return(false)
        }
        
    public func realize(_ compiler:Compiler)
        {
        }
        
    public func emitCode(into instance: MethodInstance,using: CodeGenerator,operation: Token.Symbol)
        {
        fatalError("Should have been overridden")
        }
    
    public let label:Label
    
    init(label:Label)
        {
        self.label = label
        }
        
//    public var holder: SymbolHolder
//        {
//        .type(self)
//        }

    public func decodeValue(atPointer:ObjectPointer,withOffset:Int) -> ValueHolder
        {
        fatalError("This should not be called on a Type")
        }
    }

public typealias Types = Array<Type>
