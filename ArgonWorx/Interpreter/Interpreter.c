//
//  Interpreter.c
//  Interpreter
//
//  Created by Vincent Coetzee on 27/7/21.
//

#include "Interpreter.h"

char* _class_slot_names[19] = {"_header","_magicNumber","_classPointer","_TypeHeader","_TypeMagicNumber","_TypeClassPointer","_ObjectHeader","_ObjectMagicNumber","_ObjectClassPointer","hash","name","typeCode","extraSizeInBytes","hasBytes","instanceSizeInBytes","isValue","magicNumber","slots","superclasses"};
SlotKey classSlotKeys[19];

void InitClassPointerSlotKeys()
    {
    CWord offset = 0;
    for (int index=0;index<19;index++)
        {
        classSlotKeys[index].name = _class_slot_names[index];
        classSlotKeys[index].offset = offset;
        offset += 8;
        }
    }

CWord WordAtAddressAtOffset(CWord address,CWord offset)
    {
    CWordPointer pointer = (CWordPointer)(address + offset);
    return(*pointer);
    }
    
void SetWordAtAddressAtOffset(CWord value,CWord address,CWord offset)
    {
    CWordPointer pointer = (CWordPointer)(address + offset);
    *pointer = value;
    }

long IntegerAtAddressAtOffset(CWord address,CWord offset)
    {
    long* pointer = (long*)(address + offset);
    return(*pointer);
    }

void SetIntegerAtAddressAtOffset(long value,CWord address,CWord offset)
    {
    long* pointer = (long*)(address + offset);
    *pointer = value;
    }
    
double FloatAtAddressAtOffset(CWord address,CWord offset)
    {
    double* pointer = (double*)(address + offset);
    return(*pointer);
    }

void SetFloatAtAddressAtOffset(double value,CWord address,CWord offset)
    {
    double* pointer = (double*)(address + offset);
    *pointer = value;
    }
