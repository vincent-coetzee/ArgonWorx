//
//  SymbolHolderType.swift
//  SymbolHolderType
//
//  Created by Vincent Coetzee on 3/8/21.
//

import Foundation

public class SymbolHolderType: Class
    {
    private let symbolHolder:SymbolHolder
    
    init(symbolHolder:SymbolHolder)
        {
        self.symbolHolder = symbolHolder
        super.init(label: symbolHolder.label)
        }
        
    public override func realize(_ compiler:Compiler)
        {
        self.symbolHolder.reify()
        }
    }
