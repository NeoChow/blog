Before I can describe the use cases for Implicitly Unwrapped Optionals, you should already understand what Optionals and Implicitly Unwrapped Optionals are in Swift. If you do not, I recommend you first read [my article on optionals](/posts/2014/07/05/what-is-an-optional-in-swift)

<a name="when-to-use-an-implicitly-unwrapped-optional" href="#when-to-use-an-implicitly-unwrapped-optional">When To Use An Implicitly Unwrapped Optional</a>
------------------

There are four main reasons that one would create an Implicitly Unwrapped Optional. All have to do with defining a variable that will never be accessed when `nil` because otherwise, the Swift compiler will always force you to explicitly unwrap an Optional.

### <a name="a-constant-that-cannot-be-defined-during-initialization" href="#a-constant-that-cannot-be-defined-during-initialization">1. A Constant That Cannot Be Defined During Initialization</a>

Every member constant must have a value by the time initialization is complete. Sometimes, a constant cannot be initialized with its correct value during initialization, but it can still be guaranteed to have a value before being accessed.

Using an Optional variable gets around this issue because an Optional is automatically initialized with `nil` and the value it will eventually contain will still be immutable. However, it can be a pain to be constantly unwrapping a variable that you know for sure is not nil. Implicitly Unwrapped Optionals achieve the same benefits as an Optional with the added benefit that one does not have to explicitly unwrap it everywhere.

A great example of this is when a member variable cannot be initialized in a UIView subclass until the view is loaded:

    // swift
    class MyView : UIView {
        @IBOutlet var button : UIButton
        var buttonOriginalWidth : CGFloat!

        override func viewDidLoad() {
            self.buttonOriginalWidth = self.button.frame.size.width
        }
    }

Here, you cannot calculate the original width of the button until the view loads, but you know that `viewDidLoad` will be called before any other method on the view (other than initialization). Instead of forcing the value to be explicitly unwrapped pointlessly all over your class, you can declare it as an Implicitly Unwrapped Optional.

### <a name="when-your-app-cannot-recover-from-nil" href="#when-your-app-cannot-recover-from-nil">2. When Your App Cannot Recover From a Variable Being `nil`</a>

This should be extremely rare, but if your app could literally not continue to run if a variable is `nil` when accessed, it would be a waste of time to bother testing it for `nil`. Normally if you have a condition that must absolutely be true for your app to continue running, you would use an `assert`. An Implicitly Unwrapped Optional has an assert for nil built right into it.

### <a name="nsobject-initializers" href="#nsobject-initializers">3. NSObject Initializers</a>

Apple does have at least one strange case of Implicitly Unwrapped Optionals. Technically, all initializers from classes that inherit from `NSObject` return Implicitly UnwrappedOptionals. This is because initialization in Objective-C can return `nil`. That means, in some cases, that you will still want to be able to test the result of initialization for `nil`. A perfect example of this is with `UIImage` if the image does not exist:

    // swift
    var image : UIImage? = UIImage(named: "NonExistentImage")
    if image.hasValue {
        print("image exists")
    }
    else {
        print("image does not exist")
    }

If you think there is a chance that your image does not exist and you can gracefully handle that scenario, you can declare the variable capturing the initialization explicitly as an Optional so that you can check it for `nil`. You could also use an Implicitly Unwrapped Optional here, but since you are planning to check it anyway, it is better to use a normal Optional.

<a name="when-not-to-use-an-implicitly-unwrapped-optional" href="#when-not-to-use-an-implicitly-unwrapped-optional">When Not To Use An Implicitly Unwrapped Optional</a>
---------------

### <a name="member-variables" href="#member-variables">1. Lazily Calculated Member Variables</a>

Sometimes you have a member variable that should never be nil, but it cannot be set to the correct value during initialization. One solution is to use an Implicitly Unwrapped Optional, but a better way is to use a lazy variable:

    // swift
    class FileSystemItem {
    }

    class Directory : FileSystemItem {
        @lazy var contents : [FileSystemItem] = {
            var loadedContents = [FileSystemItem]()
            // load contents and append to loadedContents
            return loadedContents
        }()
    }

Now, the member variable `contents` is not initialized until the first time it is accessed. This gives the class a chance to get into the correct state before calculating the initial value.

**Note:** This may seem to contradict #1 from above. However, there is an important distinction to be made. The `buttonOriginalWidth` above must be set during viewDidLoad to prevent anyone changing the buttons width before the property is accessed.

### <a name="everywhere-else" href="#everywhere-else">2. Everywhere Else</a>

For the most part, Implicitly Unwrapped Optionals should be avoided because if used mistakenly, your entire app will crash when it is accessed while `nil`. If you are ever not sure about whether a variable can be nil, always default to using a normal Optional. Unwrapping a variable that is never `nil` certainly doesn't hurt very much.
