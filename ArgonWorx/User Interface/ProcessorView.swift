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
    @State private var buffer = InnerInstructionArrayPointer.allocate(arraySize: 10*10, in: ManagedSegment.shared).append(InstructionBuffer.samples.allInstructions).rewind()
    @State private var color:Color = .white
    
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
                try self.buffer.singleStep(in: self.context)
                }
            catch
                {
                }
            })
            {
            Text("Next")
            }
        ForEach(InstructionBuffer.samples.allInstructions)
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
    }

struct ProcessorView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessorView()
    }
}

