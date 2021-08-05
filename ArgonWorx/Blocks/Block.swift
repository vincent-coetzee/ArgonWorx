//
//  Block.swift
//  Block
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class Block:NamingContext
    {
    private var blocks = Blocks()
    private var localSlots = LocalSlots()
    public private(set) var parent: Block!
    
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
    
    public func addBlock(_ block:Block)
        {
        self.blocks.append(block)
        }
        
    public func addLocalSlot(_ localSlot:LocalSlot)
        {
        self.localSlots.append(localSlot)
        }
        
    public func setParent(_ block:Block)
        {
        self.parent = block
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
        else if !name.isEmpty,let start = self.lookup(label: name.first)
            {
            return(start.lookup(name: name.withoutFirst))
            }
        return(nil)
        }
        
    }
    
public typealias Blocks = Array<Block>

    


    

    
