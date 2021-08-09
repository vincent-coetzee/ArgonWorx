//
//  WhileBlock.swift
//  WhileBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class WhileBlock: Block
    {
    private let condition:Expression
    
    init(condition: Expression)
        {
        self.condition = condition
        super.init()
        }
    }
