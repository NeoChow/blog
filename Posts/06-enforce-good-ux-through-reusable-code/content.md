A few weeks ago I wrote [UX and Agile](/posts/2013/01/22/ux-and-agile) about how UX designers can better integrate into the Agile process. The main point that I made is that programmers and designers should work more closely together because there is a lot that the disciplines can do to help one another. One way that programming techniques can support good UX design and UX design can make programming quicker is through reusable code and UX components. Using reusable components is good for solo developers responsible for both UX and programming as well as for teams trying to work better together.

Creating reusable components is one place where UX designers and programmers can definitely agree. Reusable components are great for programming because it means less code and higher maintainability. If a change needs to be made to a component all over the app it can be done in one place instead of many. Reusable components are great for UX because it enforces consistency so users have to learn fewer things. It is also good to force designers to be really deliberate if they are going to deviate from a common pattern.

**Programmers and designers should work together to create a collection of components for their project for all graphic components and interactions.**

A Library of Components and Interactions
=========================

Types of buttons and assets for how they look in each of their states
------------
1. Action buttons
2. Toggle buttons
3. Information buttons
4. ...

Description of different types of transitions and how they should look
--------------

1. Present details
2. Present tangental information
3. Paging
4. Pop-ups
5. ...

Error conditions and how the user should be alerted
--------------
1. Form errors
2. Network errors
3. Unknown errors
4. ...

Types of text with their font, size, and style
------------------
1. Headings
2. Paragraphs
3. Links
4. Errors
5. ...

The elements in a library will vary depending on the the type of project and the size of it but the spirit should be the same. It should be well understood how each element will look and how it will interact with users. Every element should be generic enough to be used in many places. Strong consideration should be made whenever modifying the library or adding to it.

Questions to ask when creating a new Component or Interaction
=======================================

1. Can an existing element be used instead?
2. What problem is this element solving?
3. Is there an existing paradigm in your type of project to solve the problem at hand?
4. Can this element be described in a few words or a short sentence?
5. Are there 3 or more places to use this component?

Useful for Graphic Designers, UX Designers, and Programmers Alike
==========================================

For graphic designers this library will serve as a style guide; for UX designers this library will serve as an interaction repository; and for programmers this library will translate to classes and factories.

**For the library to be effective everyone must work with it.** Programmers shouldn't code up something without going through the consideration above and adding it to the library. Otherwise the app will lose the usability and consistency the designers have defined for it. Graphic designers should not create a special component or else the usability will suffer and much more work will be created for the programmers. UX designers should not add many one-time-use components otherwise they will create much more graphic and programming work.
