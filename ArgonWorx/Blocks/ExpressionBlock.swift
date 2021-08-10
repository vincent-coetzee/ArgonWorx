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
    public var valueLocation: Instruction.Operand = .none
    init(_ expression:Expression)
        {
        self.expression = expression
        super.init()
        }
        
    public override func realize(_ compiler:Compiler)
        {
        super.realize(compiler)
        self.expression.realize(compiler)
        }
        
    public override func analyzeSemantics(_ compiler:Compiler)
        {
        super.analyzeSemantics(compiler)
        let type = self.expression.resultType
        }
        
    public override func emitCode(into: MethodInstance,using: CodeGenerator)
        {
        self.expression.emitCode(into: into,using: using)
        self.valueLocation = self.expression.valueLocation
        }
    }
