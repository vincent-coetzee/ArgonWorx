//
//  ExpressionBlock.swift
//  ExpressionBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ExpressionBlock: Block
    {
    private let expression:Expression
    
    init(_ expression:Expression)
        {
        self.expression = expression
        super.init()
        }
    }
