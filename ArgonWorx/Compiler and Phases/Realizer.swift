//
//  Realizer.swift
//  Realizer
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public struct Realizer
    {
    private let compiler:Compiler
    
    public static func realize(_ parseNode:ParseNode,in compiler:Compiler)
        {
        Realizer(compiler: compiler).realize(parseNode)
        }
        
    init(compiler: Compiler)
        {
        self.compiler = compiler
        }
        
    private func realize(_ parseNode:ParseNode)
        {
        for node in parseNode.subNodes!
            {
            node.realize(self.compiler)
            }
        for node in parseNode.subNodes!
            {
            node.realizeSuperclasses()
            }
        }
    }
