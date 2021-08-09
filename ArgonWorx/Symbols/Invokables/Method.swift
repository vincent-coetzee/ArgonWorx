//
//  Method.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import AppKit

public class Method:Symbol
    {
    public override func emitCode(using generator: CodeGenerator)
        {
        for instance in self.instances
            {
            instance.emitCode(using: generator)
            }
        }
        
    public var isSystemMethod: Bool
        {
        return(false)
        }
        
    public var isMain: Bool = false
    
    public private(set) var instances = MethodInstances()
    
    public class func method(label:String) -> Method
        {
        return(Method(label:label))
        }
        
    public override var imageName: String
        {
        "IconMethod"
        }
        
    public override var symbolColor: NSColor
        {
        .argonPink
        }
        
    public override func realize(_ compiler:Compiler)
        {
        for instance in self.instances
            {
            instance.realize(compiler)
            }
        }
        
    public override func emitCode(into: ParseNode,using: CodeGenerator)
        {
        for instance in self.instances
            {
            instance.emitCode(into: instance,using: using)
            }
        }
        
    public func instance(_ types:Class...,returnType:Class = VoidClass.voidClass) -> Method
        {
        let instance = MethodInstance(label: self.label)
        var parameters = Parameters()
        var index = 0
        for type in types
            {
            parameters.append(Parameter(label: "_\(index)",type:type))
            index += 1
            }
        instance.parameters = parameters
        instance.returnType = returnType
        self.addInstance(instance)
        return(self)
        }
        
    public func addInstance(_ instance:MethodInstance)
        {
        self.instances.append(instance)
        }
    }

public typealias Methods = Array<Method>
