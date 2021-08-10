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
    @State var source: String = ""
    @State var theClass:Class
    
    init(someClass:Class)
        {
        self.theClass = someClass
        self.label = someClass.label
        }
        
    var body: some View
        {
        VStack
            {
            HStack
                {
                Button("Compile", action: {})
                Button("Run",action: {})
                }
            TokenMappedViewControllerView(source: self.$source)
            }
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
