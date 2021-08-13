//
//  EnumerationCase.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class EnumerationCase:Symbol
    {
    public override var typeCode:TypeCode
        {
        .enumerationCase
        }
        
    public let types: Classes
    public let symbol: Argon.Symbol
    public var rawValue: LiteralExpression?
    public var caseSizeInBytes:Int = 0
    
    init(symbol: Argon.Symbol,types: Classes)
        {
        self.symbol = symbol
        self.types = types
        super.init(label: symbol)
        self.calculateSizeInBytes()
        }
        
    private func calculateSizeInBytes()
        {
        let size = ArgonModule.argonModule.enumerationCase.localAndInheritedSlots.count * MemoryLayout<Word>.size
        let typesSize = self.types.count * MemoryLayout<Word>.size
        self.caseSizeInBytes = size + typesSize + MemoryLayout<Word>.size * 4
        }
    }
    
public typealias EnumerationCases = Array<EnumerationCase>
