//
//  SuffixExpression.swift
//  SuffixExpression
//
//  Created by Vincent Coetzee on 10/8/21.
//

import Foundation

public class SuffixExpression: Expression
    {
    public override var resultType: TypeResult
        {
        return(self.expression.resultType)
        }
        
    public let operation: Token.Operator
    public let expression: Expression
    
    init(_ expression:Expression,_ operation:Token.Operator)
        {
        self.operation = operation
        self.expression = expression
        }
    }
