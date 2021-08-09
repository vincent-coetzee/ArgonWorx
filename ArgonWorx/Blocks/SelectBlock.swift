//
//  SelectBlock.swift
//  SelectBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class SelectBlock: Block
    {
    private let value:Expression
    private var whenBlocks:Array<WhenBlock>
    public var otherwiseBlock: OtherwiseBlock?
    
    init(value: Expression)
        {
        self.value = value
        whenBlocks = Array<WhenBlock>()
        super.init()
        }
        
    public func addWhen(block: WhenBlock)
        {
        self.whenBlocks.append(block)
        }
    }
