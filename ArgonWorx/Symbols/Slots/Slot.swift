//
//  Slot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public enum SlotValue
    {
    case none
    case classPointer(Word)
    case classMagicNumber(Int)
    case array([Word])
    }
    
public class Slot:Symbol
    {
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
    public var value:SlotValue = .none
    
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
        self.memoryAddress = segment.allocateObject(sizeInBytes: ArgonModule.argonModule.slot.sizeInBytes)
        assert( ArgonModule.argonModule.slot.sizeInBytes == 80)
        segment.allocatedSlots.insert(self.memoryAddress)
        let pointer = ObjectPointer(address: self.memoryAddress,class: ArgonModule.argonModule.slot)
        pointer.name = segment.allocateString(self.label)
        pointer.type = 0
        pointer.offset = Word(self.offset)
        self.isMemoryLayoutDone = true
        }
        
    public func layoutValue(in segment:ManagedSegment,at pointer:ObjectPointer)
        {
        switch(self.value)
            {
            case .classPointer(let address):
                pointer[self.offset] = address
            case .classMagicNumber(let number):
                pointer[self.offset] = Word(bitPattern: Int64(number))
            case .array(let elements):
                let array = segment.allocateArray(maximumCount: elements.count * 2)
                var arrayPointer = ArrayPointer(address: array)
                arrayPointer.append(elements)
                pointer[self.offset] = array
            default:
                break
            }
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
