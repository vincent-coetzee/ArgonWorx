//
//  ValueExpression.swift
//  ValueExpression
//
//  Created by Vincent Coetzee on 11/8/21.
//

import Foundation

public class NameExpression: Expression
    {
    private let name: Name
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
        
    public override func realize(_ compiler:Compiler)
        {
        self.symbol = self.context.lookup(name: self.name)
        if symbol.isNil
            {
            self.reportingContext.dispatchError(at: self.location, message: "The name '\(name)' can not be resolve into a symbol.")
            }
        }
    }
