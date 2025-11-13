---
author: "Navdeep Kaur"
title: "Python Expressions & assignment statements"
description: "The basics of Python are covered in this article, which includes Python expressions, operators, and assignment statements."
tags: ["python expressions", "assignment statements", "string operations"]
date: 2022-01-16
thumbnail: https://miro.medium.com/max/2000/1*Zipt5ex6sSVSkciwlJoG4Q.png
---

> This article offers the basics of Python, python expressions, operators, operations and assignment statements in python. It also covers basic python variables and data types.

<!--more-->

## **Python Expression**

- Expression is the most basic kind of programming instruction in the language. For example, in Python, 8 + 7 is called an expression. Expressions consist of values (such as  11) and operators (such as +), and they can always evaluate (that is, reduce) down to a single value.

- A single value with no operators is also considered as an expression, though it evaluates only to itself, as shown below:

```python
>>> 1
1
```

> Errors: Programs will crash if they contain code the computer can’t understand, which will cause Python to show an error message.

**For example:**

- Hello, How are you?
- Are, Hello you how?

The second line doesn’t follow the rules of English. Similarly, if you enter a bad Python instruction, Python won’t be able to understand it and will display a SyntaxError error message, as shown here:

```python
>>> 1 +
    File "<stdin>", line 1
    1 +
      ^
SyntaxError: invalid syntax
>>> 11 + 1 + * 1
    File "<stdin>", line 1
    11 + 1 + * 1
             ^
SyntaxError: invalid syntax
```

### **Math Operators from Highest to Lowest Precedence**

The ** operator is evaluated first; the *, /, //, and % operators are evaluated next, from left to right; and the + and - operators are evaluated last (also from left to right). You can use parentheses to override the usual precedence if you need to.

## **Data Types**

A data type is a category for values, and every value belongs to exactly one data type.

**Common Data Types:**

| Data type | Examples |
|-----------|----------|
| Integers  | -1, 0, 1 |
| Floating-point numbers | -1.0, 0.0, 1.0 |
| Strings  | 'a', 'Hello!', '11 candies'|

**For example:**

- The values -1 and 11, are said to be integer values. The integer (or int) data type indicates values that are whole numbers.
- Numbers with a decimal point, such as 1.11, are called floating-point numbers (or floats). Even the value 1.0 would be a floating-point number.
- In python string are always surrounded by single quote (') or double quotes (") as in 'Hello'. String can be with no characters in it, '', called a blank string or an empty string.

**String operations:**

- Concatenation

`+` is used on two string values to joins the strings as the string concatenation operator.

**For example:**

```python
>>> 'Joy' + 'Shen'
'JoyShen'
```

> Note : can only concatenate str (not "int") to str

- Replication

The `*` operator can be used with only two numeric values (for multiplication), or one string value and one integer value (for string replication).

**For example:**

```python
>>>'Joy' *35
'JoyJoyJoy'
```

> Note : String replication is not used as often as string concatenation. Python will just display an error message, like the following:

```python
>>> 'Joy' * 'Shen'
Traceback (most recent call last):
File "<pyshell#32>", line 1, in <module>
    'Joy' * 'Shen'
"TypeError: can't multiply sequence by non-int of type 'str'"
>>> 'Joy' * 3.0
Traceback (most recent call last):
File "<pyshell#33>", line 1, in <module>
    'Joy' * 3.0
"TypeError: can't multiply sequence by non-int of type 'float'"
```

## **Assignment Statements**

An assignment statement consists of a variable name, an equal sign (called the assignment operator), and the value to be stored. If you enter the assignment statement elem = 11, then a variable named elem will have the integer value 11 stored in it.

**For example:**

```python
>>> elem = 11
>>> elem
11
>>> candies = 1
>>> elem + candies
12
>>> elem = elem + 1
>>> elem
11
```

**Variable names:**

| Valid variable names | Invalid variable names |
|----------------------|-------------------------|
| _11 | 11 (can’t begin with a number) |
| ACC_BAL | ACC_$al (special characters like $ are not allowed) |
| hello |  'hello' (special characters like ' are not allowed) |
| acc_bal | acc-balance (hyphens are not allowed)|
| accBalance | acc balance (spaces are not allowed) |
| elem4 | 4elem (can’t begin with a number) |

## **Program to print "Hello World" and ask for information such as name**

```python
>>> print('Hello, world!')
>>> print('What is your name?')    # ask for their name
>>> myName = input()    # for taking input as a string
>>> print('It is good to meet you, ' + myName) 
>>> print('The length of your name is:')
>>> print(len(myName))    # to check length of string
>>> print('What is your age?')    # ask for their age
>>> myAge = int(input())     # for taking input as integer
>>> print('You will be ' + str(myAge + 1) + ' in a year.')
```

**Comments:**

- Python ignores comments, and you can use them to write notes or remind yourself what the code is trying to do. It should start with '#'.

**print() Function:**

- The print() function displays the string value inside its parentheses on the screen.

**input() Function:**

- The input() function waits for the user to type some text on the keyboard and press ENTER.

**len() Function:**

- The function evaluates to the integer value of the number of characters in that string.
