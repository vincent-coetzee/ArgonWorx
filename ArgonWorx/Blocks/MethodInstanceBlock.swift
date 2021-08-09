//
//  MethodInstanceBlock.swift
//  MethodInstanceBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class MethodInstanceBlock: Block
    {
    private let methodInstance: MethodInstance
    
    public override var method: MethodInstance
        {
        return(self.methodInstance)
        }
        
    init(methodInstance:MethodInstance)
        {
        self.methodInstance = methodInstance
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.methodInstance.lookup(label: label))
        }
        
    public override func addLocalSlot(_ slot:LocalSlot)
        {
        self.methodInstance.addLocalSlot(slot)
        }
        
    public override func emitCode(into: MethodInstance,using: CodeGenerator)
        {
        for block in self.blocks
            {
            block.emitCode(into: into,using: using)
            }
        }
    }
