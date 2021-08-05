//
//  LiteralExpression.swift
//  LiteralExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public indirect enum Literal
    {
    case `nil`
    case integer(Argon.Integer)
    case float(Argon.Float)
    case string(String)
    case boolean(Argon.Boolean)
    case symbol(Argon.Symbol)
    case array([Literal])
    }

public class LiteralExpression: Expression
    {
    private let literal:Literal
    
    init(_ literal:Literal)
        {
        self.literal = literal
        super.init()
        }
    }
