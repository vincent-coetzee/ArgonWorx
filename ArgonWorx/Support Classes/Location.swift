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
    
    public var range: NSRange
        {
        NSRange(location: self.tokenStart, length: self.tokenStop - self.tokenStart)
        }
        
    public let line:Int
    public let tokenStart:Int
    public let tokenStop:Int
    public let lineStart:Int
    public let lineStop:Int
    
    public init(line:Int,lineStart:Int,lineStop:Int,tokenStart:Int,tokenStop:Int)
        {
        self.line = line
        self.lineStart = lineStart
        self.lineStop = lineStop
        self.tokenStart = tokenStart
        self.tokenStop = tokenStop
        }
    }

public typealias Locations = Array<Location>
