---
author: "Navdeep Kaur"
title: "Python Keywords"
description: "This article refers to python reseved keywords, as well as several popular python data types and how to locate data type."
tags: ["python keywords", "python data types"]
date: 2022-01-18
thumbnail: https://core-electronics.com.au/media/wysiwyg/tutorials/Tim/Speed2/cropped-phillipino-phipped-image-2.jpg
---

> Hello everyone, here is the article offering the python reserved keywords and some common python data types and how to find data type.

<!--more-->

*Python has a set of keywords that are reserved words that cannot be used as variable names, function names, or any other identifiers.*

## **Keyword Description**

> - **and :** A logical operator
> - **as :** To create an alias
> - **assert :** For debugging
> - **break :** To break out of a loop
> - **class :** To define a class
> - **continue :** To continue to the next iteration of a loop
> - **def :** To define a function
> - **del :** To delete an object
> - **elif :** Used in conditional statements, same as else if
> - **else :** Used in conditional statements
> - **except :** Used with exceptions, what to do when an exception occurs
> - **False :** Boolean value, result of comparison operations
> - **finally :** Used with exceptions, a block of code that will be executed no matter if there is an exception or not
> - **for :** To create a for loop
> - **from :** To import specific parts of a module
> - **global :** To declare a global variable
> - **if :** To make a conditional statement
> - **import :** To import a module
> - **in :** To check if a value is present in a list, tuple, etc.
> - **is :** To test if two variables are equal
> - **lambda :** To create an anonymous function
> - **None :** Represents a null value
> - **nonlocal :** To declare a non-local variable
> - **not :** A logical operator
> - **or :** A logical operator
> - **pass :** A null statement, a statement that will do nothing
> - **raise :** To raise an exception
> - **return :** To exit a function and return a value
> - **True :** Boolean value, result of comparison operations
> - **try :** To make a try...except statement
> - **while :** To create a while loop
> - **with :** Used to simplify exception handling
> - **yield :** To end a function, returns a generator

## **Python Data Types**

*A data type is a category for values, and every value belongs to exactly one data type.*

**Common Data Types:**

| Data type | Examples |
|-----------|----------|
| Integers  | -1, 0, 1 |
| Floating-point numbers | -1.0, 0.0, 1.0 |
| Strings  | 'a', 'Hello!', '11 candies'|

*Python has the following **built-in data types** by default, in these categories :*

- *Text Type :* str
- *Numeric Types :* int, float, complex
- *Sequence Types :* list, tuple, range
- *Set Types :* set, frozenset
- *Mapping Type :* dict
- *Boolean Type :* bool
- *Binary Types :* bytes, bytearray, memoryview

## **Getting the Datatype**

*Datatype of any object can be printed by using the type() function.*

**For Example :** Find the datatype using 'type()'

```python
>>> x = 5
>>> type(x)  # to check the data type of x.
<class 'int'> # Output
>>>
>>> st = "Hello"
>>> type(st)  # to check the data type of st.
<class 'str'>   # Output
>>>
>>> y = 5.5
>>> type(y)  # to check the data type of y.
<class 'float'>  # Output 
>>>


```
