<div class="note">This article written for Swift 1 so while the principles still apply, some of the syntax has changed.</div>

When I first discovered [curried functions](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-XID_597) in Swift, I though it was very cool, especially because [methods are implemented as curried functions](http://oleb.net/blog/2014/07/swift-instance-methods-curried-functions/), but I couldn't think of a practical use case for them. If you don't already know what a curried function is, it is basically a function that is made up of a chain of functions. This will become more clear through my practical example.

Curried functions work great for implementing a logging system. Here is my example Logger type:

    // swift
    struct Logger {
        /// Level of log message to aid in the filtering of logs
        enum Level: Int, Printable {
            /// Messages intended only for debug mode
            case Debug = 3

            /// Messages intended to warn of potential errors
            case Warn =  2

            /// Critical error messagees
            case Error = 1

            /// Log level to turn off all logging
            case None = 0

            var description: String {
                switch(self) {
                case .Debug:
                    return "Debug"
                case .Warn:
                    return "Warning"
                case .Error:
                    return "Error"
                case .None:
                    return ""
                }
            }
        }

        /// Log a message to the console
        ///
        /// :param: level What level this log message is for
        /// :param: name A name to group a set of logs by
        /// :param: message The message to log
        ///
        /// :returns: the logged message
        static func log
            (#level: Level)
            (name: @autoclosure() -> String)
            (message: @autoclosure() -> String) -> String
        {
            if level.toRaw() <= Logger.logLevel.toRaw() {
                let full = "\(level.description): \(name()) - \(message())"
                println(full)
                return full
            }
            return ""
        }

        /// What is the max level to be logged
        ///
        /// Any logs under the given log level will be ignored
        static var logLevel: Level = .Warn

        /// Logger for debug messages
        static var debug = Logger.log(level: .Debug)

        /// Logger for warnings
        static var warn = Logger.log(level: .Warn)

        /// Logger for errors
        static var error = Logger.log(level: .Error)
    }

My logger only had to implement a single log method that takes a level, name, and message. A full log call would look like this:

    // swift
    Logger.log(level: .Debug)(name: "SomeName")(message: "message")
    // Prints "Debug: SomeName - message

However, because I defined `log` as a curried function, I was able to also define specially named partials for each of the different log levels. This allows a debug log call to look like this:

    // swift
    Logger.debug(name: "SomeName")(message: "message 2")
    // Prints "Debug: SomeName - message 2"

Finally, I can also define my own partials if I am going to make a series of logs all with the same name:

    // swift
    let myLog = Logger.debug(name: "My")
    myLog(message: "message 3")
    // Prints "Debug: My - message 3"

Curried functions allow me to have a logger that has a level, name, and message without forcing me to specify them all each time I want to log something.

There are definitely other ways to offer similar functionality without curried functions, but this is a very succinct and flexible way to implement it.
