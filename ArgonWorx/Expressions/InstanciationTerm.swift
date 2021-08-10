//
//  InstanciationTerm.swift
//  InstanciationTerm
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class InstanciationTerm: Expression
    {
    private let theClass:Class
    
    init(class:Class)
        {
        self.theClass = `class`
        }
        
    public override var resultType: TypeResult
        {
        return(.class(theClass))
        }
    }
