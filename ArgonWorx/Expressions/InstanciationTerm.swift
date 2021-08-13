//
//  InstanciationTerm.swift
//  InstanciationTerm
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class InstanciationTerm: Expression
    {
    private let theClass:Class
    
    init(class:Class)
        {
        self.theClass = `class`
        }
        
    public override var resultType: TypeResult
        {
        return(.class(theClass))
        }
        
    public override func realize(using realizer: Realizer)
        {
        self.theClass.realize(using: realizer)
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)MAKE EXPRESSION()")
        print("\(padding)\t \(self.theClass.label)")
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        let outputRegister = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
        instance.append(.make,.address(theClass.memoryAddress),.integer(0),.register(outputRegister))
        self._place = .register(outputRegister)
        }
    }
