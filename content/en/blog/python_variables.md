---
author: "Navdeep Kaur"
title: "Variables in Python"
description: "This article covers the rules for Python variables and valid variable names. It explains how to use local variables and global variables in Python."
tags: ["python variables", "python scopes", "Local scope", "Global scope"]
date: 2022-01-20
thumbnail: https://deiniresendiz.com/wp-content/uploads/2020/06/Python.jpg
---

> This article offers the easy understanding of Python variables, valid variable names and difference between local variables & global variables.

<!--more-->

## Python Variables

A variable in Python is a memory place where a value can be stored. According to the requirements, the value you've saved may change in the future.

## Rules for assinging names to Python variables

- A variable name must start with a letter or the underscore character
- A variable name cannot start with a number
- A variable name can only contain alpha-numeric characters and underscores (A-z, 0-9, and _ )
- Variable names are case-sensitive (age, Age and AGE are three different variables)

**Legal variable names :**

- myvar = "David"
- my_var = "David"
- _my_var = "David"
- myVar = "David"
- MYVAR = "David"
- myvar2 = "David"

**Illegal variable names :**

- 2myvar = "David"
- my-var = "David"
- my var = "David"

## Local Variables vs Global variables

- **Local Variable :** 

Local variables are those which are defined inside a function and its scope is limited to that function only. In other words, we can say that local variables are accessible only inside the function in which it was initialized.

***Local Scope :** A variable created inside a function belongs to the local scope of that function, and can only be used inside that function.*

**For example :**

```python
# Creating local variables
# Example  (1)
>>> def fun():
...     st = "I Love Python"  # local variable
...     print("Inside function",st)
...
>>> fun() # calling function
Inside function I Love Python  # output

# Example  (2) 
# If we will try to use this local variable outside the function then let’s see what will happen.

>>> def fun():
...     st = "I Love Python"  # local variable
...     print("Inside function",st)
...
>>> fun() # calling function
Inside function I Love Python  # output

>>> print("Outside function:",st) # try to print outside function
NameError: name 'st' is not defined
```

- **Global Variable :** Global variables are those which are not defined inside any function and have a global scope. In other words, global variables are accessible throughout the program and inside every function. 

***Global Scope :** A variable created in the main body of the Python code is a global variable and belongs to the global scope.*

**For example :**

```python
>>> def fun():    
...     print("Inside function",st)
>>> st = "I Love Python"  # local variable

>>> fun() # calling function
Inside function I Love Python  # output

>>> print("Outside function:",st) # try to print variable outside function
Outside Function I Love Python
```

> **Note :** The variable 'st' is defined as the global variable and is used both inside the function as well as outside the function. As there are no locals, the value from the globals will be used.