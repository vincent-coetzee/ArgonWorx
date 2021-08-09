//
//  Metaclass.swift
//  Metaclass
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class Metaclass: Class
    {
    public override var displayName: String
        {
        return("\(self.label) class")
        }
        
    private let theClass: Class
    
    public init(label:Label,class:Class)
        {
        self.theClass = `class`
        super.init(label: label)
        }
    }
