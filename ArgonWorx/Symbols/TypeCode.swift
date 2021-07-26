//
//  TypeCode.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 22/7/21.
//

import Foundation

public enum TypeCode:Int
    {
    case none = 0
    case integer = 1
    case uInteger = 2
    case float = 3
    case character = 4
    case boolean = 5
    case byte = 6
    case string = 7
    case symbol = 8
    case enumeration = 9
    case method = 10
    case methodInstance = 11
    case function = 12
    case `class` = 13
    case slot = 14
    case tuple = 15
    case type = 16
    case array = 17
    case void = 18
    case stream = 19
    case metaclass = 20
    case module = 21
    case pointer = 22
    case other = 23
    case mutableString = 24
    }
