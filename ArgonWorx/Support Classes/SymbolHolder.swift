//
//  SymbolHolder.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 16/7/21.
//

import Foundation

public class SymbolHolder
    {
    private static var list:Array<SymbolHolder> = []
    
    private let name:Name
    private let context:NamingContext?
    private let reporter:ReportingContext
    private let location:Location
    private var symbol: Symbol?
    
    init(name:Name,location:Location,namingContext:NamingContext?,reporter:ReportingContext)
        {
        self.name = name
        self.context = namingContext
        self.reporter = reporter
        self.location = location
        Self.list.append(self)
        }
        
    @discardableResult
    public func reify() -> Symbol?
        {
        let theContext = context.isNil ? ArgonModule.argonModule : context!
        if let theSymbol = theContext.lookup(name: name)
            {
            self.symbol = theSymbol
            return(self.symbol!)
            }
        reporter.dispatchError(at: self.location,message: "Could not resolve symbol with reference \(self.name), unresolved reference.")
        return(nil)
        }
    }

public typealias SymbolHolders = Array<SymbolHolder>
