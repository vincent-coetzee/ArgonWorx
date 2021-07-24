//
//  AbstractParseTreeVisitor.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 6/2/21.
//

import Foundation

public class AbstractParseTreeVisitor:ParseTreeVisitor,ReportingContext
    {
    private var visitedNodes = Dictionary<UUID,ParseTreeNode>()
    public let compiler:Compiler
    
    public func start(_ argument: Argument) throws {
        
    }
    
    public func finish(_ argument: Argument) throws {
        
    }
    
    public func start(_ class: Class) throws {
        
    }
    
    public func finish(_ class: Class) throws {
        
    }
    
    public func start(_ classMaker: Initializer) throws {
        
    }
    
    public func finish(_ classMaker: Initializer) {
    }
    
    public func start(_ constant: Constant) {
    }
    
    public func finish(_ constant: Constant) throws {
        
    }
    
    public func start(_ enumeration: Enumeration) throws {
        
    }
    
    public func finish(_ enumeration: Enumeration) throws {
        
    }
    
    public func start(_ enumerationCase: EnumerationCase) throws {
        
    }
    
    public func finish(_ enumerationCase: EnumerationCase) throws {
        
    }
    
    public func start(_ function: Function) throws {
        
    }
    
    public func finish(_ function: Function) throws {
        
    }
    
    public func start(_ reference:SymbolHolder) throws
        {
        }
        
    public func finish(_ reference:SymbolHolder) throws
        {
        }
    
    public func start(_ anImport: Import) throws {
        
    }
    
    public func finish(_ anImport: Import) throws {
        
    }
    
//    public func start(_ loadedBlock: LoadedBlock) throws {
//
//    }
//
//    public func finish(_ loadedBlock: LoadedBlock) throws {
//
//    }
    
    
    public func start(_ localSlot: LocalSlot) throws {
        
    }
    
    public func finish(_ localSlot: LocalSlot) throws {
        
    }
    
//    public func start(_ mainBlock: MainBlock) throws {
//
//    }
//
//    public func finish(_ mainBlock: MainBlock) throws {
//
//    }
    
    public func start(_ method: Method) throws {
        
    }
    
    public func finish(_ method: Method) throws {
        
    }
    
    
//    public func start(_ mapping: Mapping) throws {
//
//    }
//
//    public func finish(_ mapping: Mapping) throws {
//
//    }
    
    public func start(_ methodInstance: MethodInstance) throws {
        
    }
    
    public func finish(_ methodInstance: MethodInstance) throws {
        
    }
    
//    public func start(_ methodInstanceStub: MethodInstanceStub) throws {
//
//    }
//
//    public func finish(_ methodInstanceStub: MethodInstanceStub) throws {
//
//    }
    
    public func start(_ module: Module) throws {
        
    }
    
    public func finish(_ module: Module) throws {
        
    }
    
    public func start(_ parameter: Parameter) throws {
        
    }
    
    public func finish(_ parameter: Parameter) throws {
        
    }
    
    public func start(_ parameterizedClass:ParameterizedClass) throws
        {
        }
        
    public func finish(_ parameterizedClass:ParameterizedClass) throws
        {
        }
        
    public func start(_ parameterizedClassInstanciation:ParameterizedClassInstance) throws
        {
        }
        
    public func finish(_ parameterizedClassInstanciation:ParameterizedClassInstance) throws
        {
        }
    
//    public func start(_ reclaimedBlock: ReclaimedBlock) throws {
//
//    }
//
//    public func finish(_ reclaimedBlock: ReclaimedBlock) throws {
//
//    }
//
//    public func start(_ scopedSlot: ScopedSlot) throws {
//
//    }
//
//    public func finish(_ scopedSlot: ScopedSlot) throws {
//
//    }
    
    public func start(_ slot: Slot) throws {
        
    }
    
    public func finish(_ slot: Slot) throws {
        
    }

    public func start(_ typeAlias: TypeAlias) throws {
        
    }
    
    public func finish(_ typeAlias: TypeAlias) throws {
        
    }
    
    public func start(_ typeParameter: TypeParameter) throws {
        
    }
    
    public func finish(_ typeParameter: TypeParameter) throws {
        
    }
    
//    public func start(_ unloadedBlock: UnloadedBlock) throws {
//
//    }
//
//    public func finish(_ unloadedBlock: UnloadedBlock) throws {
//
//    }
    
    public func start(_ type: Type) throws {
        
    }
    
    public func finish(_ type: Type) throws {
        
    }
    
    public func start(_ type: TypeConstraint) throws {
        
    }
    
    public func finish(_ type: TypeConstraint) throws {
        
    }
//    
//    public func start(_ arithmeticExpression: ArithmeticExpression) throws {
//        
//    }
//    
//    public func finish(_ arithmeticExpression: ArithmeticExpression) throws {
//        
//    }
//    
//    public func start(_ arrayAccessExpression: ArrayAccessExpression) throws {
//        
//    }
//    
//    public func finish(_ arrayAccessExpression: ArrayAccessExpression) throws {
//        
//    }
//    
//    public func start(_ arrayLiteralExpression: ArrayLiteralExpression) throws {
//        
//    }
//    
//    public func finish(_ arrayLiteralExpression: ArrayLiteralExpression) throws {
//        
//    }
//    
//    public func start(_ bitExpression: BitExpression) throws {
//        
//    }
//    
//    public func finish(_ bitExpression: BitExpression) throws {
//        
//    }
//    
//    public func start(_ booleanExpression: BooleanExpression) throws {
//        
//    }
//    
//    public func finish(_ booleanExpression: BooleanExpression) throws {
//        
//    }
//    
//    public func start(_ closureExpression: ClosureExpression) throws {
//        
//    }
//    
//    public func finish(_ closureExpression: ClosureExpression) {
//    }
//    
//    public func start(_ coercionlExpression: CoercionExpression) throws {
//        
//    }
//    
//    public func finish(_ coercionlExpression: CoercionExpression) throws {
//        
//    }
//    
//    public func start(_ expression: Expression) throws {
//        
//    }
//    
//    public func finish(_ expression: Expression) throws {
//        
//    }
//    
//    public func start(_ literalExpression: LiteralExpression) throws {
//        
//    }
//    
//    public func finish(_ literalExpression: LiteralExpression) throws {
//        
//    }
//    
//    public func start(_ invocationExpression: InvocationExpression) throws {
//        
//    }
//    
//    public func finish(_ invocationExpression: InvocationExpression) throws {
//        
//    }
//    
//    public func start(_ loopClause: LOOPClause) throws {
//        
//    }
//    
//    public func finish(_ loopClause: LOOPClause) throws {
//        
//    }
//    
//    public func start(_ multiplicationExpression: MultiplicationExpression) throws {
//        
//    }
//    
//    public func finish(_ multiplicationExpression: MultiplicationExpression) throws {
//    
//    }
//    
//    public func start(_ nextMethodExpression: NextMethodExpression) throws {
//        
//    }
//    
//    public func finish(_ nextMethodExpression: NextMethodExpression) throws {
//    
//    }
//    
//    public func start(_ noneExpression: NoneExpression) throws {
//        
//    }
//    
//    public func finish(_ noneExpression: NoneExpression) throws {
//        
//    }
//    
//    public func start(_ operatorAssignmentExpression: OperatorAssignmentExpression) throws {
//    }
//    
//    public func finish(_ operatorAssignmentExpression: OperatorAssignmentExpression) throws {
//        
//    }
//    
//    public func start(_ powerExpression: PowerExpression) throws {
//        
//    }
//    
//    public func finish(_ powerExpression: PowerExpression) throws {
//        
//    }
//    
//    public func start(_ rangeExpression: RangeExpression) throws {
//        
//    }
//    
//    public func finish(_ rangeExpression: RangeExpression) throws {
//        
//    }
//    
//    public func start(_ slotExpression: SlotExpression) throws {
//        
//    }
//    
//    public func finish(_ slotExpression: SlotExpression) throws {
//        
//    }
//    
//    public func start(_ termExpression: TermExpression) throws {
//        
//    }
//    
//    public func finish(_ termExpression: TermExpression) throws {
//        
//    }
//    
//    public func start(_ typeExpression: TypeExpression) throws {
//        
//    }
//    
//    public func finish(_ typeExpression: TypeExpression) throws {
//        
//    }
//    
//    public func start(_ tupleExpression: TupleExpression) throws {
//        
//    }
//    
//    public func finish(_ tupleExpression: TupleExpression) throws {
//        
//    }
//    
//    public func start(_ unaryExpression: UnaryExpression) throws {
//        
//    }
//        
//    public func start(_ variableExpression:VariableExpression) throws
//        {
//        }
//        
//    public func finish(_ variableExpression:VariableExpression) throws
//        {
//        }
//    
//    public func finish(_ unaryExpression: UnaryExpression) throws {
//        
//    }
//    
//    public func start(_ assignmentStatement: AssignmentStatement) throws {
//        
//    }
//    
//    public func finish(_ assignmentStatement: AssignmentStatement) throws {
//        
//    }
//    
//    public func start(_ block: Block) throws {
//        
//    }
//    
//    public func finish(_ block: Block) throws {
//        
//    }
//    
//    public func start(_ closure: Closure) throws {
//        
//    }
//    
//    public func finish(_ closure: Closure) throws {
//        
//    }
//    
//    public func start(_ elseClause: ELSEClause) throws {
//        
//    }
//    
//    public func finish(_ elseClause: ELSEClause) throws {
//        
//    }
//    
//    public func start(_ forkStatement: FORKStatement) throws {
//        
//    }
//    
//    public func finish(_ forkStatement: FORKStatement) throws {
//        
//    }
//    
//    public func start(_ handleStatement: HANDLEStatement) throws {
//        
//    }
//    
//    public func finish(_ handleStatement: HANDLEStatement) throws {
//        
//    }
//    
//    public func start(_ ifStatement: IFStatement) throws {
//        
//    }
//    
//    public func finish(_ ifStatement: IFStatement) throws {
//        
//    }
//    
//    public func start(_ letStatement: LETStatement) throws {
//        
//    }
//    
//    public func finish(_ letStatement: LETStatement) throws {
//        
//    }
//    
//    public func start(_ loopStatement: LOOPStatement) throws {
//        
//    }
//    
//    public func finish(_ loopStatement: LOOPStatement) throws {
//        
//    }
//    
//    public func start(_ otherwiseClause: OTHERWISEClause) throws {
//        
//    }
//    
//    public func finish(_ otherwiseClause: OTHERWISEClause) throws {
//        
//    }
//    
//    public func start(_ repeatStatement: REPEATStatement) throws {
//        
//    }
//    
//    public func finish(_ repeatStatement: REPEATStatement) throws {
//        
//    }
//    
//    public func start(_ returnStatement: RETURNStatement) throws {
//        
//    }
//    
//    public func finish(_ returnStatement: RETURNStatement) throws {
//        
//    }
//    
//    public func start(_ scopedStatement: SCOPEDStatement) throws {
//        
//    }
//    
//    public func finish(_ scopedStatement: SCOPEDStatement) throws {
//        
//    }
//    
//    public func start(_ selectStatement: SELECTStatement) throws {
//        
//    }
//    
//    public func finish(_ selectStatement: SELECTStatement) throws {
//        
//    }
//    
//    public func start(_ signalStatement: SIGNALStatement) throws {
//        
//    }
//    
//    public func finish(_ signalStatement: SIGNALStatement) throws {
//        
//    }
//    
//    public func start(_ timesStatement: TIMESStatement) throws {
//        
//    }
//    
//    public func finish(_ timesStatement: TIMESStatement) throws {
//        
//    }
//    
//    public func start(_ whenClause: WHENClause) throws {
//        
//    }
//    
//    public func finish(_ whenClause: WHENClause) throws {
//        
//    }
//    
//    public func start(_ whileStatement: WHILEStatement) throws {
//        
//    }
//    
//    public func finish(_ whileStatement: WHILEStatement) throws {
//        
//    }
    
    public func visit(_ node:ParseTreeNode?) throws
        {
        guard let node = node else
            {
            return
            }
        try self.start()
        try node.visit(self)
        try self.finish()
        }
        
    public func start() throws
        {
        }
        
    public func finish() throws
        {
        }
        
    public func hasVisited(node:ParseTreeNode) -> Bool
        {
        return(self.visitedNodes[node.id] != nil)
        }
        
    public func remember(node:ParseTreeNode)
        {
        self.visitedNodes[node.id] = node
        }
        
    public init(compiler:Compiler)
        {
        self.compiler = compiler
        }
        
    public func dispatchError(at:Location,message:String)
        {
        }
        
    public func dispatchWarning(at:Location,message:String)
        {
        }
    }

public class Dumper:AbstractParseTreeVisitor
    {
    }
