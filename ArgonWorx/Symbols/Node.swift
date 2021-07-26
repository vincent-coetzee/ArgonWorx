//
//  Node.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import SwiftUI

public class Node:NSObject,NamingContext,ParseTreeNode,Identifiable
    {
    public let id: UUID
    public let label: String
    public private(set) var parent:Node? = nil
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
        
    public var type: Type
        {
        fatalError("This should have been implemented in a class")
        }
        
    public var name: Name
        {
        return((self.parent?.name ?? Name()) + self.label)
        }
        
    public static func ==(lhs:Node,rhs:Node) -> Bool
        {
        return(lhs.id == rhs.id)
        }
        
    ///
    /// Primary initializer for everything
    ///
    init(label:String)
        {
        self.label = label
        self.id = UUID()
        super.init()
        }
        
    ///
    /// Support for encoding and decoding with an NSArchiver
    ///
    init?(coder:NSCoder)
        {
        self.label = coder.decodeObject(forKey:"label") as! String
        self.id = coder.decodeObject(forKey:"id") as! UUID
        super.init()
        }
        
    public func encode(with coder:NSCoder)
        {
        coder.encode(self.label,forKey:"label")
        coder.encode(self.id,forKey:"id")
        }

    public func setParent(_ node: Node)
        {
        self.parent = node
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
