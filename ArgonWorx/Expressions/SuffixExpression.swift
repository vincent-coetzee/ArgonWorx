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
        
    public override func realize(using realizer: Realizer)
        {
        self.expression.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        try self.expression.emitCode(into: instance,using: using)
        switch(self.operation.name)
            {
            case "++":
                instance.append(.inc,self.expression.place,.none,self.expression.place)
            case "--":
                instance.append(.dec,self.expression.place,.none,self.expression.place)
            default:
                break
            }
        }
    }
