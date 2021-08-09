//
//  ManagedSegment.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 21/7/21.
//

import Foundation

public typealias FileStream = UnsafeMutablePointer<FILE>

public indirect enum MemorySize
    {
    public enum Units
        {
        internal static let kBytesPerKilobyte = 1024
        internal static let kBytesPerMegabyte = 1024 * 1024
        internal static let kBytesPerGigabyte = 1024 * 1024 * 1024
        
        case bytes
        case kilobytes
        case megabytes
        case gigabytes
        }
        
    case bytes(Int)
    case kilobytes(Int,MemorySize)
    case megabytes(Int,MemorySize)
    case gigabytes(Int,MemorySize)
    
    public var displayString: String
        {
        switch(self)
            {
            case .bytes(let bytes):
                return("\(bytes) B")
            case .kilobytes(let kb,let rest):
                return("\(kb) KB \(rest.displayString)")
            case .megabytes(let meg,let rest):
                return("\(meg) MB \(rest.displayString)")
            case .gigabytes(let gig,let rest):
                return("\(gig) GB \(rest.displayString)")
            }
        }
        
    public var units: Units
        {
        switch(self)
            {
            case .bytes:
                return(.bytes)
            case .kilobytes:
                return(.kilobytes)
            case .megabytes:
                return(.megabytes)
            case .gigabytes:
                return(.gigabytes)
            }
        }
        
    public var inBytes: Int
        {
        switch(self)
            {
            case .bytes(let bytes):
                return(bytes)
            case .kilobytes(let kb,let bytes):
                return(kb * Units.kBytesPerKilobyte + bytes.inBytes)
            case .megabytes(let meg,let kb):
                return(meg * Units.kBytesPerMegabyte + kb.inBytes)
            case .gigabytes(let gig,let meg):
                return(gig * Units.kBytesPerGigabyte + meg.inBytes)
            }
        }
        
    public var primaryUnit:Int
        {
        switch(self)
            {
            case .bytes(let bytes):
                return(bytes)
            case .kilobytes(let kb,_):
                return(kb)
            case .megabytes(let meg,_):
                return(meg)
            case .gigabytes(let gig,_):
                return(gig)
            }
        }
        
    public func convertToHighestUnit() -> MemorySize
        {
        var top = self.convert(toUnits: .gigabytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        top = self.convert(toUnits: .megabytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        top = self.convert(toUnits: .kilobytes)
        if top.primaryUnit > 0
            {
            return(top)
            }
        return(self.convert(toUnits: .megabytes))
        }
        
    public func size(inUnits:Units) -> MemorySize
        {
        if self.units == inUnits
            {
            return(self)
            }
        return(self.convert(toUnits: inUnits))
        }
        
    private func convert(toUnits: Units) -> Self
        {
        switch(self)
            {
            case .bytes(let amount):
                if toUnits == .kilobytes
                    {
                    let unit = amount / Units.kBytesPerKilobyte
                    let remainder = amount - unit*Units.kBytesPerKilobyte
                    return(.kilobytes(unit,.bytes(remainder)))
                    }
                else if toUnits == .megabytes
                    {
                    let meg = amount / Units.kBytesPerMegabyte
                    let remainder = amount - meg * Units.kBytesPerMegabyte
                    let kb = remainder / Units.kBytesPerKilobyte
                    let bytes = remainder - kb * Units.kBytesPerKilobyte
                    return(.megabytes(meg,.kilobytes(kb,.bytes(bytes))))
                    }
                else if toUnits == .gigabytes
                    {
                    let gig = amount / Units.kBytesPerGigabyte
                    let remainder = amount - gig  * Units.kBytesPerGigabyte
                    let meg = remainder / Units.kBytesPerMegabyte
                    let remainder1 = remainder - meg * Units.kBytesPerMegabyte
                    let kb = remainder1 / Units.kBytesPerKilobyte
                    let bytes = remainder1 - kb * Units.kBytesPerKilobyte
                    return(.gigabytes(gig,.megabytes(meg,.kilobytes(kb,.bytes(bytes)))))
                    }
            case .kilobytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            case .megabytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            case .gigabytes:
                return(.bytes(self.inBytes).convert(toUnits: units))
            }
        return(self)
        }
    }
    
public class ManagedSegment:Segment
    {
    public override var spaceFree: MemorySize
        {
        return(self.fromSpace.spaceFree)
        }
        
    public override var spaceUsed: MemorySize
        {
        return(self.fromSpace.spaceUsed)
        }
        
    public override var segmentType:SegmentType
        {
        .managed
        }
        
    private struct Space
        {
        public var isFull: Bool
            {
            return(self.baseAddress >= self.endAddress)
            }
            
        public var spaceFree: MemorySize
            {
            return(MemorySize.bytes(Int(self.endAddress - self.nextAddress)))
            }
            
        public var spaceUsed: MemorySize
            {
            return(MemorySize.bytes(Int(self.nextAddress - self.baseAddress)))
            }
            
        private var basePointer: UnsafeMutableRawBufferPointer
        internal let baseAddress: Word
        internal var nextAddress: UInt64
        private var endAddress: UInt64
        private var wordPointer: WordPointer
        private let sizeInBytes: Int
        
        init(sizeInBytes: Int)
            {
            print("ALLOCATING SPACE OF \(MemorySize.bytes(sizeInBytes).convertToHighestUnit().displayString)")
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
