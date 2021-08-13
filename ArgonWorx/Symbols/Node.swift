//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI

protocol FuckSwift
    {
    init(upYours:Int)
    }

public class Node:NamingContext,ParseTreeNode,Identifiable
    {
    public let index: UUID
    public let label: String
    public private(set) var parent:NamingContext! = nil
    
    private var locations = NodeLocations()
    
    public var declarationLocation: Location
        {
        get
            {
            locations.declarationLocation
            }
        set
            {
            locations.append(.declaration(newValue))
            }
        }
        
    public var type: Class
        {
        fatalError("This should have been implemented in a class")
        }
        
    public init(label: String)
        {
        self.index = UUID()
        self.label = label
        }
        
    public var name: Name
        {
        return(((self.parent as? Node)?.name ?? Name()) + self.label)
        }
        
    public static func ==(lhs:Node,rhs:Node) -> Bool
        {
        return(lhs.id == rhs.id)
        }

    public func setParent(_ node: NamingContext?)
        {
        self.parent = node
        }
        
    public func realize(using realizer:Realizer)
        {
        }
        
    public func visit(_ visitor:ParseTreeVisitor) throws
        {
        }
        
    ///
    /// Support for being a NamingContext
    ///
    ///
    public var primaryContext: NamingContext
        {
        return(TopModule.topModule)
        }
        
    public func lookup(name:Name) -> Symbol?
        {
        if name.isEmpty
            {
            return(nil)
            }
        if name.isRooted
            {
            if let context = self.primaryContext.lookup(label: name.first)
                {
                return(context.lookup(name: name.withoutFirst))
                }
            return(nil)
            }
        if let context = self.lookup(label: name.first),let symbol = context.lookup(name: name.withoutFirst)
            {
            return(symbol)
            }
        if name.count == 1,let symbol = self.lookup(label: name.first)
            {
            return(symbol)
            }
        return(self.parent?.lookup(name:name))
        }
        
    public func lookup(label: Label) -> Symbol?
        {
        return(nil)
        }
        
    public func addSymbol(_ symbol:Symbol)
        {
        fatalError("Attempt to addSymbol to a \(Swift.type(of:self))")
        }
    }
