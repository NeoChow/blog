The biggest feature from Objective-C that I miss in Swift is [Key Value Observing (KVO)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html). Technically this is a feature of Foundation, not Objective-C, but it depends on the dynamism of Objective-C that Swift does not have (at least yet). As a programmer, the dynamic nature of Objective-C is very fun to play with, but I am hesitant to say that it should definitely be added to Swift. This feature of Objective-C helped us solve a few key problems, KVO being one of them, and I’d like to see if we can solve those problems in a different way in Swift without having to complicate Swift with dynamism. It may even force us to find even better solutions. The first step for me, was a way to recreate KVO in Swift.

The Idea
-------

I decided to create a class called `Observable` that would be defined in a  similar way to an [Optional](http://drewag.me/posts/what-is-an-optional-in-swift) allowing one to “wrap” a value to make it observable. The observable wrapper would provide a mechanism to subscribe to value changes and then use [Property Observers](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_332) to trigger the notifications.

I am not a fan of using the [Delegate Design Pattern](https://developer.apple.com/library/ios/documentation/general/conceptual/DevPedia-CocoaCore/Delegation.html) for KVO because I feel that it spreads the logic of a specific observation out in the class making the code harder to understand and it can also create very lengthy delegate callback methods when observing multiple things. I prefer to define it right in place so I wanted to use closures instead.

My first attempt at writing an interface for this object looked like this:

    // swift
    class Observable<ValueType> {
        typealias DidChangeHandler = (oldValue: ValueType, newValue: ValueType) -> ()

        var value : ValueType

        func addObserver(handler: DidChangeHandler) {
            // ..
        }
    }

This is simple and clean. I made it a class instead of a struct so that the value could be updated easily without worrying about mutability. Since Swift allows one to provide a closure outside the method call, adding an observer would be as simple as:

    // swift
    observable.addObserver { (oldValue, newValue) in
        // do something with oldValue and / or newValue
    }

However, I quickly realized there is a problem: how would one remove an observer? I had two thoughts on how to solve this problem:

1. I could return some sort of observer handle from the `addObserver` method that would be used to stop the observation
2. I could let the user provide some sort of key to be used later for removing the observer

I decided that returning a handle didn’t feel very modern — it feels more like C to me. Also, handles would require a bunch of code overhead in every class that has observers to track those handles. For keys, I considered making the key be a second template type called `KeyType` but I quickly realized that this would require the class defining the observable to set a specific key type and would not leave the freedom to the observing class. I then considered making the key a string. This would be a similar paradigm to reuse identifiers on table cells. However, I often find the use of reuse identifiers repetitive and cumbersome to use, usually requiring a global string constant somewhere.

I decided to let the key be `AnyObject` which would allow me to use the identical operator (`===`) to compare different keys and most of the time users could use `self` as the key. I would not be able to hash the values which could be a performance hit, but in most use cases, there will not be many observers and iterating through keys should be fine (and potentially better considering the overhead of creating a hash table).

I also decided to add a parameter to the `addObserver` method that would allow the user to decide if they wanted the closure to be triggered immediately with the current value. This meant that I need to make the `oldValue` an optional because I would not have an old value in that case.

This process lead me to my final concept.

The Final Concept
-------

The final interface for my `Observable` class looks like this:

    // swift
    class Observable<ValueType> {
        typealias DidChangeHandler = (oldValue: ValueType?, newValue: ValueType) -> ()

        var value : ValueType
        init(_ value: ValueType) {
            self.value = value
        }

        func addObserverForOwner(
            owner: AnyObject,
            triggerImmediately: Bool,
            handler: DidChangeHandler
            )
        {
            // ..
        }

        func removeObserversForOwner(owner: AnyObject) {
            // ..
        }
    }

Now the user can provide an owner so that they can remove the observer later using `removeObserversForOwner:`.

With this interface, a class declares an observable property like so:

    // swift
    class Foo {
        var observableNumber = Observable(0)
    }

Any other class can then start and stop observing the value changing like so:

    // swift
    func startObserving() {
        var myFoo = Foo()
        myFoo.addObserverForOwner(self, true) { (oldValue, newValue) {
            // do something with oldValue and / or newValue
        }
    }

    func stopObserving() {
        myFoo.removeObserversForOwner(self)
    }

An observable variable can have an unlimited number of observers from an unlimited number of owners (ignoring eventual performance issues).

The Implementation
-------

Once I came up with the interface of how I wanted the class to work, the implementation was relatively easy. First I needed a way to store the observers. I decided on a private array of [tuples](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_425) containing the owner and an array of handlers for that owner. I also decided to create a private method that would let me easily get the index of an owner in that private array.

This left me with the following private code:

    // swift
    // Mark: Private Properties

    var _observers: [(owner: AnyObject, handlers: [DidChangeHandler])] = []

    // Mark: Private Methods

    func _indexOfOwner(owner: AnyObject) -> Int? {
        var index : Int = 0
        for (possibleOwner, handlers) in self._observers {
            if possibleOwner === owner {
                return index
            }
            index++
        }
        return nil
    }

Now, I could easily implement the `addObserverForOwner:triggerImmediately:handler` method:

    // swift
    func addObserverForOwner(
        owner: AnyObject,
        triggerImmediately: Bool,
        handler: DidChangeHandler
        )
    {
        if let index = self._indexOfOwner(owner) {
            // since the owner exists, add the handler to the existing array
            self._observers[index].handlers.append(handler)
        }
        else {
            // since the owner does not already exist, add a new tuple with the
            // owner and an array with the handler
            self._observers.append(owner: owner, handlers: [handler])
        }

        if (triggerImmediately) {
            // Trigger the handler immediately since it was requested
            handler(oldValue: nil, newValue: self.value)
        }
    }

Implementing the `removeObserverForOwner:` was even easier:

    // swift
    func removeObserversForOwner(owner: AnyObject) {
        if let index = self._indexOfOwner(owner) {
            self._observers.removeAtIndex(index)
        }
    }

This left just the implementation of actually calling the callbacks. As I wanted to in the beginning, I could just use a [Property Observer](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_332) and loop through all of the handlers calling one at a time:

    // swift
    var value : ValueType {
        didSet {
            for (owner, handlers) in self._observers {
                for handler in handlers {
                    handler(oldValue: oldValue, newValue: value)
                }
            }
        }
    }

Now I have a fully functioning observation model built purely in Swift.

To see the complete code, you can look on my project on [Github drewag/SwiftPlusPlus](https://github.com/drewag/SwiftPlusPlus/blob/master/SwiftPlusPlus/Observable.swift).

The Evaluation
-------

Unfortunately this solution is not perfect, so I would like to layout some of the pros and cons of this implementation.

### Pros

There are actually a few things that I like better about this implementation than KVO in Foundation:

- **Explicit as to what properties are observable** - In standard KVO, it is only clear from documentation or experimentation which properties actually trigger KVO notifications. This method makes it immediately obvious to the consumers of an API
- **Closures make code more clear than callbacks** - As I discussed earlier, I think using closures makes code more understandable by localizing the logic to the place where you are setting up what is being observed. Also, because functions are first-class citizens in Swift, you could also pass a function or method as the callback if you prefer.
- **Simple to make an observable property** - All one must do is define the property as an observable. Any time they change the value, the handlers will be called automatically.

### Cons

- **Always manipulating `value`** - Whenever trying to access or change the value of an observable property, one must always do so using the `value` property of the observable wrapper. This muddles all of the code with the impertinent knowledge that this property is observable and makes it more work to convert a property to being observable.
- **Requires Manually Unobserving** - Using [Associated Objects](http://nshipster.com/associated-objects/) in Objective-C, I was able to provide [my own wrapper for KVO](posts/objective-c-bindings) that removed the need to manually stop observing the object, it would automatically stop observing when the observed object got deallocated. So far I cannot think of a way to make this work in Swift and will mean a bunch of boilerplate code in the `deinit` method most likely.

The Future
-------

### Observable Calculated Values

Sometimes it is preferable to have a calculated value instead of a stored value that an external class can observe. The current class that I created does not allow this. One possible way to add this would be to create a different observer class that uses a closure instead of a static value (this would probably involve extracting  superclass with some common functionality). I also want to play around with `auto_closure` to see if that would be useful.

At the moment, I don’t see any major roadblocks to implementing this.

### Ordered Collection Support

KVO also has callbacks for when collections are modified. I would like to add support for this as well. The user would have to be able to observer insertions and deletions as well as complete changes to the variable. The biggest interface decision is whether it would be best to use separate observations for each type or if every observer should be forced to handle all of those potential modifications.

The biggest technical problem with implementing this is detecting and properly identifying the insertions and deletions on the collections.

### Syntactic Sugar from Apple

I am not a big fan of syntactic sugar as it can create confusion for many programmers. Optionals are a perfect example because many people are confused by optionals. I find it helpful to explain to new Swift programmers that optionals are in fact just enums. However, for patterns like optionals, that are used all over the place, some extra help from the compiler to remove syntax overhead of a feature can be great.

I would love the ability to remove a lot of the overhead around my Observable class by being able to implicitly convert an observable to the value contained within it like it is with optionals. Instead of requiring the user to always access the value through the `value` property, all interactions with the observable would be forwarded to the internal value. This would mean that converting a property to an observable would require no code modification other than the declaration and all code would not have to have knowledge that the property is observable.

At the moment, to achieve this, Apple would either have to adopt this class and add the special compiler logic that they use for Optionals, or they would have to expose whatever they are doing for optionals to us developers. The tinkerer in me wants Apple to open that up, but the realist in me would rather they take the class internally and not open the language to the overuse that would certainly occur if they released that feature.

### Automatic Unobserving

I would really like to find a way to allow observers to be disconnected automatically if the object concerned is deallocated. However, I do not have any ideas on how to implement that. If you have any ideas, I would love to hear them on [Twitter @drewag](https://twitter.com/drewag) or [LinkedIn](https://www.linkedin.com/in/drewag).
