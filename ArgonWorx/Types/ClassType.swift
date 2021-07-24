//
//  ClassType.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class ClassType:Type
    {
    public override var displayName: String
        {
        self.clazz.displayName
        }
        
    public override var isArrayType: Bool
        {
        return(self.clazz.isArrayClass)
        }
        
    public override var isStringType: Bool
        {
        return(self.clazz.isStringClass)
        }
        
    private let clazz:Class
    
    public init(`class`:Class)
        {
        self.clazz = `class`
        super.init(label:`class`.label)
        }
    }
