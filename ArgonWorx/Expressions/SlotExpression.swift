//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 13/8/21.
//

import Foundation

public class SlotExpression: Expression
    {
    private let receiver: Expression
    private let slot: Expression
    
    init(_ receiver: Expression,slot: Expression)
        {
        self.receiver = receiver
        self.slot = slot
        }
        
    public override var resultType: TypeResult
        {
        let receiverType = self.receiver.resultType
        if let aClass = receiverType.class,let identifier = (self.slot as? SlotSelectorExpression)?.selector,let aSlot = aClass.layoutSlot(atLabel: identifier)
            {
            return(.class(aSlot.type))
            }
        return(.undefined)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        let selector = (self.slot as! SlotSelectorExpression).selector
        if self.receiver.lookupSlot(selector: selector).isNil
            {
            analyzer.compiler.reportingContext.dispatchError(at: self.declaration, message: "Slot '\(selector)' was not found on the receiver, unable to resolve the slot.")
            }
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.receiver.realize(using: realizer)
        self.slot.realize(using: realizer)
        }
        
    public override func emitCode(into instance: InstructionBuffer,using generator: CodeGenerator) throws
        {
        if let slot = self.receiver.lookupSlot(selector: (self.slot as! SlotSelectorExpression).selector)
            {
            try self.receiver.emitCode(into: instance,using: generator)
            let register = generator.registerFile.findRegister(forSlot: nil, inBuffer: instance)
            instance.append(.load,self.receiver.place,.none,.register(register))
            instance.append(.iadd,.register(register),.integer(Argon.Integer(slot.offset)),.register(register))
            self._place = .register(register)
            }
        }
    }

public class SlotSelectorExpression: Expression
    {
    public let selector: String
    
    init(selector: String)
        {
        self.selector = selector
        }
    }
