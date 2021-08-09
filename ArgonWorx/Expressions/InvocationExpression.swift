//
//  InvocationExpression.swift
//  InvocationExpression
//
//  Created by Vincent Coetzee on 4/8/21.
//

import Foundation

public class InvocationExpression: Expression
    {
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
        }
        
    public override func generateConstraints(into inferencer:TypeInferencer)
        {
        if let instance = self.methodInstance
            {
            let curried = instance.curried()
            }
        }
        
    public override func findType() -> Class?
        {
        if methodInstance.isNil
            {
            self.reportingContext.dispatchError(at: self.location, message: "\(self.name) can not be resolved.")
            self.annotatedType = nil
            return(nil)
            }
        self.annotatedType = methodInstance?.returnType
        return(self.annotatedType)
        }
        
    public override func emitCode(into instance: MethodInstance, using: CodeGenerator)
        {
        
        }
    }
