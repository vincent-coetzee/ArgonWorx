//
//  Class.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
import SwiftUI
import FFI

public class Class:ContainerSymbol,ObservableObject,Hashable,Equatable
    {
    public static func == (lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.name == rhs.name)
        }
        
    public static func <(lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.isSubclass(of: rhs))
        }
    
    public static func <=(lhs: Class, rhs: Class) -> Bool
        {
        return(lhs.isInclusiveSubclass(of: rhs))
        }
    ///
    ///
    /// Return the distance between this class and the
    /// Object class in the hieararchy.
    ///
    ///
    public var depth: Int
        {
        var depth = 0
        var aClass = self
        while aClass != ArgonModule.argonModule.object
            {
            depth += 1
            if depth > 2500
                {
                fatalError("Class '\(self.label)' has a depth in excess of 2500 which is likely incorrect, probably because Object is not in it's superclass tree.")
                }
            if aClass.superclasses.count < 1
                {
                fatalError("Can not calculate depth for class '\(self.label)' probably because it (erroneously) does not have Object in it's superclass tree.")
                }
            aClass = aClass.superclasses.first!
            }
        return(depth)
        }
        
    public override func emitCode(using: CodeGenerator)
        {
        print("NEED TO WRITE OUT CLASS \(self.label)")
        }
        
    public var innerClassPointer: InnerClassPointer
        {
        return(InnerClassPointer(address: self.memoryAddress))
        }
        
    public struct ClassOffset
        {
        let theClass:Class
        let offset:Int
        }
        
    public var scalarClass: Bool
        {
        return(false)
        }
        
    public var metaclass: Metaclass
        {
        if self._metaclass.isNil
            {
            self._metaclass = Metaclass(label: "\(self.label) metaclass",class: self)
            self._metaclass?.superclasses = self.superclasses.map{$0.metaclass}
            }
        return(self._metaclass!)
        }
        
    public static let number: Class = ArgonModule.argonModule.lookup(label:"Number") as! Class
    
    public var ffiType: ffi_type
        {
        return(ffi_type_uint64)
        }
        
    public override var typeCode: TypeCode
        {
        switch(self.label)
            {
            case "Integer":
                return(.integer)
            case "UInteger":
                return(.uInteger)
            case "String":
                return(.string)
            case "Array":
                return(.array)
            case "Class":
                return(.class)
            case "Float":
                return(.float)
            case "Boolean":
                return(.boolean)
            case "Byte":
                return(.byte)
            case "Character":
                return(.character)
            case "Stream":
                return(.stream)
            case "Slot":
                return(.slot)
            case "Module":
                return(.module)
            case "Tuple":
                return(.tuple)
            case "Symbol":
                return(.symbol)
            default:
                return(.other)
            }
        }
        
    public var isVoidType: Bool
        {
        return(false)
        }
        
    public override var type:Class
        {
        return(self)
        }
        
    public var isClassClass: Bool
        {
        return(self.label == "Class")
        }
        
    public var isMetaclassClass: Bool
        {
        return(self.label == "Metaclass")
        }
        
    public var isArrayClass: Bool
        {
        return(false)
        }
        
    public var isPrimitiveClass: Bool
        {
        return(false)
        }
        
    public var isStringClass: Bool
        {
        return(false)
        }
        
    public override var imageName: String
        {
        "IconClass"
        }
        
    public override var symbolColor: NSColor
        {
        .argonLime
        }
        
    public var isSystemClass: Bool
        {
        return(false)
        }
        
    public override var children: Symbols
        {
        return(self.symbols.values + self.subclasses.sorted{$0.label<$1.label})
        }
        
    public var sizeInBytes: Int
        {
        self.layoutSlots.count * MemoryLayout<UInt64>.size
        }
        
    public var sizeInWords: Int
        {
        self.sizeInBytes / MemoryLayout<Word>.size
        }
        
    public var localAndInheritedSlots: Slots
        {
        var slots:Slots = []
        for aClass in self.superclasses
            {
            slots += aClass.localAndInheritedSlots
            }
        slots += self.localSlots
        return(slots.removeDuplicates())
        }
        
    public var localSlots: Slots
        {
        return(self.symbols.values.compactMap{$0 as? Slot}.sorted{$0.label < $1.label})
        }
        
    public var localSystemSlots: Slots
        {
        var slots = Array<Slot>()
        slots.append(HeaderSlot(label: "_\(self.label)Header", type: ArgonModule.argonModule.integer.type))
        let slot1 = Slot(label: "_\(self.label)Magic", type: ArgonModule.argonModule.integer.type)
        slots.append(slot1)
        let slot2 = ObjectSlot(label: "_\(self.label)Class", type: ArgonModule.argonModule.class.type)
        slots.append(slot2)
        return(slots)
        }
        
    public override var weight: Int
        {
        1_000
        }
        
    public var allSubclasses: Array<Class>
        {
        var list = Array<Class>()
        for aClass in self.subclasses
            {
            if !list.contains(aClass)
                {
                list.append(aClass)
                list.append(contentsOf: aClass.allSubclasses)
                }
            }
        return(list.sorted{$0.label<$1.label})
        }
        
    internal var superclassHolders = SymbolHolders()
    internal var subclasses = Classes()
    internal var superclasses = Classes()
    internal var layoutSlots: Slots = []
    internal let magicNumber:Int
    internal var slotClassType:Slot.Type = Slot.self
    internal var isMemoryPreallocated = false
    internal var header = Header(0)
    internal var hasBytes = false
    internal var _metaclass: Metaclass?
    internal var mangledCode: Label
    
    public override init(label:Label)
        {
        self.magicNumber = label.polynomialRollingHash
        self.mangledCode = label
        super.init(label: label)
        }
        
    public func hash(into hasher:inout Hasher)
        {
        hasher.combine(self.index)
        hasher.combine(self.name)
        hasher.combine(self.label)
        }
        
    public func isSubclass(of superclass:Class) -> Bool
        {
        return(superclass.isSuperclass(of: self))
        }
        
    public func isInclusiveSubclass(of superclass:Class) -> Bool
        {
        if self == superclass
            {
            return(true)
            }
        return(superclass.isSuperclass(of: self))
        }
        
    public func mcode(_ code:String) -> Class
        {
        self.mangledCode = code
        return(self)
        }
        
    public func isSuperclass(of subclass:Class) -> Bool
        {
        for aClass in self.subclasses
            {
            if aClass == subclass
                {
                return(true)
                }
            }
        return(false)
        }
        
    public func superclass(_ string:String) -> Class
        {
        self.superclassHolders.append(SymbolHolder(name:Name(string),location:.zero,namingContext:nil,reporter:NullReportingContext.shared))
        return(self)
        }
        
    public func slotClass(_ aClass:Slot.Type) -> Class
        {
        self.slotClassType = aClass
        return(self)
        }
        
    public func hasBytes(_ value:Bool)
        {
        self.hasBytes = value
        }

    public override func layoutInMemory(segment:ManagedSegment)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        if !self.isMemoryPreallocated
            {
            self.memoryAddress = segment.allocateObject(sizeInBytes: ArgonModule.argonModule.class.sizeInBytes)
            }
        else if self.memoryAddress == 0
            {
            fatalError("Memory was preallocated but is nil")
            }
        var array = Words()
        for superclass in self.superclasses
            {
            superclass.layoutInMemory(segment: segment)
            array.append(superclass.memoryAddress)
            }
        let pointer = InnerClassPointer(address: self.memoryAddress)
        pointer.setName(self.label,in: segment)
        let slotsArray = InnerArrayPointer.allocate(arraySize: self.layoutSlots.count, in: segment)
        pointer.slots = slotsArray
        for slot in self.layoutSlots.sorted(by: {$0.offset < $1.offset})
            {
            slot.layoutSymbol(in: segment)
            slotsArray.append(slot.memoryAddress)
            }
        pointer.extraSizeInBytes = 0
        pointer.instanceSizeInBytes = self.sizeInBytes
        pointer.setSlotValue(self.hasBytes,atKey: "hasBytes")
        pointer.setSlotValue(false,atKey: "isValue")
        let superclassArray = InnerArrayPointer.allocate(arraySize: self.superclasses.count,in: segment)
        for aClass in self.superclasses
            {
            superclassArray.append(aClass.memoryAddress)
            }
        pointer.setSlotValue(superclassArray.address,atKey:"superclasses")
        pointer.magicNumber = self.magicNumber
        for superclass in self.superclasses
            {
            pointer.assignSystemSlots(from: superclass)
            }
        self.isMemoryLayoutDone = true
        print("LAID OUT CLASS \(self.label) AT ADDRESS \(self.memoryAddress.addressString)")
        }
        
    public func preallocateMemory(size:Int,in segment:ManagedSegment)
        {
        guard !self.isMemoryPreallocated else
            {
            return
            }
        self.isMemoryPreallocated = true
        self.memoryAddress = segment.allocateObject(sizeInBytes: size)
        ObjectPointer(address: self.memoryAddress).setWord(ArgonModule.argonModule.class.memoryAddress,atSlot:"_classPointer")
        let header = Header(WordPointer(address:self.memoryAddress)!.word(atByteOffset: 0))
        assert(header.sizeInWords == size / 8,"ALLOCATED SIZE DOES NOT EQUAL 512")
        }
        
    private func layoutSlot(atOffset: Int) -> Slot?
        {
        for slot in self.layoutSlots
            {
            if slot.offset == atOffset
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func rawDumpFromAddress(_ address:Word)
        {
        let pointer = WordPointer(address: address)!
        let allSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        for slot in allSlots
            {
            slot.printFormattedSlotContents(base: pointer)
            }
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localAndInheritedSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(super.lookup(label: label))
        }
        
    public func allSuperclasses() -> Array<Class>
        {
        var set = Array<Class>()
        for aClass in self.superclasses
            {
            if !set.contains(aClass)
                {
                set.append(aClass)
                }
            let supers = aClass.allSuperclasses()
            for aSuper in supers
                {
                if !set.contains(aSuper)
                    {
                    set.append(aSuper)
                    }
                }
            }
        return(set)
        }
        
    public func layoutObjectSlots()
        {
        guard !self.isSlotLayoutDone else
            {
            return
            }
        print("LAYING OUT CLASS \(self.label) DIRECTLY")
        var offset:Int = 0
        var visitedClasses = Set<Class>()
        visitedClasses.insert(self)
        var slot:Slot = HeaderSlot(label: "_header",type: ArgonModule.argonModule.integer)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        slot = Slot(label: "_magicNumber",type: ArgonModule.argonModule.integer)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        slot = ObjectSlot(label: "_classPointer",type: ArgonModule.argonModule.address)
        slot.setOffset(offset)
        self.layoutSlots.append(slot)
        offset += slot.size
        for aClass in self.superclasses
            {
            aClass.layoutObjectSlots(in: self,offset: &offset,visitedClasses: &visitedClasses)
            }
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                clonedSlot.setParent(self)
                self.layoutSlots.append(clonedSlot)
                offset += clonedSlot.size
                }
            }
        self.layoutSlots = self.layoutSlots.sorted{$0.offset < $1.offset}
        self.isSlotLayoutDone = true
        }
        
    public func layoutObjectSlots(in inClass:Class,offset: inout Int,visitedClasses: inout Set<Class>)
        {
        guard !visitedClasses.contains(self) else
            {
            return
            }
        visitedClasses.insert(self)
        print("LAYING OUT CLASS \(self.label) INDIRECTLY")
        var slot:Slot = HeaderSlot(label: "_\(self.label)Header",type: ArgonModule.argonModule.integer)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        slot = Slot(label: "_\(self.label)MagicNumber",type: ArgonModule.argonModule.integer)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        slot = ObjectSlot(label: "_\(self.label)ClassPointer",type: ArgonModule.argonModule.address)
        slot.setOffset(offset)
        inClass.layoutSlots.append(slot)
        offset += slot.size
        for aClass in self.superclasses
            {
            aClass.layoutObjectSlots(in: inClass,offset: &offset,visitedClasses: &visitedClasses)
            }
        for slot in self.localSlots
            {
            if !slot.isVirtual
                {
                let clonedSlot = slot.cloned
                clonedSlot.setOffset(offset)
                if inClass.layoutSlots.map({$0.label}).contains(clonedSlot.label)
                    {
                    print("halt")
                    }
                clonedSlot.setParent(self)
                inClass.layoutSlots.append(clonedSlot)
                offset += clonedSlot.size
                }
            }
        }
        
    public func printLayout()
        {
        print("-------------------------")
        print("CLASS \(self.name.description)")
        print("")
        print("SizeInBytes: \(self.sizeInBytes)")
        print("")
        let names = self.layoutSlots.sorted(by: {$0.offset < $1.offset}).map{"\($0.label)"}
        let mappedNames = names.map{"\"\($0)\""}.joined(separator: ",")
        print("[\(mappedNames)]")
        print()
        print("typedef struct _\(self.label)")
        print("\t{")
        for name in names
            {
            print("\tCWord \(name);")
            }
        print("\t}")
        print("\t\(self.label);")
        print()
        print("typedef \(self.label)* \(self.label)Pointer;")
        var index = 0
        for slot in self.layoutSlots.sorted(by: {$0.offset < $1.offset})
            {
            let indexString = String(format:"%04d",index)
            let offsetString = String(format:"%06d",slot.offset)
            print("\(indexString) \(offsetString) \(slot.label)")
            index += 1
            }
        }
        
    public override func realizeSuperclasses()
        {
        for reference in self.superclassHolders
            {
            if let symbol = reference.reify() as? Class
                {
                if !self.superclasses.contains(symbol)
                    {
                    self.superclasses.append(symbol)
                    }
                if !symbol.subclasses.contains(self)
                    {
                    symbol.subclasses.append(self)
                    }
                symbol.realizeSuperclasses()
                }
            }
        self.superclassHolders = []
        for aClass in self.superclasses
            {
            _ = aClass.metaclass
            }
        }
        
    @discardableResult
    public func slot(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        let slot = theClass.slotClassType.init(labeled:slotLabel,ofType:theClass.type)
        self.addSymbol(slot)
        return(self)
        }
        
    @discardableResult
    public func hiddenSlot(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        self.addSymbol(HiddenSlot(label:slotLabel,type:theClass.type))
        return(self)
        }
        
    @discardableResult
    public func virtual(_ slotLabel:Label,_ theClass:Class) -> Class
        {
        self.addSymbol(VirtualSlot(label:slotLabel,type:theClass.type))
        return(self)
        }
        
    public func layoutSlot(atLabel:Label) -> Slot?
        {
        for slot in self.layoutSlots
            {
            if slot.label == atLabel
                {
                return(slot)
                }
            }
        return(nil)
        }
        
    public func hasSlot(atLabel:Label) -> Bool
        {
        for slot in self.layoutSlots
            {
            if slot.label == atLabel
                {
                return(true)
                }
            }
        return(false)
        }
    }

public typealias Classes = Array<Class>

extension Classes
    {
    public static func <=(lhs:Classes,rhs:Classes) -> Bool
        {
        if lhs.count != rhs.count
            {
            return(false)
            }
        for (left,right) in zip(lhs,rhs)
            {
            if !(left <= right)
                {
                return(false)
                }
            }
        return(true)
        }
        
    public static func <(lhs:Classes,rhs:Classes) -> Bool
        {
        if lhs.count != rhs.count
            {
            return(false)
            }
        for (left,right) in zip(lhs,rhs)
            {
            if !(left < right)
                {
                return(false)
                }
            }
        return(true)
        }
    }
