//
//  Enumeration.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 4/10/21.
//

import Foundation

public class Enumeration:Symbol
    {
    public var cases: EnumerationCases = []
    public var rawType: Class?
    
    public override var typeCode:TypeCode
        {
        .enumeration
        }
        
    public override init(label:Label)
        {
        self.rawType = ArgonModule.argonModule.integer
        super.init(label: label)
        }
        
    public override func layoutInMemory(segment:ManagedSegment)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        let pointer = InnerEnumerationPointer.allocate(in: segment)
        pointer.setSlotValue(InnerStringPointer.allocateString(self.label, in: segment).address,atKey:"name")
        pointer.setSlotValue(rawType?.memoryAddress ?? 0,atKey:"valueType")
        let casesPointer = InnerArrayPointer.allocate(arraySize: self.cases.count, in: segment)
        pointer.casesPointer = casesPointer
        var rawValueIndex = 0
        for aCase in self.cases
            {
            let casePointer = InnerEnumerationCasePointer.allocate(in: segment)
            casesPointer.append(casePointer.address)
            casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.symbol, in: segment).address,atKey:"symbol")
            casePointer.setSlotValue(pointer.address,atKey:"enumeration")
            casePointer.setSlotValue(aCase.caseSizeInBytes,atKey:"caseSizeInBytes")
            casePointer.setSlotValue(rawValueIndex,atKey:"index")
            if aCase.rawValue.isNil
                {
                casePointer.setSlotValue(0,atKey:"rawValue")
                }
            else
                {
                if aCase.rawValue!.isStringLiteral
                    {
                    casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.rawValue!.stringLiteral, in: segment).address,atKey:"rawValue")
                    }
                else if aCase.rawValue!.isSymbolLiteral
                    {
                    casePointer.setSlotValue(InnerStringPointer.allocateString(aCase.rawValue!.symbolLiteral, in: segment).address,atKey:"rawValue")
                    }
                else if aCase.rawValue!.isIntegerLiteral
                    {
                    casePointer.setSlotValue(Word(bitPattern: aCase.rawValue!.integerLiteral),atKey:"rawValue")
                    }
                }
            if aCase.types.count > 0
                {
                let arrayPointer = InnerArrayPointer.allocate(arraySize: aCase.types.count, in: segment)
                casePointer.associatedTypesPointer = arrayPointer
                for aType in aCase.types
                    {
                    arrayPointer.append(aType.memoryAddress)
                    }
                }
            rawValueIndex += 1
            }
        print("LAID OUT ENUMERATION \(self.label) AT ADDRESS \(self.memoryAddress.addressString)")
        }
    }
