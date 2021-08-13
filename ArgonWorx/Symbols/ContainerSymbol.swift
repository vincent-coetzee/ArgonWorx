//
//  ContainerSymbol.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class ContainerSymbol:Symbol
    {
    public override var isGroup: Bool
        {
        return(true)
        }
        
    internal var symbols = SymbolDictionary()
    
    public override var children: Symbols?
        {
        if self.symbols.isEmpty
            {
            return(nil)
            }
        var visibleSymbols = Symbols()
        let allSymbols = self.symbols.values + ((self as? Class).isNotNil ? (self as! Class).subclasses : [])
        for symbol in allSymbols
            {
            if !(symbol is Class)
                {
                visibleSymbols.append(symbol)
                }
            }
        visibleSymbols += self.classesWithNotDirectlyContainedSuperclasses
        visibleSymbols = visibleSymbols.sorted{$0.label<$1.label}
        return(Array(visibleSymbols))
        }
        
    public var classesWithNotDirectlyContainedSuperclasses:Classes
        {
        var classes = self.symbols.values.filter{$0 is Class}.map{$0 as! Class}
        classes = classes.filter{$0.superclasses.isEmpty}
        for aClass in self.symbols.values.filter({$0 is Class}).map({$0 as! Class})
            {
            for superclass in aClass.superclasses
                {
                if !self.directlyContains(symbol: superclass)
                    {
                    classes.append(aClass)
                    }
                }
            }
        return(classes)
        }
        
    ///
    ///
    /// Support for naming context
    ///
    ///
    public override func lookup(label:String) -> Symbol?
        {
        for symbol in self.symbols.values
            {
            if symbol.label == label
                {
                return(symbol)
                }
            }
        return(nil)
        }
        
    public override func analyzeSemantics(using analyzer:SemanticAnalyzer)
        {
        for node in self.symbols.values
            {
            node.analyzeSemantics(using: analyzer)
            }
        }
        
    public override func realize(using realizer: Realizer)
        {
        for child in self.symbols.values
            {
            if child is MethodInstance
                {
                print("junk")
                }
            child.realize(using: realizer)
            }
        }
        
    public override func emitCode(using generator: CodeGenerator) throws
        {
        for symbol in self.symbols.values
            {
            try symbol.emitCode(using: generator)
            }
        }
        
    public override func realizeSuperclasses()
        {
        for element in self.symbols.values
            {
            element.realizeSuperclasses()
            }
        }
        
    public override func addSymbol(_ symbol:Symbol)
        {
        self.symbols[symbol.label] = symbol
        symbol.setParent(self)
        }
        
    public func addSymbols(_ symbols:Array<Symbol>) -> ContainerSymbol
        {
        for symbol in symbols
            {
            self.addSymbol(symbol)
            }
        return(self)
        }
    }
