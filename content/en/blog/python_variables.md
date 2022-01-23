---
author: "Navdeep Kaur"
title: "Python Variables"
description: "The rules for Python variables, proper variable names, and python scope are all covered in this article."
tags: ["python variables", "python scopes", "Local scope", "Global scope"]
date: 2022-01-20
thumbnail: https://deiniresendiz.com/wp-content/uploads/2020/06/Python.jpg
---

> This article offers the rules for Python variables, valid variable names and python scope.

<!--more-->

## Variable Names

*A variable can have a short name (like x and y) or a more descriptive name (age, carname, total_volume).*

## Rules for Python variables

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

## Python Scope

*A variable is only available from inside the region it is created. This is called scope*.

**Local Scope :** A variable created inside a function belongs to the local scope of that function, and can only be used inside that function.

- **Local Variable :** The local variable can be accessed from a function within the function :

**Example :**

```python
def my_func():
    x = 50
    def my_innerfunc():
    print(x)
    my_innerfunc()
my_func()
```

**Global Scope :** A variable created in the main body of the Python code is a global variable and belongs to the global scope.

- **Global Variable :** Global variables are available from within any scope, global and local.

**Example :**

```python
x = 50
def my_func():
    print(x)
my_func()
print(x)
```
