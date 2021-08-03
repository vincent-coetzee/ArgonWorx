//
//  SymbolHolderType.swift
//  SymbolHolderType
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class SymbolHolderType: Type
    {
    private let symbolHolder:SymbolHolder
    
    init(symbolHolder:SymbolHolder)
        {
        self.symbolHolder = symbolHolder
        super.init(label: symbolHolder.label)
        }
    }
