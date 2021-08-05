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
        print("SIZE OF Int = \(MemoryLayout<Int>.size)")
        print("SIZE OF Int64 = \(MemoryLayout<Int64>.size)")
        let used = ManagedSegment.shared.bytesInUse
        let usedK = used / 1024
        let usedM = usedK / 1024
        print("BYTES USED IN ManagedSegment: \(used) bytes, \(usedK) KB, \(usedM) MB" )
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
            print("ADDED INDEX \(index) \(word.word)")
            }
        for (key,value) in keyedValues
            {
            let answer = dictionary[key]
            assert(value == answer,"FOR KEY \(key) STORED VALUE \(value) WAS \(answer) INSTEAD oF \(value)")
            }
        let allKeys = dictionary.keys
        print(allKeys)
        let sourceURL = Bundle.main.url(forResource: "Basics", withExtension: "argon")
        let source = try! String(contentsOf: sourceURL!)
        print(source)
//        let compiler = Compiler()
//        let element = compiler.compileChunk(source)
//        print(element)
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
