//
//  ForwardingSymbol.swift
//  ForwardingSymbol
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class ForwardingSymbol: Symbol
    {
    public override func addSymbol(_ symbol:Symbol)
        {
        self.parent?.addSymbol(symbol)
        }
    }
