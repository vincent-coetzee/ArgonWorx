//
//  Optional+Extensions.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 12/7/21.
//

import Foundation

extension Optional
    {
    public var isNotNil: Bool
        {
        switch(self)
            {
            case .some:
                return(true)
            case .none:
                return(false)
            }
        }
        
    public var isNil: Bool
        {
        switch(self)
            {
            case .some:
                return(false)
            case .none:
                return(true)
            }
        }
        
    public func sizeInBits() -> Int where Wrapped == Instruction.Operand
        {
        switch(self)
            {
            case .some(let some):
                return(some.sizeInBits)
            case .none:
                return(0)
            }
        }
    }
