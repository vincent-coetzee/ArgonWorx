//
//  Argument.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct Argument
    {
    public let tag:String?
    public let value:Expression
    }

public typealias Arguments = Array<Argument>
