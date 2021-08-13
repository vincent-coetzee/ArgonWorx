//
//  ReturnBlock.swift
//  ReturnBlock
//
//  Created by Vincent Coetzee on 8/8/21.
//

import Foundation

public class ReturnBlock: Block
    {
    public var value: Expression = Expression()
    
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        self.value.analyzeSemantics(using: analyzer)
        let returnValue = self.methodInstance.returnType
        let valueType = self.value.resultType
        if valueType.class.isNil
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.declaration, message: "The type of the returned value does not match with that defined on the method.")
            }
        else if !valueType.class!.isInclusiveSubclass(of: returnValue)
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.declaration, message: "The type of the return expression \(valueType.class!.label) does not match that of the method \(returnValue)")
            }
        }
        
    public override func emitCode(into buffer: InstructionBuffer,using generator: CodeGenerator) throws
        {
        try self.value.emitCode(into: buffer,using: generator)
        buffer.append(.store,self.value.place,.none,.register(.ret))
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)RETURN BLOCK")
        self.value.dump(depth: depth+1)
        }
    }
