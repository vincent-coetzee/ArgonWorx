//
//  Constant.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Constant:Symbol
    {
    private let _type: Class
    private let value: Expression
    
    init(label:Label,type:Class,value:Expression)
        {
        self._type = type
        self.value = value
        super.init(label: label)
        }
        
    public override var typeCode:TypeCode
        {
        .constant
        }
    }
