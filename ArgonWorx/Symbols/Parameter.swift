//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Symbol
    {
    public override var typeCode:TypeCode
        {
        .parameter
        }
        
    public override var type: Class
        {
        return(self._type)
        }
        
    private let _type:Class
    private let isHidden:Bool
    
    init(label:Label,type:Class,isHidden:Bool = false)
        {
        self.isHidden = isHidden
        self._type = type
        super.init(label: label)
        }
    }

public typealias Parameters = Array<Parameter>
