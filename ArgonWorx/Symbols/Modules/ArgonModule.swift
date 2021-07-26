//
//  ArgonModule.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation

///
///
/// The ArgonModule contains all the standard types and methods
/// defined by the Argon language. There is only a single instance
/// of the ArgonModule in any system running Argon, it can be accessed
/// via the accessor variable on the ArgonModule class.
///
///
public class ArgonModule: SystemModule
    {
    public var number: Class
        {
        return(self.lookup(label: "Number") as! Class)
        }
        
    public var readStream: Class
        {
        return(self.lookup(label: "ReadStream") as! Class)
        }
        
    public var stream: Class
        {
        return(self.lookup(label: "Stream") as! Class)
        }
        
    public var date: Class
        {
        return(self.lookup(label: "Date") as! Class)
        }
        
    public var time: Class
        {
        return(self.lookup(label: "Time") as! Class)
        }
        
    public var byte: Class
        {
        return(self.lookup(label: "Byte") as! Class)
        }
        
    public var symbol: Class
        {
        return(self.lookup(label: "Symbol") as! Class)
        }
        
    public var void: Class
        {
        return(self.lookup(label: "Void") as! Class)
        }
        
    public var float: Class
        {
        return(self.lookup(label: "Float") as! Class)
        }
        
    public var uInteger: Class
        {
        return(self.lookup(label: "UInteger") as! Class)
        }
        
    public var writeStream: Class
        {
        return(self.lookup(label: "WriteStream") as! Class)
        }
        
    public var boolean: Class
        {
        return(self.lookup(label: "Boolean") as! Class)
        }
        
    public var collection: Class
        {
        return(self.lookup(label: "Collection") as! Class)
        }
        
    public var string: Class
        {
        return(self.lookup(label: "String") as! Class)
        }
        
    public var methodInstance: Class
        {
        return(self.lookup(label: "MethodInstance") as! Class)
        }
        
    public var `class`: Class
        {
        return(self.lookup(label: "Class") as! Class)
        }
        
    public var metaclass: Class
        {
        return(self.lookup(label: "Metaclass") as! Class)
        }
        
    public var array: ArrayClass
        {
        return(self.lookup(label: "Array") as! ArrayClass)
        }
        
    public var slot: Class
        {
        return(self.lookup(label: "Slot") as! Class)
        }
        
    public var parameter: Class
        {
        return(self.lookup(label: "Parameter") as! Class)
        }
        
    public var method: Class
        {
        return(self.lookup(label: "Method") as! Class)
        }
        
    public var pointer: ParameterizedSystemClass
        {
        return(self.lookup(label: "Pointer") as! ParameterizedSystemClass)
        }
        
    public var object: Class
        {
        return(self.lookup(label: "Object") as! Class)
        }
        
    public var typeClass: Class
        {
        return(self.lookup(label: "Type") as! Class)
        }
        
    public var block: Class
        {
        return(self.lookup(label: "Block") as! Class)
        }
        
    public var integer: Class
        {
        return(self.lookup(label: "Integer") as! Class)
        }
        
    public var address: Class
        {
        return(self.lookup(label: "Address") as! Class)
        }
        
    public var moduleClass: Class
        {
        return(self.lookup(label: "Module") as! Class)
        }
        
    public var instructionArray: Class
        {
        return(self.lookup(label: "InstructionArray") as! Class)
        }
        
    public var enumerationCase: Class
        {
        return(self.lookup(label: "EnumerationCase") as! Class)
        }
        
    public var tuple: Class
        {
        return(self.lookup(label: "Tuple") as! Class)
        }
        
    public var dateTime: Class
        {
        return(self.lookup(label: "DateTime") as! Class)
        }
        
    public var enumeration: Class
        {
        return(self.lookup(label: "Enumeration") as! Class)
        }
        
    public var instruction: Class
        {
        return(self.lookup(label: "Instruction") as! Class)
        }
        
    public static let argonModule = ArgonModule(label:"Argon")
    
    public static func configure()
        {
        _ = ArgonModule.argonModule
        TopModule.topModule.addSymbol(ArgonModule.argonModule)
        ArgonModule.argonModule.initTypes()
        ArgonModule.argonModule.initBaseMethods()
        ArgonModule.argonModule.initSlots()
        ArgonModule.argonModule.resolveReferences()
        ArgonModule.argonModule.layout()
        }
        
    private var collectionModule: SystemModule
        {
        return(self.lookup(label: "Collections") as! SystemModule)
        }
        
    private var streamsModule: SystemModule
        {
        return(self.lookup(label: "Streams") as! SystemModule)
        }
        
    private var numbersModule: SystemModule
        {
        return(self.lookup(label: "Numbers") as! SystemModule)
        }
        
    private func initTypes()
        {
        self.addSymbol(SystemClass(label:"Address").superclass("\\\\Argon\\Numbers\\UInteger"))
        let collections = SystemModule(label:"Collections")
        self.addSymbol(collections)
        let streams = SystemModule(label:"Streams")
        self.addSymbol(streams)
        let numbers = SystemModule(label:"Numbers")
        self.addSymbol(numbers)
        collections.addSymbol(ArrayClass(label:"Array",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["INDEX","ELEMENT"]).slotClass(ArraySlot.self))
        collections.addSymbol(ArrayClass(label:"ByteArray",superclasses:["\\\\Argon\\Collections\\Array","\\\\Argon\\Collections\\Iterable"],parameters:["INDEX"]).slotClass(ArraySlot.self))
        collections.addSymbol(ArrayClass(label:"InstructionArray",superclasses:["\\\\Argon\\Collections\\Array","\\\\Argon\\Collections\\Iterable"],parameters:["INDEX","Instruction"]).slotClass(ArraySlot.self))
        self.addSymbol(SystemClass(label:"Behavior").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Block").superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.byteClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(PrimitiveClass.booleanClass.superclass("\\\\Argon\\Object").slotClass(BooleanSlot.self))
        self.addSymbol(PrimitiveClass.characterClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Class").superclass("\\\\Argon\\Type").slotClass(ObjectSlot.self))
        collections.addSymbol(SystemClass(label:"Collection").superclass("\\\\Argon\\Object").superclass("\\\\Argon\\Collections\\Iterable"))
        self.addSymbol(PrimitiveClass.dateClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(PrimitiveClass.dateTimeClass.superclass("\\\\Argon\\Date").superclass("\\\\Argon\\Time"))
        collections.addSymbol(ParameterizedSystemClass(label:"Dictionary",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["KEY","VALUE"]))
        self.addSymbol(SystemClass(label:"Enumeration").superclass("\\\\Argon\\Type"))
        self.addSymbol(SystemClass(label:"EnumerationCase").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Error").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Invokable").superclass("\\\\Argon\\Behavior"))
        self.addSymbol(SystemClass(label:"Instruction").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Expression").superclass("\\\\Argon\\Object"))
        numbers.addSymbol(TaggedPrimitiveClass.floatClass.superclass("\\\\Argon\\Numbers\\Number"))
        self.addSymbol(SystemClass(label:"Function").superclass("\\\\Argon\\Invokable"))
        numbers.addSymbol(TaggedPrimitiveClass.integerClass.superclass("\\\\Argon\\Numbers\\Number").slotClass(IntegerSlot.self))
        collections.addSymbol(ParameterizedSystemClass(label:"Iterable",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"]))
        collections.addSymbol(ParameterizedSystemClass(label:"List",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Magnitude").superclass("\\\\Argon\\Object"))
        self.addSymbol(SystemClass(label:"Metaclass",typeCode:.metaclass).superclass("\\\\Argon\\Class"))
        self.addSymbol(SystemClass(label:"Method",typeCode:.method).superclass("\\\\Argon\\Invokable"))
        self.addSymbol(SystemClass(label:"MethodInstance",typeCode:.methodInstance).superclass("\\\\Argon\\Invokable"))
        self.addSymbol(SystemClass(label:"Module",typeCode:.module).superclass("\\\\Argon\\Type"))
        self.addSymbol(PrimitiveClass.mutableStringClass.superclass("\\\\Argon\\String"))
        self.addSymbol(SystemClass(label:"Nil").superclass("\\\\Argon\\Object"))
        numbers.addSymbol(SystemClass(label:"Number").superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Object"))
        self.addSymbol(SystemClass(label:"Parameter").superclass("\\\\Argon\\Slot"))
        self.addSymbol(ParameterizedSystemClass(label:"Pointer",superclasses:["\\\\Argon\\Object"],parameters:["ELEMENT"],typeCode:.pointer))
        streams.addSymbol(SystemClass(label:"ReadStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\Stream"))
        streams.addSymbol(SystemClass(label:"ReadWriteStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\ReadStream").superclass("\\\\Argon\\Streams\\WriteStream"))
        collections.addSymbol(ParameterizedSystemClass(label:"Set",superclasses:["\\\\Argon\\Collections\\Collection","\\\\Argon\\Collections\\Iterable"],parameters:["ELEMENT"]))
        self.addSymbol(SystemClass(label:"Slot",typeCode:.slot).superclass("\\\\Argon\\Object"))
        streams.addSymbol(SystemClass(label:"Stream",typeCode:.stream).superclass("\\\\Argon\\Object"))
        self.addSymbol(PrimitiveClass.stringClass.superclass("\\\\Argon\\Object").slotClass(StringSlot.self))
        self.addSymbol(SystemClass(label:"Symbol",typeCode:.symbol).superclass("\\\\Argon\\String"))
        self.addSymbol(PrimitiveClass.timeClass.superclass("\\\\Argon\\Magnitude"))
        self.addSymbol(SystemClass(label:"Tuple",typeCode:.tuple).superclass("\\\\Argon\\Type"))
        self.addSymbol(SystemClass(label:"Type",typeCode:.type).superclass("\\\\Argon\\Object"))
        numbers.addSymbol(TaggedPrimitiveClass.uIntegerClass.superclass("\\\\Argon\\Numbers\\Number"))
        self.addSymbol(VoidClass.voidClass.superclass("\\\\Argon\\Object"))
        streams.addSymbol(SystemClass(label:"WriteStream",typeCode:.stream).superclass("\\\\Argon\\Streams\\Stream"))
        }
        
    private func initSlots()
        {
        self.object.slot("hash",self.integer)
        self.date.virtual("day",self.integer).virtual("month",self.string).virtual("monthIndex",self.integer).virtual("year",self.integer)
        self.time.virtual("hour",self.integer).virtual("minute",self.integer).virtual("second",self.integer).virtual("millisecond",self.integer)
        self.dateTime.virtual("date",self.date).virtual("time",self.time)
        self.collection.slot("count",self.integer)
        self.stream.slot("fileHandle",self.integer).slot("count",self.integer).virtual("isOpen",self.boolean).virtual("canRead",self.boolean).virtual("canWrite",self.boolean)
        self.slot.slot("name",self.string).slot("type",self.typeClass).slot("offset",self.integer).slot("typeCode",self.integer)
        self.typeClass.slot("name",self.string).slot("typeCode",self.integer)
        self.class.slot("superclasses",self.array.of(self.class)).virtual("subclasses",self.array.of(self.class)).slot("slots",self.array.of(self.slot)).slot("extraSizeInBytes",self.integer).slot("instanceSizeInBytes",self.integer).slot("hasBytes",self.boolean).slot("isValue",self.boolean).slot("magicNumber",self.integer)
        self.method.slot("instances",self.array.of(self.methodInstance))
        self.methodInstance.slot("name",self.string).slot("parameters",self.array.of(self.parameter)).slot("resultType",self.typeClass).slot("code",self.instructionArray)
        self.enumerationCase.slot("symbol",self.symbol).slot("associatedTypes",self.array.of(self.typeClass)).slot("enumeration",self.enumeration).slot("value",self.integer)
        self.enumeration.slot("valueType",self.typeClass).slot("cases",self.array.of(self.enumerationCase))
        self.block.slot("count",self.integer).slot("size",self.integer).slot("nextBlock",self.address)
        self.moduleClass.virtual("isSystemModule",self.boolean).slot("elements",self.typeClass).slot("isArgonModule",self.boolean).slot("isTopModule",self.boolean).slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.tuple.slot("slots",self.array.of(self.slot)).slot("instanceSizeInBytes",self.integer)
        self.array.slot("elementType",self.typeClass).slot("size",self.integer).slot("firstBlock",self.block).hasBytes(true)
        self.instruction.virtual("opcode",self.integer).virtual("mode",self.integer).virtual("operand1",self.integer).virtual("operand2",self.integer).virtual("operand3",self.integer)
        self.string.slot("count",self.integer).virtual("bytes",self.address).hasBytes(true)
        self.instructionArray.hasBytes(true)
        }
        
    private func initBaseMethods()
        {
        let numbersModule = self.numbersModule
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE",.add,right:"TYPE",out:"TYPE").where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE",.sub,right:"TYPE",out:"TYPE").where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE",.mul,right:"TYPE",out:"TYPE").where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE",.div,right:"TYPE",out:"TYPE").where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE",.modulus,right:"TYPE",out:"TYPE").where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE","truncate",right:"TYPE",out:self.integer).where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE","ceiling",right:"TYPE",out:self.integer).where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE","floor",right:"TYPE",out:self.integer).where("TYPE",self.number).method)
        numbersModule.addSymbol(SystemMethodInstance(left:"TYPE","round",right:"TYPE",out:self.integer).where("TYPE",self.number).method)
        let streams = self.streamsModule
        streams.addSymbol(SystemMethodInstance("next",self.readStream,"TYPE",self.integer).where("TYPE",self.object).method)
        streams.addSymbol(SystemMethodInstance("nextPut",self.writeStream,"TYPE",self.integer).where("TYPE",self.object).method)
        streams.addSymbol(SystemMethodInstance("open",self.string,self.string,"TYPE").where("TYPE",self.readStream).where("TYPE",self.writeStream).method)
        streams.addSymbol(SystemMethodInstance("close",self.stream,self.boolean).method)
        streams.addSymbol(SystemMethodInstance("tell",self.stream,self.integer).method)
        streams.addSymbol(SystemMethodInstance("flush",self.stream,self.boolean).method)
        streams.addSymbol(SystemMethodInstance("seek",self.stream,self.integer,self.boolean).method)
        streams.addSymbol(SystemMethodInstance("nextLine",self.stream,self.string,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextPutLine",self.stream,self.string,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextByte",self.stream,self.byte,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextPutByte",self.stream,self.byte,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextFloat",self.stream,self.float).method)
        streams.addSymbol(SystemMethodInstance("nextPutFloat",self.stream,self.float,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextInteger",self.stream,self.integer).method)
        streams.addSymbol(SystemMethodInstance("nextPutInteger",self.stream,self.integer,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextString",self.stream,self.string).method)
        streams.addSymbol(SystemMethodInstance("nextPutString",self.stream,self.string,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextSymbol",self.stream,self.symbol).method)
        streams.addSymbol(SystemMethodInstance("nextPutSymbol",self.stream,self.symbol,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextUInteger",self.stream,self.uInteger).method)
        streams.addSymbol(SystemMethodInstance("nextPutUInteger",self.stream,self.uInteger,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextDate",self.stream,self.date).method)
        streams.addSymbol(SystemMethodInstance("nextPutDate",self.stream,self.date,self.void).method)
        streams.addSymbol(SystemMethodInstance("nextTime",self.stream,self.time).method)
        streams.addSymbol(SystemMethodInstance("nextPutTime",self.stream,self.time,self.void).method)
        let collections = self.collectionModule
        collections.addSymbol(SystemMethodInstance("at",self.array,self.integer,"TYPE").method)
        collections.addSymbol(SystemMethodInstance("atPut",self.array,self.integer,"TYPE",self.void).method)
        collections.addSymbol(SystemMethodInstance("atPutAll",self.array,self.integer,self.array,self.void).method)
        collections.addSymbol(SystemMethodInstance("contains",self.array,"TYPE",self.boolean).method)
        collections.addSymbol(SystemMethodInstance("containsAll",self.array,self.array,self.boolean).method)
        collections.addSymbol(SystemMethodInstance("last",self.array,"TYPE").method)
        collections.addSymbol(SystemMethodInstance("first",self.array,"TYPE").method)
        collections.addSymbol(SystemMethodInstance("add",self.array,"TYPE").method)
        collections.addSymbol(SystemMethodInstance("addAll",self.array,self.array).method)
        collections.addSymbol(SystemMethodInstance("removeAt",self.array,self.integer).method)
        collections.addSymbol(SystemMethodInstance("removeAll",self.array,self.array).method)
        collections.addSymbol(SystemMethodInstance("withoutFirst",self.array,self.array).method)
        collections.addSymbol(SystemMethodInstance("withoutLast",self.array,self.array).method)
        collections.addSymbol(SystemMethodInstance("withoutFirst",self.array,self.integer,self.array).method)
        collections.addSymbol(SystemMethodInstance("withoutLast",self.array,self.integer,self.array).method)
        let strings = SymbolGroup(label:"String Methods")
        self.addSymbol(strings)
        strings.addSymbol(SystemMethodInstance("separatedBy",self.string,self.string,self.array.of(self.string)).method)
        strings.addSymbol(SystemMethodInstance("joinedWith",self.array.of(self.string),self.string,self.string).method)
        strings.addSymbol(SystemMethodInstance("contains",self.string,self.string,self.boolean).method)
        strings.addSymbol(SystemMethodInstance("hasPrefix",self.string,self.string,self.boolean).method)
        strings.addSymbol(SystemMethodInstance("hasSuffix",self.string,self.string,self.boolean).method)
        strings.addSymbol(SystemMethodInstance("prefixedWith",self.string,self.string,self.string).method)
        strings.addSymbol(SystemMethodInstance("suffixedWith",self.string,self.string,self.boolean).method)
        }
    ///
    ///
    /// We need a special layout algorithm because this module has
    /// complex dependencies.
    ///
    ///
    internal override func layout()
        {
        print("LAYING OUT SLOTS")
        self.layoutSlots()
        for aClass in self.classes.sorted(by: {$0.name<$1.name})
            {
            aClass.printLayout()
            }
        print("LAID OUT SLOTS")
        ///
        ///
        /// Now do layouts in a specific order
        ///
        print("LAYING OUT MEMORY")
        let segment = ManagedSegment.shared
        self.object.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.string.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.array.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.slot.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.typeClass.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.class.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.enumeration.preallocateMemory(size: InnerPointer.kClassSizeInBytes,in: segment)
        self.object.layoutInMemory(segment: segment)
        self.array.layoutInMemory(segment: segment)
        self.string.layoutInMemory(segment: segment)
        self.slot.layoutInMemory(segment: segment)
        self.typeClass.layoutInMemory(segment: segment)
        self.class.layoutInMemory(segment: segment)
        self.enumeration.layoutInMemory(segment: segment)
        for aClass in self.classes
            {
            aClass.layoutInMemory(segment: ManagedSegment.shared)
            }
        for aClass in self.classes
            {
            aClass.updateSystemSlots()
            }
        ManagedSegment.shared.backpatchAllocatedObjectClasses()
        print("LAID OUT MEMORY")
        }
    }
