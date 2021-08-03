//
//  Transformer.swift
//  Transformer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class Interceptor: Symbol
    {
    private let parameters:Parameters
    
    init(label:String,parameters:Parameters)
        {
        self.parameters = parameters
        super.init(label: label)
        }
    }
