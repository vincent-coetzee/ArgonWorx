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
        case data = 4
        }
        
    public var segmentType:SegmentType
        {
        .none
        }
        
    public var spaceFree: MemorySize
        {
        return(MemorySize.bytes(0))
        }
        
    public var spaceUsed: MemorySize
        {
        return(MemorySize.bytes(0))
        }

    public let size: MemorySize
        
    public init(sizeInBytes:Int)
        {
        self.size = MemorySize.bytes(sizeInBytes)
        }
        
    public func address(offset: Word) -> Word
        {
        return(0)
        }
        
    public func allocateObject(sizeInBytes:Int) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public func allocateString(_ string:String) -> Word
        {
        fatalError("This has not been implemented")
        }
    }
