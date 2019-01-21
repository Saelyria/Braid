#  Sample 5 - Dynamic Home Page

## Overview

This sample demonstrates how to use a struct instead of an enum to support dynamically-created section data. The view in this sample is a
'home page' for a shopping app. What we show on our home page is given to us in a mock server response (from our mock `HomeService`).
We can be told by the 'server' to show sections containing cells showing either `Product`s or `Store`s. These sections could be things like 
'Recommended for you', 'Stores nearby', or 'Recently purchased'. Dynamic section data like this could be a common requirement for a large
commercial application where exactly what gets shown is very customer-dependant. And, since it's not known at compile time, we can't use
an enum for our sections - instead, we'll build a `Section` struct.

## Walkthrough

1. 

