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
    
    public init(condition: Expression)
        {
        self.condition = condition
        super.init()
        }
    }
    
