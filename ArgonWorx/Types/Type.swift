//
//  Type.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class Type
    {
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
