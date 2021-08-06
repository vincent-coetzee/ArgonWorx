//
//  ProcessorView.swift
//  ProcessorView
//
//  Created by Vincent Coetzee on 1/8/21.
//

import SwiftUI

struct ProcessorView: View
    {
    @StateObject private var context = ExecutionContext()
    @State private var buffer = InnerInstructionArrayPointer.allocate(arraySize: 10*10, in: ManagedSegment.shared).append(InnerInstructionArrayPointer.samples.allInstructions).rewind()
    @State private var color:Color = .white
    var program = InnerInstructionArrayPointer(address:0)
    
    init()
        {
        self.initProgram()
        }
        
    var body: some View
        {
        VStack
            {
        ForEach(self.context.allRegisters)
            {
            register in
            HStack
                {
                Text("\(register)".aligned(.right,in:10) as String).inspectorFont()
                Text(Word(self.context.register(atIndex: register)).bitString).inspectorFont().foregroundColor(self.context.changedRegisters.contains(register) ? .orange : .white)
                }
            }
        Button(action:
            {
            do
                {
                try self.context.singleStep()
                }
            catch
                {
                }
            })
            {
            Text("Next")
            }
        ForEach(InnerInstructionArrayPointer.samples.allInstructions)
            {
            instruction in
            HStack
                {
                Text(" \(instruction.opcode)".aligned(.right,in:10)).inspectorFont().foregroundColor(instruction.id == self.buffer.currentInstructionId ? .orange : .white)
                Text(instruction.operandText.aligned(.left,in:33)).inspectorFont().foregroundColor(instruction.id == self.buffer.currentInstructionId ? .orange : .white)
                Spacer()
                }
            }
        }
        .padding(20)
        }
        
    mutating func initProgram()
        {
        self.program = InnerInstructionArrayPointer.allocate(arraySize: 100*10, in: ManagedSegment.shared)
        program.append(.load,operand1: .integer(2021),result: .register(.r1))
        program.append(.load,operand1: .integer(1965),result: .register(.r2))
        program.append(.isub,operand1: .register(.r1),operand2: .register(.r2),result:.register(.r3))
        program.append(.load,operand1: .integer(112000),result: .register(.r4))
        program.append(.imul,operand1: .register(.r4),operand2: .integer(12),result: .register(.r5))
        program.append(.imul,operand1: .register(.r5),operand2: .register(.r3),result: .register(.r6))
        program.append(.load,operand1: .integer(200),result: .register(.r15))
        let marker = program.append(.zero,result: .register(.r14)).fromHere("marker")
        program.append(.inc,result: .register(.r14))
        program.append(.dec,result: .register(.r15))
        program.append(.breq,operand1: .register(.r15),operand2: .integer(0),result: .label(program.toHere(marker)))
        program.rewind()
        context.call(address: self.program.address)
        }
    }

struct ProcessorView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessorView()
    }
}

