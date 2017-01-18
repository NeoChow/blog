<a name="what-is-the-problem" href="#what-is-the-problem">What is the Problem</a>
----------------------

In C, it is possible to create a variable without giving it a value. This would look something like this:

    // c
    int number

If you were to try to use the value before assigning it a value, you would get undefined behavior (that is very bad).

In contrast Swift, for safety reasons, requires all variables and constants to always hold a value. This prevents that scenario where the value of a variable can be unknown. However, there are still cases in programming where one wants to represent the absence of a value. A great example of this is when performing a search. One would want to be able to return something from the search that indicates that no value was found.

<a name="how-is-an-optional-defined" href="#how-is-an-optional-defined">How is an Optional Defined</a>
----------------------

To solve this problem, Swift created the type `Optional` that can either hold no value (`None`) or hold some value (`Some`). In fact, because [Swift allows enums to have associated values](/posts/7-cool-features-in-swift#enumeration-cases-can-hold-values), an optional is defined as an enum:

    // swift
    // slightly simplified
    enum Optional<Wrapped> {
        case none
        case some(Wrapped)
    }

You declare an optional version of a type by adding a `?` after the type name (`String?`).

<a name="unwrapping-an-optional" href="#unwrapping-an-optional">Unwrapping an Optional</a>
----------------------

Before you use the value from an `Optional` you must first "unwrap" it, which basically means that you assert that it does indeed hold a value. We consider an optional value "wrapped" because the real value is actually held inside the enumeration.

### <a name="optional-binding" href="#optional-binding">Optional Binding</a>

You can unwrap an optional in both a "safe" and "unsafe" way. The safe way is to use [Optional Binding](https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_432):

    // swift
    let possibleString: String? = "Hello"
    if let actualString = possibleString {
        // actualString is a normal (non-optional) String value
        // equal to the value stored in possibleString
        print(actualString)
    }
    else {
        // possibleString did not hold a value, handle that
        // situation
    }

### <a name="forced-unwrapping" href="#forced-unwrapping">Forced Unwrapping</a>
Sometimes you know for sure that a variable holds an actual value and you can assert that with [Forced Unwrapping](https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_430) by using an exclamation point (`!`):

    // swift
    let possibleString: String? = "Hello"
    print(possibleString!)

If possibleString were `None` (did not hold a value), the whole program would crash with a runtime error and therefore, forced unwrapping is considered "unsafe".

### <a name="implicitly-unwrapped-optional" href="#implicitly-unwrapped-optional">Implicitly Unwrapped Optional</a>

An [Implicitly Unwrapped Optional](https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-XID_436) is an optional that doesn't need to be unwrapped because it is done implicitly. These types of optionals are declared with an `!` instead of a `?`:

    // swift
    let possibleString: String! 
    print(possibleString)

Notice, I did not use an `!` to print out the value of `possibleString`. Just like forced unwrapping, accessing an implicitly unwrapped optional that is nil will cause the entire program to crash with a runtime error.

For more information on when Implicitly Unwrapped Optionals are appropriate, I recommend my other post [Uses For Implicitly Unwrapped Optionals](/posts/uses-for-implicitly-unwrapped-optionals-in-swift).
