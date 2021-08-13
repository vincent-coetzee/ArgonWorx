//
//  Slot.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public enum AddressDescriptor
    {
    case none
    case register(Instruction.Register)
    case address(Word)
    case stack(Instruction.Register,Int)
    
    public var operand: Instruction.Operand
        {
        switch(self)
            {
            case .none:
                fatalError()
            case .register(let register):
                return(.register(register))
            case .address(let address):
                return(.address(address))
            case .stack(let register,let offset):
                return(.stack(register,Argon.Integer(offset)))
            }
        }
    }
    
public class AddressDescriptors
    {
    public var valueIsDuplicated: Bool
        {
        for _ in self.descriptors
            {
            return(true)
            }
        return(false)
        }
        
    private var descriptors = Array<AddressDescriptor>()
    
    public func append(_ descriptor:AddressDescriptor)
        {
        self.descriptors.append(descriptor)
        }
    }
    
public class Slot:Symbol,Equatable
    {
    public static func ==(lhs:Slot,rhs:Slot) -> Bool
        {
        return(lhs.index == rhs.index)
        }
        
    public override var typeCode:TypeCode
        {
        .slot
        }
        
    public override var type:Class
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
        
    private let _type:Class
    public private(set) var offset:Int = 0
    public var initialValue: Expression? = nil
    public var isClassSlot = false
    public var addressDescriptors = AddressDescriptors()
    public var stackOffset: Int = 0
    
    init(label:Label,type:Class)
        {
        self._type = type
        super.init(label:label)
        }
        
    required init(labeled:Label,ofType:Class)
        {
        self._type = ofType
        super.init(label:labeled)
        }

    public override func realize(using realizer: Realizer)
        {
        self._type.realize(using: realizer)
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
        pointer.setSlotValue(self._type.memoryAddress,atKey:"slotClass")
        pointer.setSlotValue(self.offset,atKey:"offset")
        pointer.setSlotValue(self._type.typeCode.rawValue,atKey:"typeCode")
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

public class ScopedSlot: Slot
    {
    }
