//
//  SystemModule.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 13/7/21.
//

import Foundation

public class SystemModule: Module
    {
    public override var typeCode:TypeCode
        {
        .systemModule
        }
        
    public override var isSystemModule: Bool
        {
        return(true)
        }
        
    public var subModules: Modules
        {
        return(self.symbols.values.compactMap{$0 as? Module})
        }
        
    public override func lookup(label: Label) -> Symbol?
        {
        if let value = self.symbols[label]
            {
            return(value)
            }
        for module in self.subModules
            {
            if let value = module.lookup(label: label)
                {
                return(value)
                }
            }
        return(nil)
        }
        
    internal override func layout()
        {
        self.layoutSlots()
        for aModule in self.symbols.values.compactMap({$0 as? SystemModule})
            {
            aModule.layout()
            }
        self.layoutInMemory(segment: ManagedSegment.shared)
        }
        
    internal func resolveReferences()
        {
        for symbol in self.symbols.values
            {
            if let aClass = symbol as? Class
                {
                aClass.realizeSuperclasses()
                }
            else if let aModule = symbol as? SystemModule
                {
                aModule.resolveReferences()
                }
            }
        }
    }
