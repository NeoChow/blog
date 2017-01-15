I have been spending a lot of time with Swift since it was announced at WWDC. It certainly has its bugs and rough spots, but I have already discovered a number of really cool parts of the language that I would like to share because they make me feel very excited about the future of iOS and OS X development.

My strongest comparisons will be to Objective-C since that is the language it will be replacing or at least accompanying. Therefore, I am not necessarily saying similar features don’t exist in other languages, many of them do; I am simply concentrating on how Swift will change the daily lives of iOS and OSX programmers.

1. <a name="extend-structs-and-literals" href="#extend-structs-and-literals">Extend Structs and Literals</a>
----------------

I love that you can extend structs in Swift. It can be really useful to add functionality to an existing structure. One prime example for me is the ability to add a `center` method to a `CGRect` that will return the center point of the rectangle:

    // swift
    extension CGRect {
        var center: CGPoint {
            return CGPoint(
                x: self.origin.x + self.size.width / 2.0,
                y: self.origin.y + self.size.height / 2.0
            )
        }
    }

I have to use the center of a rectangle a lot and the intention of the code becomes much clearer if I can use it by name instead of always doing the math.

It can also be useful to extend literals. In ruby, there is a useful method on integers called `repeat`. Basically you can call `repeat` on an integer with a block that will be executed however many times that integer defines. In Swift, the extension to make this possible would look like this:

    // swift
    extension Int {
        func repeat(block : () -> ()) {
            for i in 0 ..&lt; self {
                block()
            }
        }
    }

You can then use it like so:

    // swift
    3.repeat {
        // called 3 times
        print("hello")
    }

**Note**: The parenthesis can be left out if the only parameter is a closure

2. <a name="enumeration-cases-can-hold-values" href="#enumeration-cases-can-hold-values">Enumeration Cases Can Hold Values</a>
----------------

In Swift, the cases of an enumeration can hold values known as [Associated Values](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-XID_189) which creates an elegant way to solve certain types of problems. A simple example of this is a network request:

    // swift
    struct NetRequest {
        enum Method {
            case get
            case post(String)
        }

        var URL: String
        var method: Method
    }

    var getRequest = NetRequest(URL: "http://drewag.me", method: .get)
    var postRequest = NetRequest(URL: "http://drewag.me", method: .post("{\"username\": \"drewag\"}"))

A GET request does not have a request body but a POST request does. Instead of having a potentially unused member variable, you can define the content body of the POST to be directly in the `Method` enum.

Possibly the best example of this is the `Optional` in Swift. The Swift compiler helps us with some syntactic sugar, but in reality when you define an optional `String` like this: `var myString : String?` the compiler actually translates it to `var myString : Optional<String>`. An `Optional` is defined as follows:

    // swift
    enum Optional<T> {
        case none
        case some(T)
    }

In the `None` case (`nil`), there is no actual value associated with it, but in the `Some` case, there is a concrete value associated with it. This is a really elegant way to express a variable that can lack a value without having pointers exposed in the language and without allowing all values to be nil.

3. <a name="keeps-your-collections-safe-and-clear" href="#keeps-your-collections-safe-and-clear">Keeps Your Collections Safe and Clear</a>
----------------

Collections in Objective-C all use the most generic class type available, `id`. This means that you can put any value into a collection including a mix of objects and often times, this leaves the types of a collection unclear. This is something I have always thought that C++ had over Objective-C. C++ has [Templates](http://en.wikipedia.org/wiki/Template_(C%2B%2B)) that allow you to define a collection with a specific type like `vector<int>`. Swift borrows very similar syntax and functionality with their [Generics](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_234) feature.

The following is a simple example of a situation where Generics can save time and prevent bugs:

    // swift
    class Word {
        enum partOfSpeech {
            case noun, pronoun, verb
        }

        var value: String
        var partOfSpeech: PartOfSpeech

        init(_ value: String, _ partOfSpeech: PartOfSpeech) {
            self.value = value
            self.partOfSpeech = partOfSpeech
        }
    }
    var sentence = [Word("I", .pronoun), Word("ran", .verb), Word("home", .noun)]
    sentence.append("quickly") // Cannot convert the expression's type '()' to type 'Word'
    sentence[0].lowercaseString // Could not find member 'lowercaseString'
    sentence[0].value.lowercaseString

Above I have defined a class `Word` that contains a String for the actual word and also a part of speech. Then I defined an array of words called `sentence`.

If another programmer saw a variable called `sentence` defined as an array, I think it would be a pretty safe bet to assume that it is simply an array of strings. In Objective-C, this kind of misconception would not be caught until runtime because the compiler doesn’t know what type is supposed to go into the array, but in Swift, every array is defined as holding a specific type. In the example above, the compiler infers that the array is of type `Word[]`. If you wanted to be more explicitly you could write its definition like so: `var sentence : Word[] = …` but it isn’t necessary. Even without explicitly defining it as such, the compiler gives an error if you try to append a value to it that is not a `Word`. It also gives an error if you try to operate on the value as if it were a `String`.

This feature will make Swift APIs including collections much more easily understood and safer to operate with.

4. <a name="multiple-functions-with-different-types" href="#multiple-functions-with-different-types">Multiple Functions with Different Types</a>
----------------

In Swift, you can define multiple versions of a function, with different implementations, with the same name as long as they take different types. This is great for defining functions that could apply to many different types but require different implementations for each. An example would be functions to add two values mathematically:

    // swift
    func mathmaticallyAdd(_ a: Int, _ b: Int) -> Int {
        return a + b;
    }

    func mathmaticallyAdd(_ a: String, _ b: String) -> String {
        let aNum = a.toInt()
        let bNum = b.toInt()
        return "\((aNum ? aNum! : 0) + (bNum ? bNum! : 0))"
    }

    mathmaticallyAdd(2, 7) // returns 9
    mathmaticallyAdd("2", "7") // returns “9”

There is no reason to define two different functions like `mathmaticallyAddInts` and `mathmaticallyAddStrings`. That would be overly verbose because the intention is clear enough with just `mathmaticallyAdd`. In the definition using `Int`, the function can just use the `+` operator. However, in the `String` implementation, the function must first convert the strings to integers.

I do not inherently dislike verbosity in a programming language, but I certainly don’t want to be forced to make something overly verbose. The goal is to make the intention clear with as few characters as possible.

5. <a name="willset-didset" href="#willset-didset">WillSet and DidSet, No Need to Completely Override Setters</a>
----------------

In Objective-C there were a lot of circumstances where I would override a property’s setter so that I could perform an action before or after setting the value. This always required boilerplate code to do the actual value assigning on top of whatever action I actually wanted to perform that was especially cumbersome if I wanted the property to be atomic.

In Swift, there is a built in mechanism to make performing actions immediately after or immediately before an assignment that removes the need for the boilerplate code. This feature is called [Property Observers](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_333). Basically you can define a `willSet` and / or a `didSet` method within a property that is automatically called at the appropriate time. `willSet` is provided a variable `newValue` and `didSet` is provided variable `oldValue`. An example of this is as follows:

    // swift
    class MyView : UIView {
        var aSubview : UIView {
            didSet {
                oldValue.removeFromSuperview()
                self.addSubview(aSubview)
            }
        }

        init(frame: CGRect) {
            self.aSubview = UIView()

            super.init(frame: frame)
        }
    }

In this `MyView` class, whenever it is assigned a new `aSubview`, the old one is automatically removed and the new one is added as a subview. I do this when I will be changing out a subview often and from multiple places so I don’t always have to track when the view is attached or not and I don’t have to duplicated the `addSubview` code.

6. <a name="weak-and-unowned-in-closures" href="#weak-and-unowned-in-closures">Weak and Unowned In Closures</a>
----------------

Memory management is still not completely automatic in Swift as it still uses [Automatic Reference Counting](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AutomaticReferenceCounting.html), but they greatly improved the syntax. Instead of having to declare a `weak` or `unsafe_unretained` variable outside of the block, you can define how a closure should capture outside variables using [Capture Lists](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_67). Here is an example for both `weak` and `unowned` in Swift:

    // swift
    class FilePickerController : UIViewController {
        var onDidPickFileWithPath : ((path : String) -> ())?
    }

    class DocumentViewController : UIViewController {
        var filePicker: FilePickerController?
        var content: String?

        init(fileAtURL URL: NSURL) {
            super.init(nibName: nil, bundle: nil)

            var request = NSURLRequest(URL: URL)

            // weak: Have self automatically set to nil if it is deallocated
            NSURLConnection.sendAsynchronousRequest(request, queue: nil) {
                [weak self]
                (response, data, error) in
                if let actualSelf = self {
                    // Captures an owning reference "actualSelf" so interacting with it in this
                    // block is safe
                    actualSelf.content = NSString(data: data, encoding: NSUTF8StringEncoding)
                }
            }
        }

        func presentFilePicker() {
            if !filePicker {
                filePicker = FilePickerController();

                // unowned: Don't worry about the nil case if you know it will never happen
                filePicker!.onDidPickFileWithPath = {
                    [unowned self]
                    (path: String) in
                    self.content = NSString.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
                }
            }

            self.presentViewController(filePicker!, animated: true, completion: nil)
        }
    }

I defined a `DocumentViewController` that can be initialized with a URL. It then begins to download the contents of the URL which is done asynchronously. There is no reason to keep the `DocumentViewController` around if the view controller is dismissed so I used a [weak reference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_68). To do so, I simply preface the closure with `[weak self]`. This indicates that I want to capture `self` weakly. If the `DocumentViewController` gets deinitialized, self will be set to `nil`. However, there could also be a race condition where the view controller gets dismissed while the closure is being executed. To prevent this causing problems, I capture a strong reference to `self` using `actualSelf` during the execution of the closure. When the closure exits, the strong reference will go away and the view controller is free to be deinitialized again.

I also created a `FilePickerController` class that theoretically allows the user to pick a file. It provides a closure member that would be called when the user picks a file. The `DocumentViewController` that I defined, has a method to present the file picker and handle the user picking a file. If this closure were to strongly capture a reference to self, there would be a circular reference because `self `owns the closure through its ownership of the `FilePickerController`. In this case, I know that the closure will only ever exist while the `DocumentViewController` exists so I can use an [unowned reference](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-XID_68) by prefacing the closure with `[unowned self]`. Now I don’t have to do anything special with `self` within the closure. I can use it normally.

This is much cleaner than what used to be necessary in Objective-C.

7. <a name="initialization-safety" href="#initialization-safety">Initialization Safety</a>
----------------

In Objective-C there was a bug that I would fairly often write. It would never make it to production, but it would cause me to scratch my head and spend a few minutes debugging it. It is a pretty common pattern that I have a mutable array in a class that I want to load contents into. This requires that the array first be initialized so that it can be added to. I would often forget to put this initialization into my class and it would continue on happily sending messages to the nil array, not actually adding anything to it.

In Swift, the compiler will catch this for two reasons. One is that you have to explicitly handle the `nil` case in swift, but the one I want to concentrate on in this section is initialization safety. If you leave any member variable uninitialized after an initializer, your app will not build. A simple example of this would be a `Directory` class with a `contents` array:

    // swift
    class FileSystemItem {
        var path: String

        init(path: String) {
            self.path = path
        }
    }

    class Directory: FileSystemItem {
        var contents: [FileSystemItem]

        init(path: String) {
            self.contents = [] // required

            super.init(path: path) // required
        }

        func loadContents() {
            // ...
            // self.contents.append(file)
            // ...
        }
    }

If I were to leave out the `self.conents = []` line, the compiler would complain with the error: “Property ‘self.contents’ not initialized at super.init call”. This will save me lots of time.

Another type of problem that initializer safety can help catch is bypassing the initialization of a superclasses variable. In Objective-C there is a convention called [Designated Initializers](https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/Initialization/Initialization.html#//apple_ref/doc/uid/TP40010810-CH6-SW3). Basically it says that every class should have an initializer that initializes the entire class to a safe state. Other initializers should always call a designated initializer because that ensures the class is never in a bad state. However, this is not enforced in Objective-C. In Swift, they made this into something the compiler guarantees. This means that the `Directory` class above must call the `init(path)` initializer or the compiler gives an error. This means that the class can never get into a situation where `path` is not defined. This becomes even more important when classes get bigger an inheritance gets deeper.
