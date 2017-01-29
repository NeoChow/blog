Over the last couple weeks I have been interviewing candiates for a new [Swift/iOS developer position](http://chronosinteractive.com/careers)
at my dev shop. I am ok with hiring a junior developer but I still need someone
that can be productive on our client work relatively quickly. This caused me to
think hard about what core things I want even a junior iOS developer to have
some level of competency with. I came up with the following 5 things.

<div class="note">I also wrote a post on [5 Core Swift Competencies Before You Get a Job](/posts/2017/01/21/5-core-swift-competencies-before-you-get-a-job), if you are interested</div>

Each topic is separated into two high level categories: **common tasks** and **avoiding
long-term problems**. There are certain things that we must do in almost any app we write
but there are also things that we must always keep in mind to avoid long-term problems.

Common Tasks
--------------

For each of the common tasks, there are going to be several different ways you can accomplish
them. You should have experience in as many of them as possible and the more you can
discuss the trade-offs between them the better. However, the most important thing is that you
feel relatively comfortable with at least one way of getting these done. If you do, your
knowledge should transfer pretty well into new methods.

Ok let's jump in!


### 1. View Layout

All iOS apps have at least some graphics, even if it is a single screen. Therefore, every iOS
developer should know how to layout views.

#### Auto Layout

The most common way today is probably through [Auto Layout](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/).
This is a great system for devices of all different sizes but it can also take some time to
get used to. When you are designing your Auto Layout constraints, you should be thinking
long-term. You should make sure that your constraints will seem logical to another
developer and also that it is as easy as possible to add support for more device
sizes in the future.

Auto Layout constraints can be created either visually in [Storyboard](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/)
or [nib files](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/LoadingResources/CocoaNibs/CocoaNibs.html)
and they can also be created programmatically. It is more common to design them
visually but adding them programatically is still a great skill.

#### Spring & Struts

Springs & Struts are really the predecessor to Auto Layout and, while they can occasionally be
useful, they should generally not be used anymore. I am including them as a quick shout-out
because if all you know is Springs & Struts, it is not a deal breaker, but I
would still encourage you to learn another way of laying out views.

#### Stack Views

[Stack Views](https://www.appcoda.com/stack-views-intro/) were a great addition in iOS 9. They
provide a way to either horizontally or vertically stack views next to each other without
complex Auto Layout constraints. Many apps still need to support iOS 8 so these are not quite
widespread yet, but they are a great tool to have in your belt when you are laying out views
for iOS 9 and later.

#### Programmatically

Lastly, we can layout views programmatically. This involves
manipulating the [frames and bounds](http://blog.carbonfive.com/2010/05/27/uiview-frames-and-bounds/)
of views manually in code. You can even [manipulate a view's transform](https://www.hackingwithswift.com/example-code/uikit/how-to-scale-stretch-move-and-rotate-uiviews-using-cgaffinetransform)
to create even more complicated layouts and animations. Most often this is done in the
[layoutsSubviews](https://developer.apple.com/reference/uikit/uiview/1622482-layoutsubviews)
method on UIView subclasses.

Doing this programmatically should not be your default method because it can become
hard to maintain with large code bases and it tends to be more work than Auto Layout, however
it is a great skill to have in a pinch. This is especially true when it comes to designing a
heirarchy of related view types.

That covers all of the common ways of laying out views, so let's move to our next topic: persisting
data.

### 2. Persisting Data

The majority of iOS apps will also need some way of persisting data locally on the user's device. Even
for apps that rely heavily on a web service, it can be important to save data for when there is no
internet connection. There are several popular ways for achieving this.

#### User Defaults

[User Defaults](https://developer.apple.com/reference/foundation/userdefaults) is probably the simplest
way of saving data locally. It lets you save and retrieve small values of various types based on a key
you define. It is not that much more complicated than adding and retrieving values from a dictionary.

#### NSCoding

[NSCoding](https://www.hackingwithswift.com/read/12/3/fixing-project-10-nscoding) is a great next step
after User Defaults. It provides a way of converting arbitrary objects and collections back and forth from
raw data. This is my prefered method for saving data in any small to medium sized app. Performance can
certainly become an issue with large amounts of data but often NSCoding is enough. I also wrote some [protocols](https://github.com/drewag/SwiftPlusPlus/blob/master/Sources/CodableType.swift)
and [types](https://github.com/drewag/SwiftPlusPlus/blob/master/Sources/EncoderType.swift) in my [SwiftPlusPlus](https://github.com/drewag/SwiftPlusPlus)
to make using NSCoding type safe in Swift.

<div class="note">The documentation is woefully out of date for my SwiftPlusPlus project. If you are interested
in some of its functionality, [reach out to me](/contact). If I gain enough interest I will certainly put some
time into improving the documentation.</div>

An extra benefit we gain using this method is it allows our types to be more easily serialized for making network
requests as I will discuss later.

#### CoreData

Another popular option is [CoreData](https://www.raywenderlich.com/115695/getting-started-with-core-data-tutorial).
It is by far the most complicated option I have listed here, but many developers find it useful and some companies
will even require knowledge of it before hiring someone. Personally, I don't like such heavy handed frameworks.
There are too many unknowns that cause confusion and discomfort. I like to know exactly what is going on when I use
a framework and I have never put in enough time to getting that kind of knowledge about CoreData.

I also have the advantage that I work on a lot of small projects instead of one big project. This allows me to develop
my own frameworks and continue to get value out of them for years. Each time I develop a new project I can reuse a
framework and get more value out of it. In the end, I recommend you familiarize yourself with CoreData, but I will also
say that I don't find it to be the ultimate solution. I (*humbly*) consider myself to be an accomplished developer and I
have little experience with it.

#### SQLite

Occasionally, for persisting data, I fallback to using [SQLite](https://www.raywenderlich.com/123579/sqlite-tutorial-swift).
When I do, I use a lightweight framework like [SQLite.swift](https://github.com/stephencelis/SQLite.swift). This is the technology
that CoreData is built on so if I am looking for similar performance to CoreData without the heavy-handed framework,
I will use this. If you are not familiar with SQL databases, this will also have a steep learning curve but it is
more likely to payoff when you do any other database work on other platforms.

There are many, *many* more ways to store data locally on your device and developers continue to come up with new
ways every month. I encourage you to experiment with lots of ways to truly understand the common problems of data
storage and to add more tools to your toolbox. However, I also encourage you to get really good at least one method
so that you can always hit the ground running on a new project.

### 3. Web Requests and Data Serialization

The last critical and common task is making web requests. It is becoming harder and harder for an app to live in a
silo these days. Almost every app needs to communicate with some sort of backend service. For that, we need to be
able to send web requests and handle their responses. As a part of that, you should be familiar with common error
scenarios like not having internet, internal server errors, bad requests, and timeouts. Every time you make a web
request you should consider all of those scenarios and have them handled gracefully for your user.

#### URLConnection

Apple provides networking APIs directly within Foundation centered around [URLConnection](https://developer.apple.com/reference/foundation/nsurlconnection)

These are already pretty great APIs so you can handle most of your networking without any third-party libraries. Personally,
I almost exclusively use the built in APIs and I rarefully find its feature set lacking.

#### AlamoFire

[AlamoFire](https://github.com/Alamofire/Alamofire) is the most popular third-party solution for making web
requests in Swift. I have not used it much because, like I have mentioned already, I tend to avoid big libraries that are doing
things I don't have intimate knowledge of. However, if you are looking for a more powerful framework than those built
into Foundation, I strongly encourage you to check out AlamoFire.

#### AFNetworking

The last popular networking framework I am familiar with is [AFNetworking](https://github.com/AFNetworking/AFNetworking).
This framework targets Objective-C developers and has been around for a long time. I have used this at previous employers
and I can definitely recommend it as long as the built in APIs are not up to scratch for you.

#### Data Serialization

Another large component of networking is being able to format your data appropriately to communicate with your desired web
service. One of the most popular format these days is [JSON](http://www.json.org) but [XML](http://www.w3schools.com/xml/)
and other binary formats like Google's [Protocol Buffers](https://developers.google.com/protocol-buffers/docs/encoding) are
also popular.

Personally I prefer to use my custom form of [NSCoding](https://www.hackingwithswift.com/read/12/3/fixing-project-10-nscoding),
as I discussed above with saving data locally, combined with [JSONSerialization](https://developer.apple.com/reference/foundation/jsonserialization)
to convert my object into JSON. However, there are countless frameworks and data types to choose from.

Don't let the brevity of this section hide the importance of learning to work with web requests. In the modern world of app
development, networking is possibly the most critical skill to have.

Avoiding Long-term Problems
---------------------------

Besides the common tasks I discussed above, there are also a couple topics I want to make sure iOS developers think about in
order to avoid long-term problems. 

### 4. Asynchronous Tasks

Asynchronous programming is a large area of study but in the majority of iOS apps, it is kept
relatively simple.

First you have to understand the idea of asynchronous programming. Very simply, it is the concept
of executing multiple lines of code at the same time. This is opposed to *synchronous* programming
where a program will execute your code one line at a time in a logical order.

The way we execute asynchronous calls on iOS is primarily through [Dispatch](https://developer.apple.com/reference/dispatch).
We simply say that we want to dipatch a code block or closure on a background thread. The other way that we
execute code asynchronously is through APIs that do it behind the scenes; most commonly these are
networking APIs. Generally asynchronous code is considered to be "running in the background" while
the main execution is done "on the main thread". The main thread, like the name suggests, handles
all the core operations of your app; most notably, it is where the user interface and interaction
is managed.

The concept is pretty easy to understand and implement, but the pitfalls are obscure and drastic.
To be a good developer that creates very few bugs, you should have a decent understanding of what those
problems are.

However, before you can even start to concern yourself with the possible problems, you must first make sure
you are always aware when your code might be exeucted asynchronously. Whenever we use a callback
(a closure passed into another method or object), we should check if it will be executed on a
backgroung thread.

#### Updating User Interface

Once you determine that your code will be executed asynchronously, you need to make sure to avoid
a few prominent problems. As I described earlier, the main thread is where the user interface and
user interaction is managed. The number one rule to remember is that you should never try to update
the user interface on a background thread. This will have unpredictable and often disastrous and
hard to debug results. In the interest of keeping this post from exploding in length, I will not go
into the technical reasons of why this is.

#### Race Conditions

The other problem you need to avoid is refered to as a "race condition". Simply put, it is the idea
that the your code acts differently depending on which order your independent threads execute. If two
different threads are working with the same variable, it is very likely that you will create hard
to debug problems. For example, if you are processing a network request in a background thread and
update some data that is currently being updated in the user interface, the user might see fragmented
data. In other cirumstances you won't notice a bug at all.

The most common way to solve this problem on iOS is by synchronizing on the main thread. Just like
we only update the user interface on the main thread, we can ensure we always access and manipulate
shared variables from main thread. This can drastically reduce the amount of race conditions we run
into.

There are also more advanced ways to synchronize code that can be much more efficient but I will
leave that to you to research if you are interested as it is outside the scope of this post.

### 5. Design Patterns

The last and possibly largest core competency I want to discuss is [Design Patterns](https://en.wikipedia.org/wiki/Software_design_pattern).
They have been around pretty much since the beginning of programming, long before iOS, but there
are some design patterns that are pervasive throughout iOS and you would do well to understand why
they exist and why you should abide by them.

#### Model-view-controller

A Design Pattern is essentially a reusable solution to a commonly occuring problem. The most prominent
one in iOS is [Model-view-controller](https://en.wikipedia.org/wiki/Model–view–controller) or MVC for
short. I won't go into great detail here but essentially it is the idea of separating our code and types
into three different layers. The *Model* layer handles all of our data and business logic. The *View* layer
handles all of the user interface and the *Controller* handles all of the communication between the other
two layers. You will notice that Apple's types are organized into this pattern. We have things like
UIViewControllers that are part of the controller layer, and UIViews that are part of the view layer.
The model layer is almost exclusively our responsibliity to create.

The important part of this pattern is that the *View* layer should never communicate directly with the *Model* layer.
This allows us to easily create reusable *View* components and *Model* components. If you tie them together
it is not possible to use them again in another app or even in another part of the same app. For example, a [UITableView](https://developer.apple.com/reference/uikit/uitableview)
can be used to display virtually any kind data; it is completely agnostics about the nature of the data, it simply contains
the logic to lay it out in a consistent fashion.

That's a crash course in Model-view-controller but encourage you to research it more.

#### Delegate

The other Design Pattern I would like to discuss is the [Delegate](https://en.wikipedia.org/wiki/Delegation_pattern)
pattern. The general idea is that a piece of code can delegate out some of its responsibilities to another piece 
of code. You may have noticed that a lot of Apple types contain "delegate" properties. These are using this *Delegate*
pattern.

Generally the purpose of the pattern is to reduce the number of responsibilities a piece of code has. You don't want any
particular type or function to do too much work. It is better to seperate them into more distinct and more easily understood
components. It also enables things like the customization of a UITableView without mixing the different layers of MVC.

Ultimately there are *many* different design patterns; we haven't even really scratched the surface with these two.
That means that it is a topic that we are always learning more about, no matter how experienced we get. There are also
some fantastic books out there like [The Gang of Four](https://www.amazon.com/gp/product/0201633612/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0201633612&linkCode=as2&tag=drewagblog-20&linkId=3d005a3897e17e260c66f868bcffcabd),
and I have an entire chapter of my book, [Learning Swift](https://www.amazon.com/gp/product/B01FKTI6JC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01FKTI6JC&linkCode=as2&tag=drewagblog-20&linkId=6092758fd638d3f61e1dabf5f28790d9)
about design patterns.

Conclusion
-----------

Just like I warned in my post about [Swift core competencies](/posts/2017/01/21/5-core-swift-competencies-before-you-get-a-job),
there is a lot more to programming for iOS than just these 5 topics. However, they are certainly critical components. Learning
these 5 competencies will bring you much close to being a true iOS developer a not someone who simply solves puzzles by
putting various pieces of code together. If you don't have much experience or knowlege about any of these topics, I strongly
encourage you to look into them. Even if you do, we can always get better, more efficient, and less error prone as developers.
If I can inspire even just one person to better themselves as a programmer based on this post, I will consider it a success!
