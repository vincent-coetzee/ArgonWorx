//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression
    {
    public func operation(_ symbol:Token.Symbol,_ rhs:Expression) -> Expression
        {
        return(BinaryExpression(self,symbol,rhs))
        }
        
    public func unary(_ symbol:Token.Symbol) -> Expression
        {
        return(UnaryExpression(symbol, self))
        }
        
    public func index(_ index:Expression) -> Expression
        {
        return(ArrayAccessExpression(array:self,index:index))
        }
        
    public func assign(_ index:Expression) -> Expression
        {
        return(AssignmentExpression(self,index))
        }
        
    public func emitCode(into instance: MethodInstance,using: CodeGenerator)
        {
        }
        
    public func realize(_ compiler:Compiler)
        {
        }
        
    public var resultType: TypeResult
        {
        .undefined
        }
        
    public func generateConstraints(into inferencer:TypeInferencer)
        {
        fatalError("This should have been overridden")
        }
        
    public var valueLocation: Instruction.Operand = .none
    }
    

public typealias Expressions = Array<Expression>
