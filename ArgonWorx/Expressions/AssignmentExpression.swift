//
//  AssignmentExpression.swift
//  AssignmentExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class AssignmentExpression: Expression
    {
    private let rhs: Expression
    private let lhs: Expression
    
    init(_ lhs:Expression,_ rhs:Expression)
        {
        self.rhs = rhs
        self.lhs = lhs
        super.init()
        }
    }
