//
//  NamingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public protocol NamingContext
    {
    var primaryContext: NamingContext { get }
    func lookup(name:Name) -> Symbol?
    func lookup(label:Label) -> Symbol?
    func addSymbol(_ symbol:Symbol)
    }
