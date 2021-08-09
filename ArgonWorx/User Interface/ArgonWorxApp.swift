//
//  ArgonWorxApp.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Interpreter
import FFI

@main
struct ArgonWorxApp: App {

    @StateObject var context = ExecutionContext()
    
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
        let byteArray = InnerByteArrayPointer.with([0,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1])
        let someBytes = byteArray.bytes
        print(someBytes)
        let samples = InnerInstructionArrayPointer.samples.allInstructions
        let arrayP = InnerInstructionArrayPointer.allocate(arraySize: samples.count * 10, in: ManagedSegment.shared)
        let from = arrayP.fromHere("start")
        arrayP.append(samples)
        print("ARRAY COUNT IS \(arrayP.count)")
        let offset = arrayP.toHere(from)
        arrayP.append(.loopeq,operand1:.integer(1),operand2: .integer(1),result: .label(offset))
        arrayP.rewind()
        while arrayP.instruction.isNotNil
            {
            print("\(arrayP.instruction!.opcode) \(arrayP.instruction!.operandText)")
            arrayP.next()
            }
        let program = InnerInstructionArrayPointer.allocate(arraySize: 100*10, in: ManagedSegment.shared)
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
        while program.instruction.isNotNil
            {
            print("\(program.instruction!.opcode) \(program.instruction!.operandText)")
            program.next()
            }
        let instructionCount = program.count
        var collection = Array<Instruction>()
        for index in 0..<instructionCount
            {
            collection.append(program.instruction(at: index))
            }
        print("SIZE OF Int = \(MemoryLayout<Int>.size)")
        print("SIZE OF Int64 = \(MemoryLayout<Int64>.size)")
        let used = ManagedSegment.shared.spaceUsed
        let usedK = used.size(inUnits: .kilobytes)
        let usedM = used.size(inUnits: .megabytes)
        print("BYTES USED IN ManagedSegment: \(used.displayString), \(usedK.displayString), \(usedM.displayString)" )
        let dictionary = InnerStringKeyDictionaryPointer.allocate(size: 2000, in: ManagedSegment.shared)
        print("DICTIONARY PRIME IS: \(dictionary.prime)")
        let randomWords = EnglishWord.randomWords(maximum: 2000)
        var keyedValues = Dictionary<String,Word>()
        var index = 0
        for word in randomWords
            {
            let random = Word.random(in: 0...4000000000)
            keyedValues[word.word] = random
            dictionary[word.word] = random
            index += 1
            }
        for (key,value) in keyedValues
            {
            let answer = dictionary[key]
            assert(answer == value,"EXPECTED VALUE \(value) FOR KEY BUT RECEIVED \(answer)")
            }
        let allKeys = dictionary.keys
        let storedKeys = keyedValues.keys
        assert(allKeys.count == storedKeys.count,"STORED KEYS SIZE DOES NOT MATCH DICTIONARY KEYS SIZE")
        for key in storedKeys
            {
            assert(allKeys.contains(key),"DICTIONARY KEYS IS MISSING KEY \(key)")
            }
        let sourceURL = Bundle.main.url(forResource: "Basics", withExtension: "argon")
        let source = try! String(contentsOf: sourceURL!)
        print(source)
        let compiler = Compiler()
        let element = compiler.compileChunk(source)
        print(element)
        let library = DynamicLibrary(path: "/Users/vincent/Desktop/libXenon.dylib")
        let symbol = library.findSymbol("PrintString")
        let stringAddress = InnerStringPointer.allocateString("Can we c this string in c ?", in: ManagedSegment.shared)
        var array = [stringAddress.address]
        CallSymbolWithArguments(symbol!.address!,&array,1)
        var pointer1 = UnsafeMutablePointer<ffi_type>.allocate(capacity: 1)
        pointer1.pointee = ffi_type_uint64
        var args:UnsafeMutablePointer<ffi_type>? = UnsafeMutablePointer<ffi_type>.allocate(capacity: 1)
        args!.pointee = ffi_type_uint64
        var interface:ffi_cif = ffi_cif()
        ffi_prep_cif(&interface,FFI_DEFAULT_ABI,1,&ffi_type_void,&args)
        var input:UnsafeMutablePointer<Word>? = UnsafeMutablePointer<Word>.allocate(capacity: 1)
        input!.pointee = stringAddress.address
        var voidValue:UnsafeMutableRawPointer? = UnsafeMutableRawPointer(input)
        ffi_call(&interface,MutateSymbol(symbol!.address!),nil,&voidValue)
        print("SIZE AND STRIDE OF Instruction: \(MemoryLayout<Instruction>.stride) \(MemoryLayout<Instruction>.size)")
        var packedPointer = WordPointer(address: ManagedSegment.shared.allocateObject(sizeInBytes: 1000 * 32))!
        var offsetPointer = packedPointer
        for index in 0..<program.count
            {
            let instruction = program.instruction(at: index)
            instruction.write(to: offsetPointer)
            offsetPointer += 4
            }
        var newList = Array<Instruction>()
        offsetPointer = packedPointer
        for index in 0..<program.count
            {
            let instruction = Instruction(from: offsetPointer)
            newList.append(instruction)
            offsetPointer += 4
            }
        for item in newList
            {
            print("\(item.opcode) \(item.operandText)")
            }
        let newArray = InnerPackedInstructionArrayPointer.allocate(numberOfInstructions: 20, in: ManagedSegment.shared)
        newArray.count = 0
        newArray.count = 4
        print(newArray.count)
        newArray.count = 0
        print(newArray.count)
        for item in newList
            {
            newArray.append(item)
            }
        for item:Instruction in newArray
            {
            print("\(item.opcode) \(item.operandText)")
            }
        let vector = InnerVectorPointer.allocate(arraySize: 20, in: ManagedSegment.shared)
        var randomSet = Array<Word>()
        let randomCount = 100
        for _ in 0..<randomCount
            {
            randomSet.append(Word.random(in: 0...1000_000_000))
            }
        for random in randomSet
            {
            vector.append(random)
            }
        assert(vector.count == randomSet.count,"VECTOR COUNT SHOULD BE \(randomSet.count) BUT IS \(vector.count)")
        print("VECTOR COUNT = \(vector.count)")
        let timer = Timer()
        for value in randomSet
            {
            assert(vector.contains(value),"VECTOR SHOULD CONTAIN VALUE \(value) BUT DOES NOT")
            }
        let total = timer.stop()
        print("AVERAGE TIME TO contains = \(total/randomSet.count) milliseconds")
        print("ManagedSpace Used = \(ManagedSegment.shared.spaceUsed.size(inUnits: .kilobytes).displayString)")
        print("ManagedSpace Freee = \(ManagedSegment.shared.spaceFree.size(inUnits: .kilobytes).displayString)")
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
                .environmentObject(context)
            }
        WindowGroup("Memory Inspector")
            {
            InspectorWindow()
            }.handlesExternalEvents(matching: Set(arrayLiteral: "InspectorWindow"))
        }
}
