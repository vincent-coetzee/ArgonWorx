//
//  EnumerationCaseInstance.swift
//  EnumerationCaseInstance
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class EnumerationCaseInstance: Symbol
    {
    private let enumerationCase: EnumerationCase
    private let enumeration: Enumeration
    private var associatedTypes: Types
    private var index: Int
    
    init(label:Label,enumerationCase: EnumerationCase,enumeration: Enumeration,associatedTypes: Types,index: Int)
        {
        self.enumerationCase = enumerationCase
        self.enumeration = enumeration
        self.associatedTypes = associatedTypes
        self.index = index
        super.init(label: label)
        }
    }
