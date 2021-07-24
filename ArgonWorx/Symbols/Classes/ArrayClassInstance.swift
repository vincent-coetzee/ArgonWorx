//
//  ArrayClassInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import Foundation

public class ArrayClassInstance: ParameterizedSystemClassInstance
    {
    public override var displayName: String
        {
        "Array<\(self.concreteTypes[0].displayName)>"
        }
    }
