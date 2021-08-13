//
//  NamingContext.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public protocol NamingContext
    {
    var index: UUID { get }
    var primaryContext: NamingContext { get }
    var parent: NamingContext! { get }
    func setParent(_ context:NamingContext?)
    func lookup(name:Name) -> Symbol?
    func lookup(label:Label) -> Symbol?
    func addSymbol(_ symbol:Symbol)
    }
