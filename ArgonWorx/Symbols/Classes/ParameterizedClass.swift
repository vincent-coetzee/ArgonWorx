//
//  ParameterizedClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class ParameterizedClass:Class
    {
    public override var typeCode:TypeCode
        {
        _typeCode
        }
        
//    private var parameters = TypeParameters()
    private let _typeCode:TypeCode
    
    init(label:Label,superclasses:Array<Label>,parameters:Array<Label>,typeCode:TypeCode = .other)
        {
        self._typeCode = typeCode
        super.init(label:label)
//        self.parameters = parameters.map{TypeParameter(label:$0)}
        self.superclassHolders = superclasses.map{SymbolHolder(name:Name($0),location:.zero,namingContext:nil,reporter:NullReportingContext.shared)}
        }
        
        
   public func of(_ type:Class) -> ParameterizedClassInstance
        {
        let instance = ParameterizedClassInstance(label: Argon.nextName("_PARAMCLASS"), sourceClass: self, types: [type.type])
        return(instance)
        }
    }
