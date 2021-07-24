//
//  Segment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public class Segment
    {
    public enum SegmentType:UInt64
        {
        case none = 0
        case stack = 1
        case `static` = 2
        case managed = 3
        }
        
    public var segmentType:SegmentType
        {
        .none
        }
        
    public let sizeInBytes:Int
    
    public init(sizeInBytes:Int)
        {
        self.sizeInBytes = sizeInBytes
        }
        
    public func allocateObject(sizeInBytes:Int) -> UInt64
        {
        return(0)
        }
    }
