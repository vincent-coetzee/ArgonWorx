//
//  Slot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public class Slot:Symbol
    {
    public override var type:Type
        {
        return(self._type)
        }
        
    public var size:Int
        {
        return(MemoryLayout<Word>.size)
        }
        
    public override var displayName: String
        {
        "\(self.label)::\(self._type.displayName)"
        }
        
    public override var imageName: String
        {
        "IconSlot"
        }
        
    public override var symbolColor: NSColor
        {
        .argonCoral
        }
        
    public override var weight: Int
        {
        100
        }
        
    public var isArraySlot:Bool
        {
        return(false)
        }
    
    public var isStringSlot:Bool
        {
        return(false)
        }
        
    public var isHidden: Bool
        {
        return(true)
        }
        
    public var cloned: Slot
        {
        let newSlot = Slot(label: self.label,type:self._type)
        newSlot.offset = self.offset
        return(newSlot)
        }
        
    public var isVirtual: Bool
        {
        return(false)
        }
        
    private let _type:Type
    public private(set) var offset:Int = 0
    
    init(label:Label,type:Type)
        {
        self._type = type
        super.init(label:label)
        }
        
    required init(labeled:Label,ofType:Type)
        {
        self._type = ofType
        super.init(label:labeled)
        }
        
    public func setOffset(_ integer:Int)
        {
        self.offset = integer
        }
        
    public func printFormattedSlotContents(base:WordPointer)
        {
        let offsetValue = self.offset
        let offsetString = String(format: "%08X",offsetValue)
        let name = self.label.aligned(.left,in:25)
        let word = base.word(atByteOffset: offsetValue)
        print("\(offsetString) \(name) WRD \(word.bitString) \(word)")
        }
        
    public func layoutSymbol(in segment:ManagedSegment)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        let pointer = InnerSlotPointer.allocate(in: segment)
        self.memoryAddress = pointer.address
        assert( ArgonModule.argonModule.slot.sizeInBytes == 88)
        pointer.setSlotValue(segment.allocateString(self.label),atKey:"name")
        pointer.setSlotValue(self._type.typeClass.memoryAddress,atKey:"slotClass")
        pointer.setSlotValue(self.offset,atKey:"offset")
        pointer.setSlotValue(self._type.typeClass.typeCode.rawValue,atKey:"typeCode")
        self.isMemoryLayoutDone = true
        }
    }

public typealias Slots = Array<Slot>

extension Slots
    {
    public func removeDuplicates() -> Slots
        {
        var seenSlots = Slots()
        for slot in self
            {
            if !seenSlots.contains(slot)
                {
                seenSlots.append(slot)
                }
            }
        return(seenSlots)
        }
    }

public class HiddenSlot: Slot
    {
    public override var isHidden: Bool
        {
        return(true)
        }
    }
