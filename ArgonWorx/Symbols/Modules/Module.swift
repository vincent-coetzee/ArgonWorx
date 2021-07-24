//
//  Module.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation
import AppKit
import SwiftUI

struct ModuleMenuView: View
    {
    var binding: Binding<String>
    
    var body: some View
        {
        HStack
            {
            Text("New Module name:")
            TextField("",text: binding)
            }
            .frame(maxWidth: 500,maxHeight:60)
            .border(Color.white)
        }
    }
    
struct ModuleButtonView: View
    {
    var binding: Binding<String?>
    
    var body: some View
        {
        HStack
            {
            Spacer()
            Button(action: {binding.wrappedValue = "module"})
                {
                Image(systemName:"plus.app").renderingMode(.template).foregroundColor(NSColor.argonNeonOrange.swiftUIColor).font(.title2)
                    
                }
                .frame(alignment:.trailing)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
public class Module:ContainerSymbol
    {
    public var classes:Classes
        {
        var classes = Array(self.symbols.values.compactMap{$0 as? Class})
        classes += self.symbols.values.compactMap{($0 as? Module)?.classes}.flatMap{$0}
        return(classes)
        }
        
    public var isSystemModule: Bool
        {
        return(false)
        }
        
    public override func newItemButton(_ binding:Binding<String?>) -> AnyView
        {
        return(AnyView(ModuleButtonView(binding: binding)))
        }
        
    public override func newItemView(_ binding:Binding<String>) -> AnyView
        {
        return(AnyView(ModuleMenuView(binding: binding)))
        }
        
    public override var imageName: String
        {
        "IconTest"
        }
        
    public override var symbolColor: NSColor
        {
        .argonNeonOrange
        }
        
    public override func visit(_ visitor:ParseTreeVisitor) throws
        {
        try visitor.start(self)
        for symbol in self.symbols.values
            {
            try symbol.visit(visitor)
            }
        try visitor.finish(self)
        }
        
    public override var weight: Int
        {
        10_000
        }
        
    public override func directlyContains(symbol:Symbol) -> Bool
        {
        for aSymbol in self.symbols.values
            {
            if aSymbol.id == symbol.id
                {
                return(true)
                }
            }
        return(false)
        }
        
    internal func layout()
        {
        self.layoutSlots()
        self.layoutInMemory(segment: ManagedSegment.shared)
        }
        
    internal func layoutSlots()
        {
        for aClass in self.symbols.values.compactMap({$0 as? Class})
            {
            aClass.layoutObjectSlots()
            }
        for module in self.symbols.values.compactMap({$0 as? Module})
            {
            module.layoutSlots()
            }
        }
    }

public typealias Modules = Array<Module>
