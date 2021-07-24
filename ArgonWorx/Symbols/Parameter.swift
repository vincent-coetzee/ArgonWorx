//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Symbol
    {
    private let _type:Type
    
    init(label:Label,type:Type)
        {
        self._type = type
        super.init(label: label)
        }
    }

public typealias Parameters = Array<Parameter>
