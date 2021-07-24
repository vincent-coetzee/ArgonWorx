//
//  Compiler.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct Compiler
    {
    public var reportingContext:ReportingContext
        {
        return(NullReportingContext.shared)
        }
    }
