//
//  ParameterizedClassInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class ParameterizedClassInstance:Class
    {
    internal let concreteTypes:Classes
    private let sourceClass:ParameterizedClass
    
    init(label:Label,sourceClass:ParameterizedClass,types:Classes)
        {
        self.sourceClass = sourceClass
        self.concreteTypes = types
        super.init(label:label)
        }
    }
