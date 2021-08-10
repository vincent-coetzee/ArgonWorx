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
        if self.methodInstance.isNil
            {
            return(.undefined)
            }
        return(.class(self.methodInstance!.returnType))
        }
        
    private let name: Name
    private let namingContext: NamingContext
    private let reportingContext: ReportingContext
    private let arguments: Arguments
    private var methodInstance: MethodInstance?
    private let location: Location
    
    init(name:Name,arguments:Arguments,location:Location,namingContext:NamingContext,reportingContext: ReportingContext)
        {
        self.name = name
        self.location = location
        self.arguments = arguments
        self.namingContext = namingContext
        self.reportingContext = reportingContext
        }
        
    public override func realize(_ compiler:Compiler)
        {
        for argument in self.arguments
            {
            argument.value.realize(compiler)
            }
        self.methodInstance = self.namingContext.lookup(name: self.name) as? MethodInstance
        if self.methodInstance.isNil
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
        let instance = self.methodInstance!
        if instance.parameters.count != self.arguments.count
            {
            self.reportingContext.dispatchError(at: self.location, message: "Method \(instance.label) expects \(instance.parameters.count) parameters but \(self.arguments.count) were defined.")
            }
        
        }
        
    public override func emitCode(into instance: MethodInstance, using: CodeGenerator)
        {
        
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
        
    public override func emitCode(into instance: MethodInstance, using: CodeGenerator)
        {
        
        }
    }
