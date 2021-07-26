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
    public var allocatedStrings = Set<Word>()
    public var allocatedArrays = Set<Word>()
    public var allocatedSlots = Set<Word>()
    public var allocatedClasses = Set<Word>()
    
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
        self.endAddress = baseAddress + UInt64(sizeInBytes)
        self.nextAddress = baseAddress
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
        self.allocatedArrays.insert(address)
        let pointer = InnerArrayPointer(address: address)
        pointer.setSlotValue(ArgonModule.argonModule.array.memoryAddress,atKey:"_classPointer")
        pointer.count = 0
        pointer.size = maximumCount
        return(address)
        }
        
    public func allocateString(_ string:String) -> Word
        {
        let extraBytes = ((string.utf8.count / 7) + 1) * 8
        let totalBytes = ArgonModule.argonModule.string.sizeInBytes + extraBytes
        let address = self.allocateObject(sizeInBytes: totalBytes)
        self.allocatedStrings.insert(address)
        let object = ObjectPointer(address: address)
        object.setWord(ArgonModule.argonModule.string.memoryAddress,atSlot:"_classPointer")
        let pointer = StringPointer(address: address)
        pointer.string = string
        return(address)
        }
        
    public func word(atOffset:Word) -> Word
        {
        UnsafePointer<Word>(bitPattern: UInt(atOffset))!.pointee
        }
        
    public func writeInt32(_ integer:Int,to file:FileStream)
        {
        var value:CInt = CInt(integer)
        fwrite(&value,MemoryLayout<CInt>.size,1,file)
        }
        
    public func writeWord(_ integer:Word,to file:FileStream)
        {
        var value:CUnsignedLongLong = CUnsignedLongLong(integer)
        fwrite(&value,MemoryLayout<CUnsignedLongLong>.size,1,file)
        }
        
    public func writeString(_ string:String,to file:FileStream)
        {
        self.writeInt32(string.utf8.count,to:file)
        _ = string.withCString
            {
            pointer in
            fwrite(pointer,1,string.utf8.count,file)
            }
        }
        
    public func write(to file:FileStream)
        {
        let pointer = UnsafeRawPointer(bitPattern: UInt(self.baseAddress))
        let numberToWrite = self.nextAddress - self.baseAddress
        self.writeWord(numberToWrite,to: file)
        let bytesWritten = fwrite(pointer,Int(numberToWrite),1,file)
        if bytesWritten != numberToWrite
            {
            fatalError("Could not save segment image out, error = \(errno)")
            }
        let classes = TopModule.topModule.classes
        self.writeInt32(classes.count,to:file)
        for aClass in classes
            {
            self.writeString(aClass.name.description,to:file)
            self.writeWord(aClass.memoryAddress,to:file)
            }
        }
        
    public func backpatchAllocatedObjectClasses()
        {
        for address in self.allocatedStrings
            {
            let pointer = InnerStringPointer(address: address)
            pointer.setSlotValue(ArgonModule.argonModule.string.memoryAddress, atKey: "_classPointer")
            pointer.setSlotValue(ArgonModule.argonModule.string.magicNumber, atKey: "_magicNumber")
            }
        for address in self.allocatedArrays
            {
            let pointer = InnerArrayPointer(address: address)
            pointer.setSlotValue(ArgonModule.argonModule.array.memoryAddress, atKey: "_classPointer")
            pointer.setSlotValue(ArgonModule.argonModule.array.magicNumber, atKey: "_magicNumber")
            }
        for address in self.allocatedSlots
            {
            let pointer = InnerSlotPointer(address: address)
            pointer.setSlotValue(ArgonModule.argonModule.slot.memoryAddress, atKey: "_classPointer")
            pointer.setSlotValue(ArgonModule.argonModule.slot.magicNumber, atKey: "_magicNumber")
            }
        for address in self.allocatedClasses
            {
            let pointer = InnerClassPointer(address: address)
            pointer.setSlotValue(ArgonModule.argonModule.class.memoryAddress, atKey: "_classPointer")
            pointer.setSlotValue(ArgonModule.argonModule.class.magicNumber, atKey: "_magicNumber")
            }
        }
    }
