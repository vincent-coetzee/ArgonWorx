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
        
    public var tag: Label
        {
        return(self.label)
        }
        
    private let _type:Class
    public let isHidden:Bool
    public let isVariadic: Bool
    
    init(label:Label,type:Class,isHidden:Bool = false,isVariadic:Bool = false)
        {
        self.isHidden = isHidden
        self._type = type
        self.isVariadic = isVariadic
        super.init(label: label)
        }
    }

public typealias Parameters = Array<Parameter>

