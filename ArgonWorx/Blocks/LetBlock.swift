//
//  LetBlock.swift
//  LetBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class LetBlock: Block
    {
    private let name: Name
    private let value:Expression
    private let location:Location
    private let namingContext: NamingContext
    private let slot: Slot
    
    public init(name:Name,slot:Slot,location:Location,namingContext: NamingContext,value:Expression)
        {
        self.slot = slot
        self.name = name
        self.value = value
        self.location = location
        self.namingContext = namingContext
        }
        
    public override func analyzeSemantics(_ compiler:Compiler)
        {
        let valueType = self.value.findType()
        let slotType = slot.type
        if valueType.isNotNil
            {
            if !valueType!.isSubclass(of: slotType)
                {
                compiler.reportingContext.dispatchError(at: self.location, message: "An instance of class \(valueType) can not be assigned to an instance of \(slotType).")
                }
            }
        }
        
    public override func emitCode(into: MethodInstance,using: CodeGenerator)
        {
        }
    }
