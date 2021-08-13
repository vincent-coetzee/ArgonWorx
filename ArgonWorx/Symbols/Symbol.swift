//
//  Symbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
import SwiftUI

public class Symbol:Node,ParseNode
    {
        
    public func newItemButton(_ binding:Binding<String?>) -> AnyView
        {
        return(AnyView(EmptyView()))
        }
        
    public func newItemView(_ binding:Binding<String>) -> AnyView
        {
        return(AnyView(EmptyView()))
        }
        
    public var displayName: String
        {
        self.label
        }
        
    public var description: String
        {
        return("\(Swift.type(of:self))(\(self.label))")
        }
        
    public var imageName: String
        {
        "IconEmpty"
        }
        
    public var symbolColor: NSColor
        {
        .black
        }
        
    public var symbolType: SymbolType
        {
        .none
        }    
    
    public var typeCode:TypeCode
        {
        fatalError("TypeCode being called on Symbol which is not valid")
        }
        
    public var children:Symbols?
        {
        return(nil)
        }
        
    public var weight: Int
        {
        10
        }
        
    public func realizeSuperclasses()
        {
        }
        
   public func allocateAddresses(using: AddressAllocator)
        {
        }
        
    public func emitCode(using: CodeGenerator) throws
        {
        }
        
    public func emitCode(into: InstructionBuffer,using: CodeGenerator) throws
        {
        fatalError("Should not have been called")
        }
        
    public func analyzeSemantics(using: SemanticAnalyzer)
        {
        }
        
    internal var memoryAddress: Word = 0
    internal var isMemoryLayoutDone: Bool = false
    internal var isSlotLayoutDone: Bool = false
    internal var locations: SourceLocations = SourceLocations()
    public var privacyScope:PrivacyScope? = nil
    
    public override init(label:Label)
        {
        super.init(label:label)
        }
    
    public var isGroup: Bool
        {
        return(false)
        }
        
    public func directlyContains(symbol:Symbol) -> Bool
        {
        return(false)
        }
        
    public func layoutInMemory(segment:ManagedSegment)
        {
        self.isMemoryLayoutDone = true
        }
        
    public func addDeclaration(_ location:Location)
        {
        self.locations.append(.declaration(location))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
    }

public typealias SymbolDictionary = Dictionary<Label,Symbol>
public typealias Symbols = Array<Symbol>
