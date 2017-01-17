**Note To New Programmers:** At this time I do not recommend learning Swift as your first language. It is still a very young language and therefore the resources and communities around it are not robust enough to allow it to be an effective first language. Also, the language itself is still buggy and in flux. When learning your first language, you want to be sure all problems are your fault and not potentially the fault of the technology you are using. This assumption can be made with more mature languages but not Swift yet. Instead, if you still want to start with iOS and/or OS X development, I recommend starting with Objective-C.

Read Apple’s Documentation
-------------

Before doing anything else, if you are truly serious about learning Swift and you are already familiar with other programming languages, Apple has already provided some great documentation for learning Swift:

- [The Swift Programming Language](https://itunes.apple.com/us/book/swift-programming-language/id881256329?mt=11) - A must read
- [Using Swift with Cocoa and Objective-C](https://itunes.apple.com/us/book/using-swift-cocoa-objective/id888894773?mt=11)

Key Concepts
-------------

There are a few key concepts that I think are extremely important to learn that I want to highlight.

### Optionals

Optionals are really important because variables cannot ever lack a value in Swift but it is still valuable to be able to represent a variable that can have *no value* or *nil*. It is also one of the biggest barriers to learning how to interact with Objective-C APIs and Apple’s frameworks because many variables in Objective-C are pointers meaning they can be *nil*. Optionals must be used in those cases.

You need to understand what an Optional is, how to check if it is *nil*, and how to “unwrap” it to access the actual value if it is not *nil*.

- [What is An Optional In Swift](/posts/what-is-an-optional-in-swift)
- [Uses for Implicitly Unwrapped Optionals](/posts/2014/07/05/uses-for-implicitly-unwrapped-optionals-in-swift)

### Constants v.s. Variables

There are two ways to declare a value in Swift. You can use `let` to indicate a constant and `var` to indicate a variable. You should always use `let` unless you have a reason to change a stored value.

- [Constants and Variables (Apple)](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_399)

### Initialization

Initialization is much more restrictive in Swift than many other languages. There are more complicated rules around what order things must be initialized in and what variables must be set in an initializer. There is also a compiler made distinction between **designated initializers** and **convenience initializers**.

- [Initialization (Apple)](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html#//apple_ref/doc/uid/TP40014097-CH18-XID_265)

### Automatic Reference Counting (ARC)

Memory management is not completely automatic in Swift. You still need to understand that there are different ownership relationships between objects. Most notably, you need to understand enough to prevent [reference cycles in classes](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_54) and [reference cycles in closures](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_62).

- [Automatic Reference Counting (Apple)](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_50)

### Value and Reference Types

In Swift, there are two forms of types: [Value Types](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-XID_105) and [Reference Types](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-XID_106). It is important that you understand the difference between them so that you can [appropriately decide when to use each](http://www.reddit.com/r/swift/comments/2a5mff/i_still_dont_understand_the_difference_between/cirpdxn).

### Generics

If you are not familiar with Generics from another language like C++, it can be hard to wrap you head around this change form Objective-C. In Objective-C it is common to use containers that store very generic types like `id`. Swift [makes these containers safer using generics](/posts/2014/06/29/7-cool-features-in-swift#keeps-your-collections-safe-and-clear).

- [Generics (Apple)]((https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_232)

Follow Swift Tag on Stack Overflow
-------------

I have found it very valuable to follow the [Swift tag on Stack Overflow](http://stackoverflow.com/questions/tagged/swift). It is really great to see real world problems and solutions instead of the theoretical ones in a lot of documentation. It is even more valuable if you answer questions. Most people learn much better by doing and it is also really helpful to be forced to put your ideas into writing.

Follow Blogs
-------------

There are a few really great blogs that have cropped up already:

- [Drewag (This Blog)](https://drewag.me) - A shameless plug for this blog. I will not be writing exclusively about Swift, but I plan to concentrate pretty heavily on it
- [Erica Sadun](http://ericasadun.com) - Many great posts about Swift
- [Practical Swift](http://practicalswift.com) - A blog dedicated to Swift

Listen To Podcasts
-------------

Podcasts give you a sense of the community and a constant learning opportunity. They are also great for learning while doing boring tasks like house work and driving. I have not found any dedicated Swift podcasts yet, but all of the following podcasts discuss Swift periodically and it is still valuable to keep up with what is happening in the Apple development world.

### General News and Discussion
- [Core Intuition](http://www.coreint.org)
- [Accidental Tech Podcast](http://atp.fm)
- [The Prompt](http://5by5.tv/prompt)

### Technical
- [Mobile Couch](http://jellystyle.com/podcasts/mobilecouch)
- [Developing Perspective](http://developingperspective.com)
- [Debug](http://www.imore.com/debug)
- [Edge Cases](http://edgecasesshow.com)
- [iDeveloper](http://ideveloper.tv)
- [NSBrief](http://nsbrief.com)

### Specific Episodes

- [Accidental Tech Podcast - 68 Siracusa Waited Impatiently for This](http://atp.fm/?offset=1402690818053) - Early discussion of Swift starting around 70:44
- [Edge Cases - 92 Edge Cases Live](http://edgecasesshow.com/092-edge-cases-live.html) - Another early discussion of Swift starting around 22:28
- [Edge Cases - 99 Swift is a really good thing and a step back](http://edgecasesshow.com/099-swift-is-a-really-good-thing-and-a-step-back.html) - Great discussion on how Swift is both a step forward and potentially a step backward
- [Core Intuition - 145 An Element of Academic-ness](http://www.coreint.org/2014/07/episode-145-an-element-of-academic-ness/) - Great perspective on making sure Swift is practical
- [Mobile Couch - 34 Tuples, Chuples, Twooples](http://jellystyle.com/podcasts/mobilecouch/34) - Details on what is new about Swift
- [iDeveloper - 120 Move Swiftly On or Stay Objective?](http://ideveloper.tv/2014/7/1/120) - Discussion around when to adopt Swift
- [NSBrief - 126 Swift Grudge Match](http://nsbrief.com/126-ash-furrow/)
