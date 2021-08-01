//
//  ArgonWorxApp.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import SwiftUI
import UniformTypeIdentifiers
    
@main
struct ArgonWorxApp: App {

    init()
        {
        Thread.initThreads()
        ArgonModule.configure()
        Header.test()
        let segment = ManagedSegment.shared
        let classObject = segment.allocateObject(sizeInBytes: ArgonModule.argonModule.class.sizeInBytes)
        let string1 = segment.allocateString("This is a test string to see how it is allocated.")
        let string2 = string1
        print(Word(ObjectPointer(address: string2,class:ArgonModule.argonModule.string).count))
        let pointer = StringPointer(address: string2)
        print(pointer.string)
        let array = segment.allocateArray(maximumCount: 20)
        var arrayPointer = ArrayPointer(address: array)
        print("array size is \(arrayPointer.size)")
        print("array count is \(arrayPointer.count)")
        arrayPointer.append(2000)
        arrayPointer.append(10000)
        print("array count is \(arrayPointer.count)")
        print("array[0] = \(arrayPointer[0])")
        print("array[1] = \(arrayPointer[1])")
        let theClass = ArgonModule.argonModule.class
        theClass.layoutInMemory(segment: segment)
        let address = theClass.memoryAddress
        theClass.rawDumpFromAddress(address)
        let nameAddress = ObjectPointer(address: address,class:ArgonModule.argonModule.class).name
        let stringPointer = InnerStringPointer(address:nameAddress)
        let stringCount = stringPointer.count
        print(stringCount)
        let aString = stringPointer.string
        print(aString)
        let anArray = InnerArrayPointer(address: ObjectPointer(address: address,class:ArgonModule.argonModule.class).slots)
        let slotsCount = anArray.count
        let slotsSize = anArray.size
        print(slotsCount)
        print(slotsSize)
        let slot1 = InnerSlotPointer(address: anArray[0])
        let slot1Name = slot1.name
        print(slot1Name)
        print("\(slotsCount) SLOTS IN \(aString)")
        for index in 0..<slotsCount
            {
            let slot = InnerSlotPointer(address: anArray[index])
            print("SLOT \(index) IS \(slot.name)")
            }
        let classPointer = slot1.classPointer
        let name1 = classPointer.name
        print(name1)
        let class1Pointer = InnerClassPointer(address: ArgonModule.argonModule.array.memoryAddress)
        let slotsPointer = class1Pointer.slots
        print(slotsPointer.count)
        print(slotsPointer.size)
        let slot1Pointer = InnerSlotPointer(address: slotsPointer[4])
        print(slot1Pointer.name)
        print(slot1Pointer.typeCode)
        var encoder = BitEncoder()
        var value:Int = 0b1111
        var width = 10
        encoder.encode(value: value,inWidth: width)
        print(encoder.words)
        encoder = BitEncoder()
        width = 4
        encoder.encode(value: 0b1100,inWidth: width)
        encoder.encode(value: Instruction.Operand.slot(.sp,10),inWidth: width)
        width = 64
        encoder.encode(value: 0b11111111,inWidth: width)
        width = 8
        encoder.encode(value: 0b11111111,inWidth: width)
        let thread = Thread.current
        print(thread.context)
        let sample = InstructionBuffer.sample
        sample.dump()
        do
            {
            try sample.execute(in: ExecutionContext())
            }
        catch let error
            {
            print("\(error)")
            }
        }
        
    var body: some Scene
        {
        WindowGroup("Project Browser")
            {
            ContentView()
            }
        WindowGroup("Processor Browser")
            {
            ProcessorView()
            }
        WindowGroup("Memory Inspector")
            {
            InspectorWindow()
            }.handlesExternalEvents(matching: Set(arrayLiteral: "InspectorWindow"))
        }
}
