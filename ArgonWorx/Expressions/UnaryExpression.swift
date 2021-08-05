//
//  UnaryExpression.swift
//  UnaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class UnaryExpression: Expression
    {
    private let operation: Token.Symbol
    private let rhs: Expression
    
    init(_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        super.init()
        }
    }
