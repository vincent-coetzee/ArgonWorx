//
//  TypeAlias.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class TypeAlias:Symbol
    {
    public override func emitCode(using: CodeGenerator)
        {
        }
        
    private let _type:Class
    
    init(label:Label,type:Class)
        {
        self._type = type
        super.init(label: label)
        }
        
    public override var typeCode:TypeCode
        {
        .typeAlias
        }
    }
