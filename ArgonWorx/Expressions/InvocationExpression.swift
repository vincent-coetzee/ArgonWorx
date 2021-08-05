//
//  InvocationExpression.swift
//  InvocationExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InvocationExpression: Expression
    {
    private let name: Name
    private let namingContext: NamingContext
    private let reportingContext: ReportingContext
    private let arguments: Arguments
    
    init(name:Name,arguments:Arguments,namingContext:NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.arguments = arguments
        self.namingContext = namingContext
        self.reportingContext = reportingContext
        }
    }
