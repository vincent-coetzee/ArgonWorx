//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class LocalReadExpression: Expression
    {
    public let name:Name
    private let namingContext: NamingContext
    private let reportingContext: ReportingContext
    private let location: Location
    private var slot:Slot?
    
    init(name:Name,location:Location,namingContext:NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.namingContext = namingContext
        self.reportingContext = reportingContext
        }
        
    public override func realize(_ compiler:Compiler)
        {
        slot = self.namingContext.lookup(name: self.name) as? Slot
        if slot.isNil
            {
            self.reportingContext.dispatchError(at: self.location, message: "Could not resolve SLOT named \(self.name).")
            }
        }
        
    public override func findType() -> Class?
        {
        self.annotatedType = self.slot?.type
        return(self.annotatedType)
        }
    }
