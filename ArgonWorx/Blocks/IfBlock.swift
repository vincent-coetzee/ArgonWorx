//
//  IfBlock.swift
//  IfBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class IfBlock: Block
    {
    private let condition:Expression
    internal var elseBlock: Block?
    
    public init(condition: Expression)
        {
        self.condition = condition
        super.init()
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)IF")
        condition.dump(depth: depth+1)
        for block in self.blocks
            {
            block.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using: CodeGenerator) throws
        {
        try self.condition.emitCode(into: buffer,using: using)
        buffer.append(.brf,self.condition.place,.none,.label(0))
        let fromThere = buffer.triggerFromHere()
        for block in self.blocks
            {
            try block.emitCode(into: buffer,using: using)
            }
        let fromEnd = buffer.triggerFromHere()
        if self.elseBlock.isNotNil
            {
            try buffer.toHere(fromThere)
            try self.elseBlock!.emitCode(into: buffer,using: using)
            }
        else
            {
            try buffer.toHere(fromThere)
            }
        try buffer.toHere(fromEnd)
        }
    }
    
