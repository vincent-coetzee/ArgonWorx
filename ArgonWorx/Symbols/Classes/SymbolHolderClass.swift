//
//  SymbolHolderType.swift
//  SymbolHolderType
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class SymbolHolderClass: Class
    {
    private let symbolHolder:SymbolHolder
    
    init(symbolHolder:SymbolHolder)
        {
        self.symbolHolder = symbolHolder
        super.init(label: symbolHolder.label)
        }
    
    public override func realize(using realizer: Realizer)
        {
        self.symbolHolder.reify()
        }
    }
