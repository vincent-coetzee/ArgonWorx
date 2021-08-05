//
//  SlotAccessExpression.swift
//  SlotAccessExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class SlotReadExpression: Expression
    {
    private let name:Name
    private let namingContext: NamingContext
    private let reportingContext: ReportingContext
    
    init(name:Name,namingContext:NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.namingContext = namingContext
        self.reportingContext = reportingContext
        }
    }
