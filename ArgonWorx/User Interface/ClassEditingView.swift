//
//  ClassEditingView.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 14/7/21.
//

import SwiftUI

struct ClassEditingView: View
    {
    @State var label:String
    @State var superclasses:Array<UUID> = []
    @State var newSlotName:String = ""
    
    @State var theClass:Class
    
    init(someClass:Class)
        {
        self.theClass = someClass
        self.label = someClass.label
        }
        
    var body: some View
        {
        if theClass.isSystemClass
            {
            Text("This class can not be edited because it is a system class.").font(.system(size: 20, weight: .bold, design: .default))
            }
        else
            {
            EmptyView()
            }
        Form
            {
            Text(theClass.isSystemClass ? "System Class " + theClass.label : theClass.label).font(.system(size: 20, weight: .bold, design: .default)).foregroundColor(NSColor.argonLime.swiftUIColor)
            HStack
                {
                Picker("Superclasses", selection: $superclasses)
                    {
                    ForEach(ArgonModule.argonModule.object.allSubclasses)
                        {
                        aClass in
                        Text(aClass.label).tag(aClass.id)
                        }
                    }
                TextField("Name:",text: self.$label)
                }
            ForEach(theClass.localSlots)
                {
                slot in
                HStack
                    {
                    Text(slot.label)
                    Text("::")
                    Text(slot.type.displayName)
                    Button(action: { self.deleteSlot(slot)})
                        {
                        Image(systemName: "delete.left")
                        }
                    }
                }
            HStack
                {
                TextField("New Slot Name:",text:$newSlotName)
                Button(action: { self.addSlot($newSlotName)})
                    {
                    Image(systemName: "plus.square")
                    }
                }
            Spacer().frame(maxHeight: 100)
            HStack
                {
                Button("Cancel",action: self.onCancel)
                Button("OK",action: self.onOK)
                }
            }.padding(100)
            Spacer()
        }
        
    private func onCancel()
        {
        }
        
    private func onOK()
        {
        }
        
    private func deleteSlot(_ slot:Slot)
        {
        }
        
    private func addSlot(_ binding:Binding<String>)
        {
        }
    }

struct ClassEditingView_Previews: PreviewProvider
    {
    static let aClass = Class(label:"SomeClass")
    
    static var previews: some View
        {
        ClassEditingView(someClass: aClass)
        }
    }
