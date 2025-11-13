---
author: "Navdeep Kaur"
title: "Learn basic list methods in Python"
description: "With some examples, this article explains the one of four built-in Python data structures for storing collections of data."
tags: ["Data structures","Python Lists"]
date: 2022-02-19
thumbnail: https://onestopdataanalysis.com/wp-content/uploads/2020/01/Python-List.png
---

> Multiple items can be stored in a single variable using lists. Lists are one of four built-in Python data structures for storing collections of data; the other three are Tuple, Set, and Dictionary, all of which have different properties and applications. In Python lists are written with square brackets.

**Basics of list in Python**

```python

# 1.Create list
>>> ls = ["apple", "orange", "cherry"]
>>> print(ls)
['apple', 'orange', 'cherry'] # Output

# 2. Access items
>>> ls = ["apple", "orange", "cherry"]
>>> print(ls[1])
orange # Output

# 3. Negative indexing
>>> ls = ["apple", "orange", "cherry"]
>>> print(ls[-1])
cherry # Output

# 4. Range
>>> ls = ["apple", "orange", "cherry", "banana", "kiwi", "melon", "mango"]
>>> print(ls[2:5])
['cherry', 'banana', 'kiwi'] # Output
# NOTE : The search will start at index 2 (included) and end at index 5 (not included).

# 5. By leaving out the start value, the range will start at the first item :
>>> ls = ["apple", "orange", "cherry", "banana", "kiwi", "melon", "mango"]
>>> print(ls[:4])
['apple', 'orange', 'cherry', 'banana'] # Output

# 6. By leaving out the end value, the range will go on to the end of the list :
>>> ls = ["apple", "orange", "cherry", "banana", "kiwi", "melon", "mango"]
>>> print(ls[2:])
['cherry', 'banana', 'kiwi', 'melon', 'mango'] # Output

# 7. Change Item Value
>>> ls = ["apple", "orange", "cherry"]
>>> ls[1] = "blackcurrant"
>>> print(ls)
['apple', 'blackcurrant', 'cherry'] # Output

# 8. Loop Through a List : You can loop through the list items by using a for loop.
>>> ls = ["apple", "blackcurrant", "cherry"]
>>> for x in ls:
...    print(x)
...
apple # Output 
blackcurrant # Output
cherry  # Output

# 9. Check if Item Exists : To determine if a specified item is present in a list use the in keyword

>>> ls = ["apple", "orange", "cherry"]
>>> if "apple" in ls:
...     print("Yes, 'apple' is in the fruits list")
...
Yes, 'apple' is in the fruits list # Output

# 10. Check Length
>>> ls = ["apple", "orange", "cherry"]
>>> print(len(ls))
3 # Output
```

## List Methods with examples

```python

# Using the append() method to append an item :
>>> ls = ["apple", "orange", "cherry"]
>>> ls.append("banana")
>>> print(ls)
['apple', 'orange', 'cherry', 'banana'] # Output

# To add an item at the specified index, use the insert() method :
>>> ls = ["apple", "orange", "cherry"]
>>> ls.insert(1, "banana")
>>> print(ls)
['apple', 'banana', 'orange', 'cherry'] # Output

# The remove() method removes the specified item :
>>> ls = ["apple", "orange", "cherry"]
>>> ls.remove("orange")
>>> print(ls)
['apple', 'cherry'] # Output

# The pop() method removes the specified index, (or the last item if index is not specified):
>>> ls = ["apple", "orange", "cherry"]
>>> ls.pop()
'cherry'
>>> print(ls)
['apple', 'orange'] # Output

# The del keyword removes the specified index:
>>> ls = ["apple", "orange", "cherry"]
>>> del ls[0]
>>> print(ls)
['orange', 'cherry'] # Output

# The clear() method empties the list:
>>> ls = ["apple", "orange", "cherry"]
>>> ls.clear()
>>> print(ls)
[] # Output

# copy the list
>>> ls = ["apple", "orange", "cherry"]
>>> mylist = ls.copy()
>>> print(mylist)
['apple', 'orange', 'cherry'] # Output

# Join two list
>>> ls1 = ["a", "b" , "c"]
>>> ls2 = [1, 2, 3]
>>> ls3 = ls1 + ls2
>>> print(ls3)
['a', 'b', 'c', 1, 2, 3]  # Output

# Append list2 into list1:
>>> ls1 = ["a", "b" , "c"]
>>> ls2 = [1, 2, 3]
>>> for x in ls2:
...     ls1.append(x)
...
>>> print(ls1)
['a', 'b', 'c', 1, 2, 3] # Output

# Use the extend() method to add list2 at the end of list1:**
>>> ls1 = ["a", "b" , "c"]
>>> ls2 = [1, 2, 3]
>>> ls1.extend(ls2)
>>> print(ls1)
['a', 'b', 'c', 1, 2, 3] # Output
```

## Notable Lists methods

> - **append() :** Adds an element at the end of the list
> - **clear() :** Removes all the elements from the list
> - **copy() :** Returns a copy of the list
> - **count() :** Returns the number of elements with the specified value
> - **extend() :** Add the elements of a list (or any iterable), to the end of the current list
> - **index() :** Returns the index of the first element with the specified value
> - **insert() :** Adds an element at the specified position
> - **pop() :** Removes the element at the specified position
> - **remove() :** Removes the item with the specified value
> - **reverse() :** Reverses the order of the list
> - **sort() :** Sorts the list