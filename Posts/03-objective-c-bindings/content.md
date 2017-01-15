The Problem
============

Key-Value Observing is a great feature of Objective-C, however it can take a lot of code to keep an object's property up to date with another object's property. It usually involves adding an observer to the source object and then implementing `-observeValueForKeyPath:ofObject:change:context` to update the destination object every time the source object's property changes. It is also required that you remove the observer before the source object gets deallocated.

The Solution
============

Basics
---------

I just posted a new project on my github account for [Objective-C Bindings](https://github.com/drewag/bindings). It provides an extension to NSObject that adds the following methods:

    // objectivec
    - (void)bindProperty:(NSString *)observingKeyPath
        toObserved:(NSObject *)observed
        withKeyPath:(NSString *)observedKeyPath;
    - (void)unbindProperty:(NSString *)keyPath;
    - (void)unbindAll;

If you want an object's property to always be equal to another object's property you can bind it using the `-bindProperty:toObservered:withKeyPath:` method. This automatically sets up the necessary observers and removes the observer if the source object or destination object is destroyed.

You can also manually remove a binding by calling the `-unbindProperty:` or `-unbindAll` methods.

Transforming Values
---------

Sometimes you may want to bind a property to the property of a different type. For example, you might want to bind a date property to a string property.

To do this, create a setter on the destination object that takes the source objects property types, convert the object, and then set it on the real property. For example:

    // objectivec
    - (void)setDate:(NSDate *)date {
        self.dateString = date.description;
    }

In the example above you would bind to the "date" key path.

Warning
----------

There are two things you should be aware of with this implementation:

1. Bindings do not follow mocked objects (at least for [OCMock's](http://ocmock.org) implementation). Your tests will crash if you don't bind and unbind the real object or bind and unbind the mock object. You can't bind a real object and then create a partial mock for it afterwards.
2. If you do not setup reuse identifiers correctly and try to bind with objects in a cell you will get weird crashes because the cell does not go through it's normal deallocation process when using incorrect reuse identifiers.

The Implementation
=============

To setup a binding this implementation creates a *BindingObserver* instance to track the destination and source objects. The *BindingObserver* is also setup as an observer of the source object and updates the destination object whenever a change is triggered. When this object is deallocated, it removes itself as an observer. To ensure this object sticks around only as long as the destination object is around it is put into an observers array attached as an [associative reference](http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/) of the source object. This way, when the destination object is deallocated, so is the binding object.

It is also necessary to account for the source object being deallocated first. For this, an *ObservedBindingReference* instance is created and attached to the source object also through  an [associative reference](http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/). When the *ObservedBindingReference* is deallocated it first sends a message to the real *BindingObserver* to unbind itself.

Improvements
=======

I have considered a few improvements but haven't had a reason to implement them yet:

1. Use a [OCMock](http://ocmock.org) like interface for setting up bindings so that the user gets auto completion. Something like:
`[[[[[destinationObject bind] stringProperty] to] sourceObject] otherStringProperty]`. Then again, that is some pretty deep nesting.

2. Allow binding to a block instead of automatically setting a value. It can be nice to isolate the business logic to one place instead of having to separate it into where you setup the binding and where you are handling the callback.
3. A binding that has 2 way syncing. (Update either object if the other is changed).

If you have any other ideas, find any bugs, or want to contribute please don't hesitate to comment below or fork the [github repository](https://github.com/drewag/bindings) and play around with it.

**Edit:** I have updated the property bindings repository to include the ability to bind a UITableView directly to a to-many property. See [Bind A UITableView to a Property](/posts/2013/02/10/bind-a-uitableview-to-a-property) for more information.
