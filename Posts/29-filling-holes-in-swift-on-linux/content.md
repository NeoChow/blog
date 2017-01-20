There are still a number of critical holes in Swift when run on Linux which is the primary place where you are going to
deploy a Swift backend or website. The most notable holes are in Foundation. People are working hard to fill
them in, but in the meantime I still wanted to push forward with server-side development. After I thought up this
technique, the problems I ran into changed from mountains to mole hills. There are too many upsides
to using Server-Side Swift for me to wait for everything to be completely fully baked.

For those who don't know, [Foundation](https://developer.apple.com/reference/foundation) is the basic framework on top of Swift that adds a lot of common functionality. This
is where things like URLs, JSON serialization, and much more are implemented. Admittedly there have been some other frameworks have popped up in the
community to replace Foundation, but personally, I want to stick with
Foundation as much as possible as it is the most likely to be supported for the long term.

The three general areas I have found the Foundation support on Linux to be particularly lacking are:

- Web Requests ([URLConnection](https://developer.apple.com/reference/foundation/nsurlconnection))
- File Management ([FileManager](https://developer.apple.com/reference/foundation/nsfilemanager))
- Date Formatting ([DateFormatter](https://developer.apple.com/reference/foundation/nsdateformatter)) which is thankfully fully supported now.

There are plenty of other missing implementations but these are the most critical I have run into so far.

Discovering the holes
------------

The first thing we need to discuss is to know how we discover the holes in the first place. There is a [file in the open
source repository](https://github.com/apple/swift-corelibs-foundation/blob/master/Docs/Status.md) that describes the status of
Foundation with a decent amount of granularity. You could theoretically lookup each functionality you want to use on that status
page before choosing to use it, but I don't feel that is very practical. First of all, you need to track down which version of
Foundation was included in the version of Swift you are targeting. Also, a lot of the various components have a status
of "Incomplete" which means it is hard to know exactly what parts of it are done.

The process that I have developed is to get it working with Foundation on macOS and to plan out thorough testing once I move it
over to Linux. It is much nicer to develop Swift in Xcode on macOS anyway. This is testing I should be doing anyway and I am just
prepared for there to be crashes because of missing functionality.
The way this appears during testing is always going to be a crash. Usually it will report a message that this is not implemented yet, but
sometimes it will crash for other reasons. Presumably this is because of a bug in the implementation but without digging through the
Foundation source code it is impractical and ultimately not very important to know. By getting it working on macOS you drastically reduce
the circumstances where the crash is because of something you are doing wrong.

In order to find out exactly where the program is crashing on Linux, I run it in [LLDB](http://lldb.llvm.org). For those of you unfamiliar
with the name, LLDB is the debugger currently built into Xcode. This allows me to see the exact callstack of the crash and therefore lets me
know where I need to fix the hole in Foundation.

To run your program in LLDB, build it as normal (preferably in debug mode) and then run the command you normally use to run it but with the
prefix `lldb`:

    // bash
    swift build
    lldb .build/debug/my-program arg1 arg2

Instead of immediately starting the program, LLDB will provide you an opportunity to do all kinds of configuration before hand. I will not
get into all of the details here but I certainly encourage you to get familiar with LLDB if you are interested. In our case, we just want to
run our program. To do that simply type "run" or "r" and hit enter.

At that point, do whatever you need to do to create the crash and LLDB will stop there and provide you a prompt. To see the callstack type "bt"
(for backtrace) and hit enter. If this is not descriptive enough, you can use the "up" command to move up the callstack and see a short snippet
of the executing code. Find the place where you call into Foundation and that will tell you where you need to fix.

The Solution
--------------

The solution I have used to solve most of these problems is to fallback to using bash. This may seem crazy or complicated to some but the truth of
the matter is that Linux supports a ton of operations right out of the box easily from the command line. It is a great short-term solution until
Foundation on Linux is finished.

I leave the Foundation implementation within a [conditional compilation block](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-ID203)
and add in a call to the command line when on linux:

    // swift
    #if os(Linux)
        // do command line stuff
    #else
        // do Foundation stuff
    #endif

To make calling bash commands easier, I wrote a pretty simple struct:

    // swift
    #if os(Linux)
    import Foundation
    struct CommandLine {
        static func execute(_ command: String) -> String {
            let BUFSIZE = 1024
            let pp = popen(command, "r")
            var buf = [CChar](repeating: CChar(0), count:BUFSIZE)

            var output = ""
            while fgets(&buf, Int32(BUFSIZE), pp) != nil {
                output += String(cString: buf)
            }
            pclose(pp)
            return output
        }
    }
    #endif

I wrapped it a conditional compilation block because I don't want to accidently use it on macOS. All it does is open up a new process with the given command,
read in the output of the command, and return it to the caller. This could certainly be made more robust by incorporating things like status codes and other things.
I also explored using [Task](https://developer.apple.com/reference/foundation/nstask) from Foundation, but the implementation above has served me well.

With this I have been able to handle things like creating directories with "mkdir" (`mkdir &lt;path>`), moving files with the move command (`mv &lt;from> &lt;to>`), formatting
dates with `date`, and more. I even use it for something that Foundation does not support: *sending emails*. For that I use the `mail` command. It is a great fallback
because I already know how to do these things from the command line and, even if I don't, there are a ton of resources online describing how to do so.

**Warning:** Just like with SQL you need to be very careful to not allow attackers to inject their own bash code into your calls. For example, if your call is
`mkdir 'fielpath'` someone could manipulate the file path to be `some/path'; rm -rf /' to delete your entire file directory. You need to sanatize your input to not allow
this kind of attack by escaping all single quotes in the call. You should also ensure you are running your program with minimum permissions. Finally, you should avoid using
this technique in a place that can even be manipulated by the user in the first place.

The Future
-------------

Slowly I hope to phase out all of the calls into bash. Calling into bash breaks a lot of the core principles of Swift: mainly safety. For a while I even forgot to close the
process with `pclose` and it was causing my programs to leak processes and eventually crash. I am putting these calls in place because they are quick and easy workarounds. I
don't want to impede the process of my development too much, especially for the things that should **and will be** easy soon.

I recommend occasionally restoring the Foundation code on Linux when new versions of Swift are released to see if they have been implemented yet. That has already happend to me with DateFormatter
and I was able to happily delete several calls to the command line. I also recommend wrapping these calls in methods and types that hide the hack from other parts of the code.
I ultimately only have a few places in my code that actually have this command line code, even if other code depends on the functionality. A few of the types I have created so far are:
[Command Line](https://github.com/drewag/SwiftPlusPlus/blob/master/Sources/CommandLine.swift), [Email](https://github.com/drewag/SwiftPlusPlus/blob/master/Sources/Email.swift),
and a [File Service](https://github.com/drewag/SwiftPlusPlus/blob/master/Sources/FileService.swift).

That's it for this tip, but I am planning to write a lot more about what I have learned so far writing Server-Side Swift. If you are interested in doing your own Server-Side Swift
development, I encourage you to subscribe to my posts with the form below or follow me on Twitter.
