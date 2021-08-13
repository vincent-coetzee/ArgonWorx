//
//  SystemMethodInstance.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 18/7/21.
//

import Foundation

public class SystemMethodInstance:MethodInstance
    {
    public override var isSystemMethodInstance: Bool
        {
        return(true)
        }
    }

public class IntrinsicMethodInstance: SystemMethodInstance
    {
    }

public class LibraryMethodInstance: SystemMethodInstance
    {
    public var rawFunctionName: String
        {
        var name = "M"
        let names = self.parameters.map{$0.type.mangledCode}.joined(separator: "P")
        name += "P" + names
        name += self.returnType.mangledCode
        return(name)
        }
    }
    
