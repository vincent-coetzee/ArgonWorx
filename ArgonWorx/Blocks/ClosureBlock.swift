//
//  ClosureBlock.swift
//  ClosureBlock
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class ClosureBlock: Block
    {
    public var parameters = Parameters()
    public var resultType:Class = VoidClass.voidClass
    
    public func addParameter(label:String,type: Class)
        {
        let parameter = Parameter(label: label,type: type)
        self.parameters.append(parameter)
        }
    }
