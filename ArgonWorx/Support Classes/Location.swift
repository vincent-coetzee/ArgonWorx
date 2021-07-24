//
//  Location.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public struct Location
    {
    public static let zero = Location(line:0,lineStart:0,lineStop:0,tokenStart:0,tokenStop:0)
    
    private let line:Int
    private let tokenStart:Int
    private let tokenStop:Int
    private let lineStart:Int
    private let lineStop:Int
    
    public init(line:Int,lineStart:Int,lineStop:Int,tokenStart:Int,tokenStop:Int)
        {
        self.line = line
        self.lineStart = lineStart
        self.lineStop = lineStop
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        }
    }
