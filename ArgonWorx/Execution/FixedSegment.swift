//
//  FixedSegment.swift
//  FixedSegment
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class FixedSegment:Segment
    {
    public static let shared = FixedSegment(sizeInBytes: 1024*1024*100)
    
    public var startOffset: Word
        {
        return(self.baseAddress)
        }
        
    public var endOffset: Word
        {
        return(self.nextAddress)
        }
        
    public var bytesInUse: Int
        {
        return(Int(self.nextAddress - self.baseAddress))
        }
        
    private var basePointer: UnsafeMutableRawBufferPointer
    private let baseAddress: Word
    private var nextAddress: UInt64
    private var endAddress: UInt64
    private var wordPointer: WordPointer
    
    override init(sizeInBytes:Int)
        {
        self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<UInt64>.alignment)
        self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
        self.endAddress = baseAddress + UInt64(sizeInBytes)
        self.nextAddress = baseAddress
        self.wordPointer = WordPointer(address: self.baseAddress)!
        super.init(sizeInBytes:sizeInBytes)
        print("MANAGED SEGMENT OF SIZE \(self.sizeInBytes) ALLOCATED AT \(self.baseAddress.addressString)")
        }

    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        if self.nextAddress >= self.endAddress
            {
            fatalError("The FixedSegment has run out of space, allocate a larger space and rerun the system")
            }
        let newPointer = self.nextAddress;
        self.nextAddress += UInt64(sizeInBytes)
        let pointer = UnsafeMutablePointer<Word>(bitPattern: UInt(newPointer))!
        var header:Header = 0
        header.tag = .header
        header.sizeInWords = sizeInBytes / MemoryLayout<Word>.size
        header.isForwarded = false
        header.flipCount = 0
        header.hasBytes = false
        pointer[0] = header
        return(newPointer)
        }

    public override func allocateString(_ string:String) -> Word
        {
        let extraBytes = ((string.utf8.count / 7) + 1) * 8
        let totalBytes = ArgonModule.argonModule.string.sizeInBytes + extraBytes
        let address = self.allocateObject(sizeInBytes: totalBytes)
        let object = ObjectPointer(address: address)
        object.setWord(ArgonModule.argonModule.string.memoryAddress,atSlot:"_classPointer")
        let pointer = StringPointer(address: address)
        pointer.string = string
        return(address)
        }
    }
