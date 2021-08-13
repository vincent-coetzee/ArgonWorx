//
//  InvocationExpression.swift
//  InvocationExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InvocationExpression: Expression
    {
    public override var resultType: TypeResult
        {
        if self.method.isNil
            {
            return(.undefined)
            }
        return(.class(self.method!.returnType))
        }
        
    private let name: Name
    private let namingContext: NamingContext
    private let reportingContext: ReportingContext
    private let arguments: Arguments
    private var method: Method?
    private let location: Location
    
    init(name:Name,arguments:Arguments,location:Location,namingContext:NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.arguments = arguments
        self.namingContext = namingContext
        self.reportingContext = reportingContext
        }
        
    public override func realize(using realizer:Realizer)
        {
        for argument in self.arguments
            {
            argument.value.realize(using: realizer)
            }
        self.method = self.namingContext.lookup(name: self.name) as? Method
        if self.method.isNil
            {
            self.reportingContext.dispatchError(at: self.location, message: "Unable to resolve a method named '\(self.name).")
            }
        else
            {
            self.validate()
            }
        }
        
    private func validate()
        {
        let instance = self.method!
//        if instance.parameters.count != self.arguments.count
//            {
//            self.reportingContext.dispatchError(at: self.location, message: "Method \(instance.label) expects \(instance.parameters.count) parameters but \(self.arguments.count) were defined.")
//            }
//
        }
        
    public override func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)INVOCATION EXPRESSION()")
        print("\(padding)\t \(self.name)")
        for argument in self.arguments
            {
            argument.value.dump(depth: depth + 1)
            }
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator) throws
        {
        if self.method.isNil
            {
            return
            }
        for argument in self.arguments.reversed()
            {
            try argument.value.emitCode(into: instance,using: using)
            instance.append(.push,argument.value.place, .none, .none)
            }
        let localCount = instance.localSlots.count
        instance.append(.push,.register(.bp))
        instance.append(.store,.register(.sp),.none,.register(.bp))
        if localCount > 0
            {
            let size = localCount * MemoryLayout<Word>.size
            instance.append(.isub,.register(.sp),.integer(Argon.Integer(size)),.register(.sp))
            }
        instance.append(.disp,.address(self.method!.memoryAddress))
        }
    }

public class MethodInvocationExpression: Expression
    {
    private let method: Method
    private let arguments: Arguments

    
    init(method:Method,arguments:Arguments)
        {
        self.method = method
        self.arguments = arguments
        }

    public override var resultType: TypeResult
        {
        return(.class(self.method.returnType))
        }
        
    public override func emitCode(into instance: InstructionBuffer, using: CodeGenerator)
        {
        
        }
    }
