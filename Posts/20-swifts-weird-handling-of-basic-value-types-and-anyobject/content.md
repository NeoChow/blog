I recently wrapped my head around something that I have found very strange in Swift. Swift provides two high level protocols called `Any` and `AnyObject`.  `Any` can be used for both value types (like structs) and reference types (classes) while `AnyObject` can only be used for classes.

As expected this code produces a compilation error:

    // swift
    var objects : [AnyObject] = []
    var aString : String = "Hello"
    objects.append(aString) // The type ‘String’ does not conform to protocol ‘AnyObject’

However, by simply adding `import Foundation` to the top, it compiles and runs fine:

    // swift
    import Foundation

    var objects : [AnyObject] = []
    var aString : String = "Hello"
    objects.append(aString)

What is going on here?

The reason this works fine, is because the compiler is actually converting `aString` to `NSString` implicitly. `String` is a struct **but `NSString` is a class**. If Foundation is not imported, this conversion is not possible because it doesn’t know about `NSString`.

This also happens with numbers like `Int` which can be implicitly converted to the class type `NSNumber`.

This means that in Swift, strings and numbers can be treated as both value types **and** reference types.

This seems to go against Swift's policy of always requiring explicit conversions between types, but I guess it is a compromise to allow working with Objective-C much easier.

Be careful of this “magic” conversion. You may be using a reference type when you are expecting it to be a value type. I recommend removing `import Foundation` whenever possible.
