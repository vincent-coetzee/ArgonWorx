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
    }
    
public typealias EnumerationCases = Array<EnumerationCase>
