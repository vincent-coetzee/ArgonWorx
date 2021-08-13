//
//  ValueExpression.swift
//  ValueExpression
//
//  Created by Vincent Coetzee on 11/8/21.
//

import Foundation

public class LocalAccessExpression: Expression
    {
    public var localSlot: Slot
        {
        return(self.symbol as! Slot)
        }
        
    internal let name: Name
    private let location: Location
    private let context: NamingContext
    private let reportingContext: ReportingContext
    private var symbol: Symbol?
    
    init(name: Name,location: Location,context: NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.context = context
        self.reportingContext = reportingContext
        }
        
    public override func realize(using realizer:Realizer)
        {
        self.symbol = self.context.lookup(name: self.name)
        if symbol.isNil
            {
            self.reportingContext.dispatchError(at: self.location, message: "The name '\(name)' can not be resolve into a symbol.")
            }
        }
        
    public override func lookupSlot(selector: String) -> Slot?
        {
        if symbol.isNotNil && (symbol is Module || symbol is Class || symbol is Slot)
            {
            if symbol is Module
                {
                return((symbol as! Module).lookup(label: selector) as? Slot)
                }
            else if symbol is Metaclass
                {
                return((symbol as! Metaclass).lookup(label: selector) as? Slot)
                }
            else
                {
                return((symbol as! Slot).lookup(label: selector) as? Slot)
                }
            }
        return(nil)
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator)
        {
        if symbol.isNil
            {
            return
            }
        if symbol is LocalSlot
            {
            let slot = symbol as! LocalSlot
            self._place = .stack(.bp,Argon.Integer(slot.stackOffset))
            }
        if symbol is Parameter
            {
            let parameter = symbol as! Parameter
            self._place = .stack(.bp,Argon.Integer(parameter.stackOffset))
            }
        if symbol is Class
            {
            self._place = .address(symbol!.memoryAddress)
            }
        }
    }
