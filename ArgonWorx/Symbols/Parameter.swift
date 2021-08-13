//
//  Parameter.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class Parameter:Slot
    {
    public override var typeCode:TypeCode
        {
        .parameter
        }
        
    public var tag: Label
        {
        return(self.label)
        }
        
    public let isVisible:Bool
    public let isVariadic: Bool
    
    init(label:Label,type:Class,isVisible:Bool = false,isVariadic:Bool = false)
        {
        self.isVisible = isVisible
        self.isVariadic = isVariadic
        super.init(label: label,type: type)
        }
    
    required init(labeled: Label, ofType: Class) {
        fatalError("init(labeled:ofType:) has not been implemented")
    }
}

public typealias Parameters = Array<Parameter>
