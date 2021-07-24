//
//  TypeCode.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public enum TypeCode:Int
    {
    case none
    case integer
    case uInteger
    case float
    case character
    case boolean
    case byte
    case string
    case symbol
    case enumeration
    case method
    case methodInstance
    case function
    case `class`
    case slot
    case tuple
    case type
    case array
    case void
    case stream
    case metaclass
    case module
    case pointer
    case other
    case mutableString
    }
