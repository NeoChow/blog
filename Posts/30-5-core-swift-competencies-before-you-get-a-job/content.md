I recently started the process of interviewing candiates for a new [Swift/iOS developer position](http://chronosinteractive.com/careers)
at my dev shop. I have been preparing to administer some tech interviews which led me to down the path
of deciding what skills I need in a candiate. I am not particularly concerned that they know every
technical detail, especially if they are new. I imagine most developers will be able to tackle any problem I give them,
in time, using the vast amount of resources out there now to point you in the
right direction when you experience a problem. The knowledge I want is that which is not a requirement
to get the job done, but to get the job done reliably well. I want real developers, not people who simply
puzzle solutions together (even though I think the puzzling step is important). Therefore, I came up with 5 different knowledge sets
that I think separate the developers from the puzzlers.

From this point forward, I will talk directly to those of you that want to make sure you have these core competencies. My
intension is not to make you feel bad about your current skillset, but to inspire you to learn these core competencies
and take your skils to the next level.

Each topic is divided into 2 high level categories: **effectively using the language** and **avoiding long-term
problems**. First I want to be sure that you know how to leverage your primary tool of choice. Then I want to
make sure your code will not cause problems on my projects in the long-run without me scrutinizing every line
of code you commit.

Effectively Using the Language
------------------------------

### 1. Optionals

Optionals are littered all over Swift code. They are not particularly complicated so you should have an extremely
thorough understanding of how they work and the different types that exist. You should no longer be at the stage
where you try randomly putting exclamation points and question marks in different places until it compiles. You should
appreciate and embrace the safety that they provide even if they can be annoying at times. If you don't learn to do
so, not only can you not effectively use the language, but you will not enjoy a job spent writing Swift.

If you want to bone up on the technical nature of optionals, I have [a separate post explaining them thorougly](/posts/2014/07/05/what-is-an-optional-in-swift).

Optionals are fantastic because they force you to confront how you are going to handle edge cases. They also make
it abundantly clear to anyone reading your code whether you are handling them or not. If you see an exclamation point,
other than in [some particular circumstances](/posts/2014/07/05/uses-for-implicitly-unwrapped-optionals-in-swift), you
should think: "here be dragons!"

### 2. Enumerations and Switches

Enumerations or "enums" for short are a simple concept on the surface: describe a finite list of possible values that a
variable could be. There are lots of more advanced uses for them but I am only really concerned with that simple concept in
a candiate. It is when you combine enumerations with switches in Swift that you can easily protect your code from a whole class of
bugs and increase its reliability greatly. If you are not often thinking, "Oh, I could use an enum here", you are foregoing
another core part of Swift. Gone should be the days of arbitrary strings and integers as values to represent finite
ideas.

The best example I can give for this is in finite table views. [Table views](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html)
and [collection views](https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/Introduction/Introduction.html)
are virtually ubiquitous across all iOS apps these days. They are fantastic when you have arbitrarily long lists, but
they are also a quick and easy way to layout fixed menus and information. In these circumstances I *always* use enumerations
to avoid silly mistakes, especially when I return to modify the table view later. Instead of using raw integers to determine
the number and content of rows, I use an enumeration:

    // swift
    enum Sections: Int {
        case contact, info

        case count
    }

    enum ContactSection: Int {
        case feedback, featureRequest, bug

        case count
    }

    enum InfoSection: Int {
        case about
        
        case count
    }

For those of you not aware, if you set an enumeration to have a raw type of `Int`, it will automatically assign each successive case
the next integer value starting at 0. Therefore, I always leave the last case as a "count" case which will be the total number of cases.
If you don't know all the details around enumerations I unfortunetly don't have a post for that yet, but you can certainly read my book [Learning Swift](https://www.amazon.com/gp/product/B01FKTI6JC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01FKTI6JC&linkCode=as2&tag=drewagblog-20&linkId=6092758fd638d3f61e1dabf5f28790d9)
where I cover all of the core Swift concepts.

Now, back to the example. In the table view data source, I can use those enumerationss to greatly increase the safety of my code. First, I can return the
raw value of the section's count for the number of sections (instead of a hard-coded number):

    // Swift
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }

Then I can initialize the section enumeration based on the passed in integer to figure out the correct number of rows:

    // Swift
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .count:
            fatalError()
        case .contact:
            return ContactSection.count.rawValue
        case .info:
            return InfoSection.count.rawValue
        }
    }

Again I use the raw value of each of the sections' count for the number of rows.

Lastly, I can nest the switches in the "cell for row" method:

    // Swift
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Default.rawValue)
            ?? UITableViewCell(style: .value1, reuseIdentifier: Identifiers.Default.rawValue)

        switch Section(rawValue: indexPath.section)! {
        case .count:
            fatalError()
        case .contact:
            switch ContactSection(rawValue: indexPath.row)! {
            case .count:
                fatalError()
            case .feedback:
                // Configure Cell
            case .featureRequest:
                // Configure Cell
            case .bug:
                // Configure Cell
            }
        case .info:
            switch InfoSections(rawValue: indexPath.row)! {
            case .count:
                fatalError()
            case .about:
                // Configure Cell
            }
        }

        return cell
    }

The only thing you need to be careful of is using the correct enumeration for each of the sections (same goes
for the "number of rows" method).

Now you can do all sorts of things very safely. You can reorder rows or even entire sections by simply changing
the enumerations around. If you add another section or row, the compiler will instantly tell you every place
you need to implement that new item. They also add great clarity to your code compared to using raw values.

You may have also noticed that I used an enumeration for the cell identifier. This is another great place to
eliminate the use of an arbitrary string and it is even better than a constant because it enforces an organization
of all possible identifiers.

These are just two examples of harnessing enumerations and switches to greatly enhance your code. They are not required to
get the job done, but they certainly make for more reliable and maintainable code.

### 3. Protocol Extensions

Now to the last of the core competencies for effectively using Swift. This is the famous idea of Protocol Oriented Programming.
It is definitely more advanced than the previous two topics so I don't expect comprehensive knowledge of the subject. I myself
am still always finding new ways to take advantage of protocols. However, you should be familiar with the idea and be able to describe
how they can be useful.

I am planing to write a post where I go more in-depth into the subject, but for now you can check out the amazing [Apple Developers Conference Talk](https://developer.apple.com/videos/play/wwdc2015/408/)
on it.

Ultimately, you need to realize why the idea of extending protocols is so powerful and how it differs form subclassing. Subclassing
really tightly <a href="https://en.wikipedia.org/wiki/Coupling_(computer_programming)">couples</a> all subclasses to their parent subclasses
while protocol conformance remains quite loose. It allows easily and unobtrusively adding functionality to many different types all at
once in a very targeted way. Being able to harness this will make you a much better Swift developer and it is one of the biggest things
that stands out from other common programming languages. If you don't familiarize yourself with this concept, you are leaving a lot of
power on the table.

Avoiding Long-term Problems
-----------------------

Now we get to the last two, and most important, competencies relating to how good programmers avoid long-term problems down the road.

### 4. Value Types v.s. Reference Types

To program safely in Swift, you *must* understand the difference between value types and reference types. (Obviously you must
also know how to create them.) This distinction has many influences on advanced topics like memory managment and performance, but it also
greatly influences how we need to reason about our code. It is something you should always be thinking about first when creating a new type.

In short, value types are copied whenever they are passed around your code while reference types have only a single value that is *referenced*
when passed around. That means you will get very different results from the following code:

    // swift
    var b = a
    b.changeInSomeWay()
    print(a)
    print(b)

If `b` is a reference type, both print calls will print the same thing because both `a` and `b` reference the same underlying object. However,
if `b` is a value type, it will print two different things because `b` is no longer associated with `a`. To learn more about this, you can read my [stack overflow answer on the subject](http://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845#24232845).

Both value types and reference types have important use cases. You don't want to use a value type to represent a finite resource like a heart rate monitor.
It doesn't make sense to copy a heart rate monitor that exists physically. At the same time, you don't want to use a reference type to represent
a homework assignment you send to a friend to look at. If your friend accidently destroys his copy, you don't want it to affect yours. If you choose
the wrong type, you are asking for bugs down the line as your code base grows in size and age.

### 5. Reference Cycles

Finally, we have our last core competency: reference cycles. While I expect every progammer will create reference cycles from time-to-time, I expect
you to have an in-depth knowledge of how they can occur. You should know how you can both fix and avoid them, especially because there are only
limited ways they can realistically occur in Swift and they are virtually the only way that memory will leak.

This is another topic I cover in-depth in [my book](https://www.amazon.com/gp/product/B01FKTI6JC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01FKTI6JC&linkCode=as2&tag=drewagblog-20&linkId=6092758fd638d3f61e1dabf5f28790d9),
but in short, reference cycles are when you have an object reference itself through other objects and/or closures. This creates a cycle where
[Automatic Reference Counting](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html),
better known as "ARC", will never know to delete the object from memory. This most often happens in complicated object relationships or when you
absent mindedly capture a strong reference to an object inside a closure that the object itself owns. For example:

    // Swift
    let ball = Ball()
    ball.onBounce = {
        print("\(ball.location.x), \(ball.location.y)")
    }

Here the ball has a strong reference to the `onBounce` closure and the closure has a strong reference back to the ball. Neither the ball nor the
closure will ever be deleted and therefore will be considred "leaked" memory. To fix it, you must capture the ball weakly. In this case we can capture
it as unowned:

    // Swift
    ball.onBounce = { [unowned ball] in
        print("\(ball.location.x), \(ball.location.y)")
    }

If any of this is new or confusing to you, I *highly* recommend you research and practice it more. It will not be obvious that memory leaks
are occuring until much later when users are experiencing peformance problems or even crashes. Every time you create a type that references another
type or pass a closure somewhere, you should be asking yourself, "Am I creating a reference cycle?". It is much easier to prevent reference
cycles up front than it is to track them down later.

Bonus
------------

### 6. Generics

I also want to quickly mention [generics](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html).
They are certainly not unique to Swift but they can be very powerful. I wouldn't mind if a beginner Swift programmer didn't know how to harness
them but I certainly want all developers to eventually learn to. Generics are a huge part of how you can leverage the Swift type system to work
for you. That changes the compiler from an annoying foe to a most helpful friend. That idea is so important to me that I dedicated an entire chapter
to it in [my book](https://www.amazon.com/gp/product/B01FKTI6JC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01FKTI6JC&linkCode=as2&tag=drewagblog-20&linkId=6092758fd638d3f61e1dabf5f28790d9).

I think that the biggest reason many developers dislike [strongly-typed](https://en.wikipedia.org/wiki/Strong_and_weak_typing) languages like Swift is that
they have not spent enough time to discover how you can really take advantage of a compiler (just like ardent strongly-typed language supporter have not spent
enough time to discover the power of a flexible type system). 

Conclusion
------------

Ultimately, there is a lot more knowledge necessary to actually get your job done as a Swift developer. However, I strongly believe most developers
will be able to puzzle their way through a project to get it done regardless of what frameworks, third-party libraries, and stack overflow answers they need to
use along the way. These core competencies are the most important stepping stones between being a puzzle solver and a true Swift developer that can be a valuable
asset to a company.
