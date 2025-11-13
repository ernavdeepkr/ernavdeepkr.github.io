---
author: "Navdeep Kaur"
title: "Python Strings and some common string operations"
description: "The python strings are discussed in this article. A string is a collection of characters in Python. Many Python methods are also included here in this post"
tags: ["python string"]
date: 2022-02-16
thumbnail: https://miro.medium.com/max/1400/1*q8gcsJSpJXurkWSBszlt3w.png
---

> This article is related to the python strings. In Python, a string is a collection of characters. It is a derived data type. Many Python methods, such as replace , join , or split modify strings.

<!--more-->

**1. What is the Syntax for the strings ?**

- use single or double quotation for string.

**For example :**

```python
>>> my_name = "XYZ"
>>> my_name
'XYZ' # Output

# or 

>>> my_name = 'XYZ'
>>> my_name
'XYZ' # Output

# both are same.
```

**2. How to Print string ?**

```python
>>> print("Hello")
Hello # Output

>>> print('Hello')
Hello # Output
```

**3. What are Escape Characters ?**

An escape character allows you to insert characters into a string that would be otherwise impossible.

```python
>>> spam = 'Say hello to Riya\'s father.'

>>> spam
"Say hello to Riya's father." # Output
```

```python
Escape character    |    Print as   
------------------------------------     
     \'                  Single quote     
     \"                  Double quote     
     \t                  Tab              
     \n                  Newline (line break)
     \\                  Backslash        
```

**4. Define Raw Strings ?**

Place an "r" before the beginning quotation mark of a string to make it a raw string. A raw string completely ignores all **escape characters** and prints any backslash that appears in the string.

```python
>>> print(r'That is David\'s bag.')

That is David\'s bag. # Output

# output will remane same and will ignore escape character.
```

**5. Discuss how to put Strings Inside Other Strings ?**

```python
>>> name = 'David'
>>> age = 35
>>>
>>> print('Hello, my name is ' + name + '. I am ' + str(age) + ' years old.')

Hello, my name is david. I am 3 years old. # output

# we can put strings inside the strings in this way 
```

**6. What is String interpolation ?**

A simpler approach is to use string interpolation, in which the %s operator inside the string acts as a marker to be replaced by values following the string.

```python
>>> name = 'David'
>>> age = 35
>>> print('My name is %s. I am %s years old.' % (name, age))

My name is David. I am 35 years old. # Output
```

**7. What are f-strings ?**

It's similar to string interpolation, but instead of percents, braces are used, and the expressions are placed immediately inside the braces. F-strings, like raw strings, contain a f prefix before the first quote mark.

```python
>>> name = 'David'
>>> age = 35
>>> print(f'My name is {name}. Next year I will be {age + 1}.')

My name is david. Next year I will be 4. # Output

```

**8. How to assign string to variable ?**

```python
>>> a = "Hello"
>>> print(a)

Hello # Output
```

**9. Example of Multiline string :**

```python
>>> a = """It is the simplest method
          to let a long string split into different lines. You will need to enclose it
          with a pair of Triple quotes"""
>>> print(a)

It is the simplest method
          to let a long string split into different lines. You will need to enclose it
          with a pair of Triple quotes  # Output
```

**10. Slicing the string :**

```python
>>> b = "Hello, World!"
>>> print(b[2:5])

llo # Output
```

**12. Negative indexing :**

```python
>>> b = "Hello, World!"
>>> print(b[-4:-2])

rl # Output
```

**13. String length :**

```python
>>> a = "Hello, World!"
>>> print(len(a))

13 # Output
```

**14. Check presence of the string :**
  
```python
>>> txt = "This is a method to check the presence of some string."
>>> x = "ence" in txt # to check if it is present in string
>>> print(x)

True  # Output

>>> txt = "This is a method to check the presence of some string."
>>> x = "ence" not in txt # to check if it is not present in string
>>> print(x)

False # Output 
```

**15. String concatination :**
  
```python
>>> a = "Hello"
>>> b = "World"
>>> c = a + b
>>> print(c)

HelloWorld # Output
```

**16. String format() :**

The format() method allows you to format selected parts of a string.

- **Use the format() method to insert numbers into string :**

The format() method takes the passed arguments, formats them, and places them in the string where the placeholders {} are

  ```python
  >>> age = 34
  >>> txt = "My name is Nik, and I am {}"
  >>> print(txt.format(age))

  My name is Nik, and I am 34 # Output
  ```

- **Format the price to be displayed as a number with two decimals**

  ```python
  >>> price = 50
  >>> txt = "The price is {:.2f} dollars"
  >>> print(txt.format(price))

  The price is 50.00 dollars # Output
  ```

**17. Multiple Values :**

If you want to use more values, just add more values to the format() method.

  ```python
  >>> quantity = 5
  >>> itemno = 127
  >>> price = 50
  >>> myorder = "I want {} pieces of item number {} for {:.2f} dollars."
  >>> print(myorder.format(quantity, itemno, price))
  
  I want 5 pieces of item number 127 for 50.00 dollars.
  ```

**18. Index Numbers :**

- You can use index numbers to be sure the values are placed in the correct placeholders
  
  ```python
  >>> age = 40
  >>> name = "David"
  >>> txt = "His name is {1}. {1} is {0} years old."
  >>> print(txt.format(age, name))

  His name is David. David is 40 years old. # Output
  ```

- You can also use named indexes by entering a name inside the curly brackets {carname}, but then you must use names when you pass the parameter values txt.format(carname = "Ford")
  
  ```python
  >>> myorder = "I have a {carname}, it is a {model}."
  >>> print(myorder.format(carname = "Ford", model = "Mustang"))
  
  I have a Ford, it is a Mustang. # Output
  ```

## Useful String Methods

```python
# strip() 
>>> a = " Hello, World! "
>>> print(a.strip()) # It removes spaces outside string.

Hello, World! # Output

# lower() 
>>> a = "Hello, World!"
>>> print(a.lower())

hello, world! # Output

# upper()
>>> a = "Hello, World!"
>>> print(a.upper())

HELLO, WORLD! # Output

# replace()
>>> a = "Hello, World!"
>>> print(a.replace("W", "J"))

Hello, Jorld! # Output

# split()
>>> a = "Hello, World!"
>>> print(a.split(",")) # returns ['Hello', ' World!']

['Hello', ' World!'] # Output after using split

# join() : The join() method is useful when you have a list of strings that need to be joined together into a single string value.

>>> print(', '.join(['cats', 'rats', 'bats']))

cats, rats, bats # Output after using join method

>>> print(' '.join(['My', 'name', 'is', 'Kevy']))

My name is Kevy  # Output 

>>> print('ABC'.join(['My', 'name', 'is', 'Kevy']))

MyABCnameABCisABCKevy # Output
```
