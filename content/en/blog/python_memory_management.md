---
author: "Navdeep Kaur"
title: "How Memory is managed in Python?"
description: "With some examples, this article explains the memory management, garbage collection, id() function and memory allocation in Python."
tags: ["Memory management","Garbage collection"]
date: 2022-01-24
thumbnail: https://www.askpython.com/wp-content/uploads/2020/11/Memory-management-in-python-1024x512.png
---

> Any software developer should be aware of memory allocation since designing efficient code also implies producing memory-efficient code.

**This article covers**:

- What is memory management?
- Garbage collection
- Reference counting
- id() function
- Memory allocation in Python

## **What is memory management?**

A memory manager decides where an application's data should be stored. Memory allocation is the process of allocating a block of memory in a computer to a program, whereas memory deallocation is the process of freeing up memory. Python's memory allocation and deallocation procedures are fully automated, as the Python developers created a garbage collector to eliminate the need for the user to manually collect garbage.

- **Garbage Collection**

Garbage collection is the process by which the interpreter frees up memory when it isn't in use, allowing other things to use it. Assume there is no memory reference to an object that is no longer in use. The virtual computer in this case has a garbage collector.

- **Reference Counting**

Reference counting counts the number of times an object is referenced to by other objects in the system. When references to an object are deleted, the reference count for that object is reduced. When the reference count approaches zero, the object is deallocated.

**For example:**

*Let's consider the situation where two or more variables have the same value. The Python virtual machine makes the second variable point to the already existing value in the private heap, rather than creating another object with the same value in the private heap.*

```python
>>> x = 10
>>> id(x)
2033856768592
>>> # Because everything in Python is an object, when x = 10 is executed, 
>>> # an integer object 10 is generated in memory and 
>>> # its reference is set to variable x.

>>> y = x # second variable pointing to existing value
>>>
>>> id(y)
2033856768592
>>>
>>> if id(x) == id(y): # to check if x and y have same id's.
...     print("x and y refer to the same object")
...
x and y refer to the same object
```

- **id() function** 

As in the above example, the function only takes one parameter and returns the object's identity. This identification must be unique and constant throughout the object's existence. The id() value of two objects with non-overlapping values may be the same. If the object already exists with the same value, then it will construct another reference variable that will refer to the same object.

- Now, let’s change the value of x and see what happens.

```python

>>> x = 10 # variable with value 10
>>> y = x #varible with same existing value
>>>
>>> id(x)
2033856768592
>>>
>>> id(y)
2033856768592
>>> # Both x and y have same values upto now
>>>
>>> x = 11 # Now value of x is 11
>>>
>>> id(x)
2033856768624 # id of x has been changed here because now x has value 11.
>>>
>>> if id(x) != id(y):
...     print("x and y do not refer to the same object")
...
x and y do not refer to the same object
```

- So now x refer to a new object x and the link between x and 10 disconnected but y still refer to 10.

## **Memory Allocation in Python**

*There are two parts of memory:*

- Stack Memory Allocation
- Heap Memory Allocation

1. **Stack Memory Allocation**

*Stack memory allocation is the storage of static memory inside a particular function or method call. When the function is called, the memory is stored in the function call stack. Any local variable initializations are stored in call stack and deleted once the function returns.

So, when we run our program, all the functions are first stored in call stack and then deleted when the function is returned.*

**For Example:**

```python
def func():
    #These initializations are stored in stack memory
    x = 10
    y = "Apple"
```

2. **Heap Memory Allocation**

Heap memory allocation is the storage of memory that is needed outside a particular function or a method call or are shared within multiple functions globally are stored in Heap memory. This memory is used in the program at global scope.

It is simply a large space of memory provided to users when they want to allocate and deallocate variables/values.

In Python, heap memory is managed by interpreter itself and the user has no control over it.

**For Example:**

```python

# Allocates memory for 5 integers in heap memory
x=[None]*5
```