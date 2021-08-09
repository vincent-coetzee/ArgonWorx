//
//  DataSegment.swift
//  DataSegment
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class DataSegment: Segment
    {
    public static let shared = DataSegment(sizeInBytes: 100 * 1024 * 1024)
    
    public override var segmentType:SegmentType
        {
        .data
        }
        
    public override var spaceFree: MemorySize
        {
        return(MemorySize.bytes(0))
        }
        
    public override var spaceUsed: MemorySize
        {
        return(MemorySize.bytes(0))
        }

    private let basePointer:UnsafeMutableRawBufferPointer
    private let baseAddress: Word
    private let endAddress: Word
    private var nextAddress: Word
    private var wordPointer: WordPointer
    
    public override init(sizeInBytes:Int)
        {
        print("ALLOCATING SPACE OF \(MemorySize.bytes(sizeInBytes).convertToHighestUnit().displayString)")
        self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<UInt64>.alignment)
        self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
        self.endAddress = baseAddress + UInt64(sizeInBytes)
        self.nextAddress = baseAddress
        self.wordPointer = WordPointer(address: self.baseAddress)!
        print("MANAGED SEGMENT SPACE OF SIZE \(sizeInBytes) ALLOCATED AT \(self.baseAddress.addressString)")
        super.init(sizeInBytes: sizeInBytes)
        }
        
    public override func address(offset: Word) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        fatalError("This has not been implemented")
        }
        
    public override func allocateString(_ string:String) -> Word
        {
        fatalError("This has not been implemented")
        }
    }
