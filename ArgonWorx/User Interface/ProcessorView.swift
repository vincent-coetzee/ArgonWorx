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
    @State private var buffer = InstructionBuffer.samples
    
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
                Text(Word(self.context.register(atIndex: register)).bitString).inspectorFont()
                }
            }
        Button(action:
            {
            do
                {
                try self.buffer.singleStep(in: self.context)
                self.context.update()
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
                Text(" \(instruction.opcode)".aligned(.right,in:10)).inspectorFont()
                Text(instruction.operandText.aligned(.left,in:33)).inspectorFont()
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
