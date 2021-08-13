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
        
    public override var resultType: TypeResult
        {
        return(self.rhs.resultType)
        }

    public override func realize(using realizer:Realizer)
        {
        self.lhs.realize(using: realizer)
        self.rhs.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.lhs.emitCode(into: instance,using: generator)
        try self.rhs.emitCode(into: instance,using: generator)
        instance.append(.store,self.lhs.place,.none,rhs.place)
        self._place = rhs.place
        }
    }
