//
//  MethodInstance.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

public class MethodInstance:Function
    {
    public var isSystemMethodInstance: Bool
        {
        return(false)
        }
        
    private var expressions = Expressions()
    public var parameters = Parameters()
    public var returnType = Type(label:"")
    
    public var method: ArgonWorx.Method
        {
        let method = SystemMethod(label: self.label)
        method.addInstance(self)
        return(method)
        }
        
    override init(label:Label)
        {
        super.init(label:label)
        }
        
    init(left:String,_ operation:Token.Symbol,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = TypeParameter(label:out)
        super.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(left:String,_ operation:String,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = TypeParameter(label:out)
        super.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(left:String,_ operation:String,right:String,out:Class)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = ClassType(class: out)
        super.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(left:Class,_ operation:Token.Symbol,right:Class,out:Class)
        {
        let leftParm = Parameter(label: "left", type: ClassType(class:left))
        let rightParm = Parameter(label: "right", type: ClassType(class:right))
        let name = "\(operation)"
        let result = ClassType(class:out)
        super.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ op2:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: TypeParameter(label:op2))
        let result = ClassType(class:out)
        super.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let result = TypeParameter(label:out)
        super.init(label: label)
        self.parameters = [leftParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ op2:Class,_ op3:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let lastParm = Parameter(label: "op3", type: TypeParameter(label:op3))
        let result = ClassType(class:out)
        super.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ op2:Class,_ op3:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let lastParm = Parameter(label: "op3", type: ClassType(class:op3))
        let result = ClassType(class:out)
        super.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ op2:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let result = TypeParameter(label:out)
        super.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ op2:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let result = ClassType(class:out)
        super.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    init(_ label:String,_ op1:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let result = ClassType(class:out)
        super.init(label: label)
        self.parameters = [leftParm]
        self.returnType = result
        }
        
    init(label: Label,parameters: Parameters,returnType:Type? = nil,expressions: Expressions)
        {
        self.parameters = parameters
        self.returnType = returnType ?? VoidClass.voidClass.type
        self.expressions = expressions
        super.init(label: label)
        }
        
    public func `where`(_ name:String,_ aClass:Class) -> MethodInstance
        {
        return(self)
        }
    }

public typealias MethodInstances = Array<MethodInstance>
