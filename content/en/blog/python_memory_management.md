---
author: "Navdeep Kaur"
title: "Memory management"
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

Any software developer should be aware of memory allocation since designing efficient code also implies producing memory-efficient code. Allocating a block of memory in a computer to a program is known as memory allocation and freeing up memory is called memory deallocation. The memory allocation and deallocation methods in Python are automatic since the Python developers designed a garbage collector so that the user does not have to manually collect rubbish.

- **Garbage Collection**

Garbage collection is the method by which the interpreter frees up memory when it isn't in use so that it can be used by other objects.Assume there is no reference to an item in memory that is not in use. In this scenario, the virtual machine has a garbage collector.

- **Reference Counting**

The number of times an object is referred by other objects in the system is counted by reference counting. The reference count for an object is decremented when references to it are removed. The object is deallocated when the reference count reaches zero.

**For example:**

*Let's consider the situation where two or more variables have the same value. The Python virtual machine makes the second variable point to the already existing value in the private heap, rather than creating another object with the same value in the private heap. As a result, having a large number of references in a class can consume a lot of memory; in this scenario, referencing counting is useful.*

```python
>>> x = 10
>>> id(x)
2033856768592
>>> # Because everything in Python is an object, when x = 10 is executed, 
>>> # an integer object 10 is generated in memory and 
>>> # its reference is set to variable x.
>>> y = x
>>>
>>> id(y)
2033856768592
>>>
>>> if id(x) == id(y):
...     print("x and y refer to the same object")
...
x and y refer to the same object
```

- **id() function** 

As can be seen, the function only takes one parameter and returns the object's identity. This identification must be unique and constant throughout the object's existence. The id() value of two objects with non-overlapping lives may be the same. If we compare this to C, they are the memory address; in Python, they are the unique id. In Python, this function is commonly used internally.
Because Python optimizes memory usage by allocating the same object reference to a new variable if the object already exists with the same value, y = x will construct another reference variable y that will refer to the same object.

- Now, let’s change the value of x and see what happens.

```python

>>> x = 10
>>> y = x
>>>
>>> id(x)
2033856768592
>>>
>>> id(y)
2033856768592
>>> x = 11
>>>
>>> id(x)
2033856768624
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