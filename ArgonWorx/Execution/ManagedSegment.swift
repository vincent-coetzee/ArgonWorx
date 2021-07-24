//
//  ManagedSegment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public class ManagedSegment:Segment
    {
    public static let shared = ManagedSegment(sizeInBytes: 1024*1024*100)
    
    public var startOffset: Word
        {
        return(self.baseAddress)
        }
        
    public var endOffset: Word
        {
        return(self.nextAddress)
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
        let next = unsafeBitCast(self.basePointer.baseAddress,to: UInt64.self)
        self.endAddress = next + UInt64(sizeInBytes)
        self.nextAddress = next
        self.wordPointer = WordPointer(address: self.baseAddress)!
        super.init(sizeInBytes:sizeInBytes)
        print("MANAGED SEGMENT OF SIZE \(self.sizeInBytes) ALLOCATED AT \(self.baseAddress.addressString)")
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        let newPointer = self.nextAddress;
        print("ALLOCATED \(sizeInBytes) BYTES @ \(newPointer.addressString)")
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
        
    public func allocateInstance(ofClass:InnerClassPointer) -> Word
        {
        let sizeInBytes = ofClass.instanceSizeInBytes
        let address = self.allocateObject(sizeInBytes: sizeInBytes)
        let pointer = InnerInstancePointer(address: address)
        pointer.classPointer = ofClass
        pointer.magicNumber = 0
        return(address)
        }
        
        
    public func allocateArray(maximumCount:Int) -> UInt64
        {
        let objectSizeInBytes = ArgonModule.argonModule.array.sizeInBytes
        let extraSizeInBytes = maximumCount * MemoryLayout<Word>.size
        let totalSizeInBytes = objectSizeInBytes + extraSizeInBytes
        let address = self.allocateObject(sizeInBytes: totalSizeInBytes)
        let pointer = ObjectPointer(address: address,class:ArgonModule.argonModule.array)
        pointer.setWord(0,atSlot: "count")
        pointer.setWord(Word(maximumCount),atSlot: "size")
        pointer.setBoolean(true,atSlot: "hasBytes")
        return(address)
        }
        
    public func allocateString(_ string:String) -> Word
        {
        let extraBytes = ((string.utf8.count / 7) + 1) * 8
        let totalBytes = ArgonModule.argonModule.string.sizeInBytes + extraBytes
        let address = self.allocateObject(sizeInBytes: totalBytes)
        let pointer = StringPointer(address: address)
        pointer.string = string
        return(address)
        }
        
    public func word(atOffset:Word) -> Word
        {
        UnsafePointer<Word>(bitPattern: UInt(atOffset))!.pointee
        }
    }
