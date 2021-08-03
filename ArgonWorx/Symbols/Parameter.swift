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
    private let isHidden:Bool
    
    init(label:Label,type:Type,isHidden:Bool = false)
        {
        self.isHidden = isHidden
        self._type = type
        super.init(label: label)
        }
    }

public typealias Parameters = Array<Parameter>
