//
//  BinaryExpression.swift
//  BinaryExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class BinaryExpression: Expression
    {
    private let operation: Token.Symbol
    private let rhs: Expression
    private let lhs: Expression
    
    init(_ lhs:Expression,_ operation:Token.Symbol,_ rhs:Expression)
        {
        self.operation = operation
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        }
    }
