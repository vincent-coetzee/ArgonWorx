//
//  Function.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Function:Symbol
    {
    internal var cName: String
    internal var parameters: Parameters
    public var returnType: Type = VoidClass.voidClass.type
    
    override init(label:Label)
        {
        self.cName = ""
        self.parameters = Parameters()
        super.init(label: label)
        }
    }
