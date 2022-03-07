---
author: "Navdeep Kaur"
title: "Python Dictionary"
description: "This article covers one of four built-in Python data structures for storing data collections through examples."
tags: ["python keywords", "python data types", "python dictionary"]
date: 2022-03-07
thumbnail: https://www.zigya.com/blog/wp-content/uploads/2021/02/valks-2.jpg
---

> A dictionary is an unsorted, changeable, and indexed collection. Curly brackets are used to write dictionaries in Python, and they have keys and values.

- Some dictionaries methods are explained below with outputs, Let's start with creating one dictionary.

```python

# 1.Create and print a dictionary
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2022
        }
>>> print(dt)
{'brand': 'Nissan', 'model': 'Altima', 'year': 2022} # Output

# 2.Get the value of the "model" key:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2022
        }
>>> x = dt["model"]
>>> print(x)
Altima # Output

# 3.Change the "year" to 2018:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2022
        }
>>> dt["year"] = 2018
>>> print(dt)
{'brand': 'Nissan', 'model': 'Altima', 'year': 2018} # Output: date changed

# 4.Print all key names in the dictionary, one by one:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2018
        }
>>> for x in dt:
...     print(x)
...
        # Below is Output
brand
model
year

# 5.You can also use the values() function to return values of a dictionary:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2018
        }
>>> for x in dt.values():
...     print(x)
...
Nissan
Altima
2018

# 6.Loop through both keys and values, by using the items() function:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2018
        }
>>> for x, y in dt.items():
...     print(x, y)
...
        # Below is Output
brand Nissan
model Altima
year 2018

# 7.Adding Items : Adding an item to the dictionary is done by using a new index key and assigning a value to it:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2018
        }
>>> dt["color"] = "red"
>>> print(dt)
{'brand': 'Nissan', 'model': 'Altima', 'year': 2018, 'color': 'red'} # Output

# 8.The pop() method removes the item with the specified key name:
>>> dt = {
        "brand": "Nissan",
        "model": "Altima",
        "year": 2018,
        "color": "red"
        }
>>> dt.pop("model")
>>> print(dt)
{'brand': 'Nissan', 'year': 2018, 'color': 'red'}

# 9.The del keyword removes the item with the specified key name:
>>> dt = {
        "brand": "Nissan",
        "year": 2018,
        "color": "red"
        }
>>> del dt["color"]
>>> print(dt)
{'brand': 'Nissan', 'year': 2018} # Output

# 10.The clear() method empties the dictionary:
>>> dt = {
        "brand": "Nissan",
        "year": 2018
        }
>>> dt.clear()
>>> print(dt)
{} # Output
```

- **Useful Dictionaries Methods**

  >- **clear()** Removes all the elements from the dictionary
  >- **copy()** Returns a copy of the dictionary
  >- **fromkeys()** Returns a dictionary with the specified keys and value
  >- **get()** Returns the value of the specified key
  >- **items()** Returns a list containing a tuple for each key value pair
  >- **keys(**) Returns a list containing the dictionary keys
  >- **pop()** Removes the element with the specified key
  >- **popitem()** Removes the last inserted key-value pair
  >- **setdefault()** Returns the value of the specified key. If the key does not exist: insert the key, with the specified value
  >- **update()** Updates the dictionary with the specified key-value pairs
  >- **values()** Returns a list of all the values in the dictionary
