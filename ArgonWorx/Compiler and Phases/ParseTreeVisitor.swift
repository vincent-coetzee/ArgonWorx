//
//  ParseTreeVisitor.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/25/21.
//

import Foundation

public protocol ParseTreeVisitor
    {
    var compiler:Compiler { get }
//    func accept(_ state:AcceptState,_ aliasSlot:AliasSlot) throws
    func start(_ argument:Argument) throws
    func finish(_ argument:Argument) throws
    func start(_ `class`:Class) throws
    func finish(_ `class`:Class) throws
    func start(_ constant:Constant) throws
    func finish(_ constant:Constant) throws
//    func accept(_ delegateSlot:DelegateSlot) throws
    func start(_ enumeration:Enumeration) throws
    func finish(_ enumeration:Enumeration) throws
    func start(_ enumerationCase:EnumerationCase) throws
    func finish(_ enumerationCase:EnumerationCase) throws
    func start(_ function:Function) throws
    func finish(_ function:Function) throws
    func start(_ reference:SymbolHolder) throws
    func finish(_ reference:SymbolHolder) throws
    func start(_ anImport:Import) throws
    func finish(_ anImport:Import) throws
    func start(_ initializer:Initializer) throws
    func finish(_ initializer:Initializer) throws
//    func start(_ loadedBlock:LoadedBlock) throws
//    func finish(_ loadedBlock:LoadedBlock) throws
    func start(_ localSlot:LocalSlot) throws
    func finish(_ localSlot:LocalSlot) throws
//    func start(_ mainBlock:MainBlock) throws
//    func finish(_ mainBlock:MainBlock) throws
//    func start(_ mapping:Mapping) throws
//    func finish(_ mapping:Mapping) throws
    func start(_ method:Method) throws
    func finish(_ method:Method) throws
    func start(_ methodInstance:MethodInstance) throws
    func finish(_ methodInstance:MethodInstance) throws
//    func start(_ methodInstanceStub:MethodInstanceStub)  throws
//    func finish(_ methodInstanceStub:MethodInstanceStub)  throws
    func start(_ module:Module) throws
    func finish(_ module:Module) throws
    func start(_ parameter:Parameter) throws
    func finish(_ parameter:Parameter) throws
    func start(_ parameterizedClass:ParameterizedClass) throws
    func finish(_ parameterizedClass:ParameterizedClass) throws
    func start(_ parameterizedClassInstance:ParameterizedClassInstance) throws
    func finish(_ parameterizedClassInstance:ParameterizedClassInstance) throws
//    func start(_ reclaimedBlock:ReclaimedBlock) throws
//    func finish(_ reclaimedBlock:ReclaimedBlock) throws
//    func start(_ scopedSlot:ScopedSlot) throws
//    func finish(_ scopedSlot:ScopedSlot) throws
    func start(_ slot:Slot) throws
    func finish(_ slot:Slot) throws
//    func start(_ symbolReference:SymbolReference) throws
//    func finish(_ symbolReference:SymbolReference) throws
    func start(_ typeAlias:TypeAlias) throws
    func finish(_ typeAlias:TypeAlias) throws
//    func start(_ genericParameter:TypeParameter) throws
//    func finish(_ genericParameter:TypeParameter) throws
//    func start(_ typeReference:DeferredSymbol) throws
//    func finish(_ typeReference:DeferredSymbol) throws
//    func start(_ type:Type) throws
//    func finish(_ type:Type) throws
    func start(_ type:TypeConstraint) throws
    func finish(_ type:TypeConstraint) throws
//    func start(_ unloadedBlock:UnloadedBlock) throws
//    func finish(_ unloadedBlock:UnloadedBlock) throws
    
//    func start(_ arithmeticExpression:ArithmeticExpression)  throws
//    func finish(_ arithmeticExpression:ArithmeticExpression)  throws
//    func start(_ arrayAccessExpression:ArrayAccessExpression) throws
//    func finish(_ arrayAccessExpression:ArrayAccessExpression) throws
//    func start(_ arrayLiteralExpression:ArrayLiteralExpression) throws
//    func finish(_ arrayLiteralExpression:ArrayLiteralExpression) throws
//    func start(_ bitExpression:BitExpression) throws
//    func finish(_ bitExpression:BitExpression) throws
//    func start(_ booleanExpression:BooleanExpression) throws
//    func finish(_ booleanExpression:BooleanExpression) throws
//    func start(_ closureExpression:ClosureExpression) throws
//    func finish(_ closureExpression:ClosureExpression) throws
//    func start(_ coercionlExpression:CoercionExpression) throws
//    func finish(_ coercionlExpression:CoercionExpression) throws
//    func start(_ literalExpression:LiteralExpression) throws
//    func finish(_ literalExpression:LiteralExpression) throws
//    func start(_ invocationExpression:InvocationExpression) throws
//    func finish(_ invocationExpression:InvocationExpression) throws
//    func start(_ loopClause:LOOPClause) throws
//    func finish(_ loopClause:LOOPClause) throws
//    func start(_ multiplicationExpression:MultiplicationExpression) throws
//    func finish(_ multiplicationExpression:MultiplicationExpression) throws
//    func start(_ nextMethodExpression:NextMethodExpression) throws
//    func finish(_ nextMethodExpression:NextMethodExpression) throws
//    func start(_ noneExpression:NoneExpression) throws
//    func finish(_ noneExpression:NoneExpression) throws
//    func start(_ operatorAssignmentExpression:OperatorAssignmentExpression) throws
//    func finish(_ operatorAssignmentExpression:OperatorAssignmentExpression) throws
//    func start(_ powerExpression:PowerExpression) throws
//    func finish(_ powerExpression:PowerExpression) throws
//    func start(_ rangeExpression:RangeExpression) throws
//    func finish(_ rangeExpression:RangeExpression) throws
//    func start(_ slotExpression:SlotExpression) throws
//    func finish(_ slotExpression:SlotExpression) throws
//    func start(_ termExpression:TermExpression) throws
//    func finish(_ termExpression:TermExpression) throws
//    func start(_ typeExpression:TypeExpression) throws
//    func finish(_ typeExpression:TypeExpression) throws
//    func start(_ typeReferenceExpression:TypeReferenceExpression) throws
//    func finish(_ typeReferenceExpression:TypeReferenceExpression) throws
//    func start(_ tupleExpression:TupleExpression) throws
//    func finish(_ tupleExpression:TupleExpression) throws
//    func start(_ unaryExpression:UnaryExpression) throws
//    func finish(_ unaryExpression:UnaryExpression) throws
//    func start(_ variableExpression:VariableExpression) throws
//    func finish(_ variableExpression:VariableExpression) throws
//
//    func start(_ assignmentStatement:AssignmentStatement) throws
//    func finish(_ assignmentStatement:AssignmentStatement) throws
//    func start(_ block:Block) throws
//    func finish(_ block:Block) throws
//    func start(_ closure:Closure) throws
//    func finish(_ closure:Closure) throws
//    func start(_ elseClause:ELSEClause) throws
//    func finish(_ elseClause:ELSEClause) throws
//    func start(_ forkStatement:FORKStatement) throws
//    func finish(_ forkStatement:FORKStatement) throws
//    func start(_ handleStatement:HANDLEStatement) throws
//    func finish(_ handleStatement:HANDLEStatement) throws
//    func start(_ ifStatement:IFStatement) throws
//    func finish(_ ifStatement:IFStatement) throws
//    func start(_ letStatement:LETStatement) throws
//    func finish(_ letStatement:LETStatement) throws
//    func start(_ loopStatement:LOOPStatement) throws
//    func finish(_ loopStatement:LOOPStatement) throws
//    func start(_ otherwiseClause:OTHERWISEClause) throws
//    func finish(_ otherwiseClause:OTHERWISEClause) throws
//    func start(_ repeatStatement:REPEATStatement) throws
//    func finish(_ repeatStatement:REPEATStatement) throws
//    func start(_ returnStatement:RETURNStatement) throws
//    func finish(_ returnStatement:RETURNStatement) throws
//    func start(_ scopedStatement:SCOPEDStatement) throws
//    func finish(_ scopedStatement:SCOPEDStatement) throws
//    func start(_ selectStatement:SELECTStatement) throws
//    func finish(_ selectStatement:SELECTStatement) throws
//    func start(_ signalStatement:SIGNALStatement) throws
//    func finish(_ signalStatement:SIGNALStatement) throws
//    func start(_ timesStatement:TIMESStatement) throws
//    func finish(_ timesStatement:TIMESStatement) throws
//    func start(_ whenClause:WHENClause) throws
//    func finish(_ whenClause:WHENClause) throws
//    func start(_ whileStatement:WHILEStatement) throws
//    func finish(_ whileStatement:WHILEStatement) throws
    
    func hasVisited(node:ParseTreeNode) -> Bool
    func remember(node:ParseTreeNode)
    }
    
public protocol ParseTreeNode
    {
    var index:UUID { get }
    func visit(_ visitor:ParseTreeVisitor) throws
    }

