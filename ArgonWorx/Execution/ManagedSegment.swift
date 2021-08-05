//
//  ManagedSegment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public typealias FileStream = UnsafeMutablePointer<FILE>

public class ManagedSegment:Segment
    {
    private struct Space
        {
        public var isFull: Bool
            {
            return(self.baseAddress >= self.endAddress)
            }
            
        public var bytesInUse: Int
            {
            return(Int(self.nextAddress - self.baseAddress))
            }
        
        private var basePointer: UnsafeMutableRawBufferPointer
        internal let baseAddress: Word
        internal var nextAddress: UInt64
        private var endAddress: UInt64
        private var wordPointer: WordPointer
        private let sizeInBytes: Int
        
        init(sizeInBytes: Int)
            {
            self.sizeInBytes = sizeInBytes
            self.basePointer = UnsafeMutableRawBufferPointer.allocate(byteCount: sizeInBytes, alignment: MemoryLayout<UInt64>.alignment)
            self.baseAddress = unsafeBitCast(self.basePointer.baseAddress,to: Word.self)
            self.endAddress = baseAddress + UInt64(sizeInBytes)
            self.nextAddress = baseAddress
            self.wordPointer = WordPointer(address: self.baseAddress)!
            print("MANAGED SEGMENT SPACE OF SIZE \(self.sizeInBytes) ALLOCATED AT \(self.baseAddress.addressString)")
            }
            
        public mutating func allocateObject(sizeInBytes:Int) -> Word
            {
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
            
        public mutating func allocateString(_ string:String) -> Word
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
        
    public static let shared = ManagedSegment(sizeInBytes: 1024*1024*100)
    
    public var startOffset: Word
        {
        return(self.fromSpace.baseAddress)
        }
        
    public var endOffset: Word
        {
        return(self.fromSpace.nextAddress)
        }
        
    public var bytesInUse: Int
        {
        return(self.fromSpace.bytesInUse)
        }
        
    private var fromSpace: Space
    private var toSpace: Space
    private var middleSpace: Space
    private var finalSpace: Space
    
    override init(sizeInBytes:Int)
        {
        self.fromSpace = Space(sizeInBytes: sizeInBytes)
        self.toSpace = Space(sizeInBytes: sizeInBytes)
        self.middleSpace = Space(sizeInBytes: sizeInBytes)
        self.finalSpace = Space(sizeInBytes: sizeInBytes)
        super.init(sizeInBytes: sizeInBytes)
        }
        
    private func collectGarbage()
        {
        }
        
    public override func allocateObject(sizeInBytes:Int) -> Word
        {
        if self.fromSpace.isFull
            {
            self.collectGarbage()
            }
        return(self.fromSpace.allocateObject(sizeInBytes: sizeInBytes))
        }

    public override func allocateString(_ string:String) -> Word
        {
        return(self.fromSpace.allocateString(string))
        }
    }
