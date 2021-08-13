//
//  Block.swift
//  Block
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class Block:NSObject,NamingContext
    {
    public var declaration: Location
        {
        self.locations.declaration
        }
        
    internal var locations = SourceLocations()
    internal var blocks = Blocks()
    internal var localSlots = Slots()
    public let index:UUID
    
    public private(set) var parent: NamingContext!
    
    public var methodInstance: MethodInstance
        {
        return((self.parent as! Block).methodInstance)
        }
        
    public var primaryContext: NamingContext
        {
        return(TopModule.topModule)
        }
    
    public func addSymbol(_ symbol: Symbol)
        {
        if !(symbol is LocalSlot)
            {
            fatalError("Attempt to add a symbol to a block")
            }
        self.addLocalSlot(symbol as! LocalSlot)
        }
    
    override init()
        {
        self.index = UUID()
        }
        
    init(coder: NSCoder)
        {
        self.blocks = coder.decodeObject(forKey: "blocks") as! Array<Block>
        self.localSlots = coder.decodeObject(forKey:"localSlots") as! Array<Slot>
        self.index = coder.decodeObject(forKey: "index") as! UUID
        self.parent = coder.decodeObject(forKey: "parent") as? NamingContext
        }
        
    public func encode(with coder: NSCoder)
        {
        coder.encode(self.blocks,forKey: "blocks")
        coder.encode(self.localSlots,forKey: "localSlots")
        coder.encode(self.index,forKey: "index")
        coder.encode(self.parent,forKey: "parent")
        }
        
    public func addBlock(_ block:Block)
        {
        self.blocks.append(block)
        block.parent = self
        }
        
    public func addLocalSlot(_ localSlot:Slot)
        {
        self.localSlots.append(localSlot)
        }
        
    public func setParent(_ block:NamingContext?)
        {
        self.parent = block
        }
        
    public func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        for block in self.blocks
            {
            try block.emitCode(into: into,using: using)
            }
        }
        
    public func addDeclaration(_ location:Location)
        {
        self.locations.append(.declaration(location))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func realize(using realizer: Realizer)
        {
        for block in self.blocks
            {
            block.realize(using: realizer)
            }
        }
        
    public func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for block in self.blocks
            {
            block.analyzeSemantics(using: analyzer)
            }
        }
        
    public func lookup(label: String) -> Symbol?
        {
        for slot in self.localSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.parent.lookup(label: label))
        }
        
    public func lookup(name: Name) -> Symbol?
        {
        if name.isRooted
            {
            return(TopModule.topModule.lookup(name: name.withoutFirst))
            }
        else if name.isEmpty
            {
            return(nil)
            }
        if let start = self.lookup(label: name.first)
            {
            if name.count == 1
                {
                return(start)
                }
            return(start.lookup(name: name.withoutFirst))
            }
        return(nil)
        }
        
        
    public func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        for block in self.blocks
            {
            block.dump(depth: depth+1)
            }
        }
    }
    
public typealias Blocks = Array<Block>

    


    

    
