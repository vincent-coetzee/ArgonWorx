//
//  Argument.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public struct Argument
    {
    public let tag:String?
    public let value:Expression
    }

public typealias Arguments = Array<Argument>

extension Arguments
    {
    public var resultTypes: Array<TypeResult>
        {
        return(self.map{$0.value.resultType})
        }
    }

public typealias TypeResults = Array<TypeResult>

extension TypeResults
    {
    public var isMisMatched: Bool
        {
        for result in self
            {
            switch(result)
                {
                case .undefined:
                    return(true)
                case .mismatch:
                    return(true)
                default:
                    break
                }
            }
        return(false)
        }
    }
