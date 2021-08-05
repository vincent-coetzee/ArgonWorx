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
        
    internal private(set) var block: MethodInstanceBlock! = nil
    public var localSlots = LocalSlots()
    
    public var method: ArgonWorx.Method
        {
        let method = SystemMethod(label: self.label)
        method.addInstance(self)
        return(method)
        }
        
    override init(label:Label)
        {
        super.init(label:label)
        self.block = MethodInstanceBlock(methodInstance: self)
        }
        
    convenience init(left:String,_ operation:Token.Symbol,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = TypeParameter(label:out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(left:String,_ operation:String,right:String,out:String)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = TypeParameter(label:out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(left:String,_ operation:String,right:String,out:Class)
        {
        let leftParm = Parameter(label: "left", type: TypeParameter(label: left))
        let rightParm = Parameter(label: "right", type: TypeParameter(label: right))
        let name = "\(operation)"
        let result = ClassType(class: out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(left:Class,_ operation:Token.Symbol,right:Class,out:Class)
        {
        let leftParm = Parameter(label: "left", type: ClassType(class:left))
        let rightParm = Parameter(label: "right", type: ClassType(class:right))
        let name = "\(operation)"
        let result = ClassType(class:out)
        self.init(label: name)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: TypeParameter(label:op2))
        let result = ClassType(class:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let result = TypeParameter(label:out)
        self.init(label: label)
        self.parameters = [leftParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:String,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let lastParm = Parameter(label: "op3", type: TypeParameter(label:op3))
        let result = ClassType(class:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ op3:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let lastParm = Parameter(label: "op3", type: ClassType(class:op3))
        let result = ClassType(class:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm,lastParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:String)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let result = TypeParameter(label:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ op2:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let rightParm = Parameter(label: "op2", type: ClassType(class:op2))
        let result = ClassType(class:out)
        self.init(label: label)
        self.parameters = [leftParm,rightParm]
        self.returnType = result
        }
        
    convenience init(_ label:String,_ op1:Class,_ out:Class)
        {
        let leftParm = Parameter(label: "op1", type: ClassType(class:op1))
        let result = ClassType(class:out)
        self.init(label: label)
        self.parameters = [leftParm]
        self.returnType = result
        }
        
    convenience init(label: Label,parameters: Parameters,returnType:Type? = nil)
        {
        self.init(label: label)
        self.parameters = parameters
        self.returnType = returnType ?? VoidClass.voidClass.type
        }
        
    public func `where`(_ name:String,_ aClass:Class) -> MethodInstance
        {
        return(self)
        }
        
    public func addLocalSlot(_ localSlot:LocalSlot)
        {
        self.localSlots.append(localSlot)
        self.localSlots.sort(by: {$0.offset < $1.offset})
        }
        
    public override func lookup(label: String) -> Symbol?
        {
        for slot in self.localSlots
            {
            if slot.label == label
                {
                return(slot)
                }
            }
        return(self.parent?.lookup(label: label))
        }
        
    public func layoutSymbol(in segment:ManagedSegment)
        {
        guard !self.isMemoryLayoutDone else
            {
            return
            }
        let pointer = InnerMethodInstancePointer.allocate(in: segment)
        self.memoryAddress = pointer.address
        assert( ArgonModule.argonModule.slot.sizeInBytes == 88)
        pointer.setSlotValue(segment.allocateString(self.label),atKey:"name")
        let slotArray = InnerArrayPointer.allocate(arraySize: self.localSlots.count, in: segment)
        for slot in self.localSlots
            {
            slot.layoutSymbol(in: segment)
            slotArray.append(slot.memoryAddress)
            }
        self.isMemoryLayoutDone = true
        }
    }

public typealias MethodInstances = Array<MethodInstance>
