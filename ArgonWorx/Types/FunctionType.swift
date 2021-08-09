//
//  FunctionType.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 2/7/21.
//

import Foundation

public class FunctionType:Type
    {
    private let methodInstance:MethodInstance?
    private let function:Function?
    
    init(method:MethodInstance)
        {
        self.function = nil
        self.methodInstance = method
        super.init(label:method.label)
        }
        
    init(function:Function)
        {
        self.methodInstance = nil
        self.function = function
        super.init(label: function.label)
        }
        
    public var parameters: Parameters
        {
        var parameters:Parameters
        if self.function.isNotNil
            {
            parameters = self.function!.parameters
            }
        else
            {
            parameters = self.methodInstance!.parameters
            }
        parameters.append(self.function.isNotNil ? Parameter(label: "returnValue",type: self.function!.returnType) : Parameter(label: "returnValue",type: self.methodInstance!.returnType))
        return(parameters)
        }
        
    public var curriedFunction: [CurriedFunctionType]
        {
        CurriedFunctionType.curriedFunctions(functionType: self)
        }
    }

public class CurriedFunctionType: Type
    {
    public var parameter: Parameter
        {
        return(from)
        }
        
    public let from: Parameter
    public let to: Parameter
    public let remainder: CurriedFunctionType?
    
    init(label:Label,from:Parameter,to: Parameter,remainder: CurriedFunctionType?)
        {
        self.from = from
        self.to = to
        self.remainder = remainder
        super.init(label: label)
        }
        
    public static func curriedFunctions(functionType:FunctionType) -> [CurriedFunctionType]
        {
        let parameters = functionType.parameters
        var last:CurriedFunctionType?
        var collection = [CurriedFunctionType]()
        for index in stride(from:parameters.count-1,to: 0,by: -1)
            {
            last = CurriedFunctionType(label:"\(functionType.label)_next_\(index)",from: parameters[index-1],to: parameters[index],remainder: last)
            collection.append(last!)
            }
        return(collection)
        }
    }
