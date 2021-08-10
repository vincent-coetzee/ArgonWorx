//
//  ArrayAccessExpression.swift
//  ArrayAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ArrayAccessExpression: Expression
    {
    private let array:Expression
    private let index:Expression
    
    init(array:Expression,index:Expression)
        {
        self.array = array
        self.index = index
        }
        
    public override var resultType: TypeResult
        {
        self.array.resultType
        }
        
    public override func realize(_ compiler:Compiler)
        {
        self.array.realize(compiler)
        self.index.realize(compiler)
        }
    }
