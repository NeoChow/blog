Testing asynchronous code in Objective-C can be a real pain unless you make one simple change to the way you program it in the first place. Instead of using Apple’s APIs directly everywhere, it is infinitely easier to test if you encapsulate all asynchronous calls into your own wrapper object. A simple wrapper object would provide a method to execute a block in the background, and a method to execute a block in the foreground. It could look like this:

    // objectivec
    // DWTaskDispatcher.h
    @interface DWTaskDispatcher : NSObject

    + (instancetype)singleton;

    - (void)executeTaskInForeground:(void(^)())task;
    - (void)executeTaskInBackground:(void(^)())task;

    @end

    //  DWTaskDispatcher.m
    #import “DWTaskDispatcher.h”

    @interface DWTaskDispatcher ()

    @property (nonatomic, strong) NSOperationQueue *backgroundOperationQueue;

    @end

    @implementation DWTaskDispatcher

    + (instancetype)singleton {
        static id sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
        return sharedInstance;
    }

    - (id)init {
        self = [super init];
        if (self) {
            self.backgroundOperationQueue = [NSOperationQueue new];
            self.backgroundOperationQueue.maxConcurrentOperationCount = 3;
        }
        return self;
    }

    - (void)executeTaskInForeground:(void(^)())task {
        dispatch_async(dispatch_get_main_queue(), task);
    }

    - (void)executeTaskInBackground:(void(^)())task {
        NSBlockOperation *operation = [NSBlockOperation
        blockOperationWithBlock:task];
        [self.backgroundOperationQueue addOperation:operation];
    }

    @end
    </code></pre>

Whenever something should be done asynchronously, one would do the following:

    // objectivec
    [[DWTaskDispatcher singleton] executeTaskInBackground:^{

        // Perform a background operation

        [[DWTaskDispatcher singleton] executeTaskInForeground:^{
            // Perform any notifications or calls to other
            // objects if necessary
        }];
    }];

Making this simple encapsulation provides an opportunity to easily test all of your asynchronous code without having to test private methods or any other type of unrecommended behavior. A test helper would provide a way to temporarily replace what will be returned from the singleton method with a fake subclass that collects tasks to be executed and allows the test to manually execute tasks when desired. The test helper could look like this:

    // objectivec
    // DWTaskDisptacherTestHelper.m
    #import "DWTaskDispatcher.h”

    @interface DWTaskDisptacherTestHelper : DWTaskDispatcher

    + (void)executeWithFakeSingleton:(void(^)(DWTaskDisptacherTestHelper *taskDispatcherTestHelper))testBlock;

    - (void)performNextBackgroundTask;
    - (void)performNextForegroundTask;

    @end

    // DWTaskDispatcherTestHelper.m
    #import "DWTaskDisptacherTestHelper.h”

    #import <objc/runtime.h>

    @interface DWTaskDisptacherTestHelper ()

    @property (nonatomic, strong) NSMutableArray *backgroundTasks;
    @property (nonatomic, strong) NSMutableArray *foregroundTasks;

    + (void)fakeSingleton;
    + (void)restoreSingleton;

    @end

    static DWTaskDisptacherTestHelper *fakeTaskDispatcher = nil;

    @implementation DWTaskDisptacherTestHelper

    + (void)executeWithFakeSingleton:(void(^)(DWTaskDisptacherTestHelper *taskDispatcherTestHelper))testBlock {
        fakeTaskDispatcher = [DWTaskDisptacherTestHelper new];
        [self fakeSingleton];
        if (task) {
            task(fakeTaskDispatcher);
        }
        [self restoreSingleton];
        fakeTaskDispatcher = nil;
    }

    + (instancetype)singleton {
        return fakeTaskDispatcher;
    }

    - (id)init {
        self = [super init];
        if (self) {
            self.backgroundTasks = [NSMutableArray array];
            self.foregroundTasks = [NSMutableArray array];
        }
        return self;
    }

    - (void)executeTaskInBackground:(void (^)())task {
        [self.backgroundTasks addObject:[task copy]];
    }

    - (void)executeTaskInForeground:(void(^)())task {
        [self.foregroundTasks addObject:[task copy]];
    }

    - (void)performNextForegroundTask {
        if (self.foregroundTasks.count > 0) {
            void(^task)() = self.foregroundTasks[0];
            if (task) {
                task();
            }
            [self.foregroundTasks removeObjectAtIndex:0];
        }
    }

    - (void)performNextBackgroundTask {
        if (self.backgroundTasks.count > 0) {
            void(^task)() = self.backgroundTasks[0];
            if (task) {
                task();
            }
            [self.backgroundTasks removeObjectAtIndex:0];
        }
    }

    #pragma mark - Private Methods

    + (void)fakeSingleton {
        Method orig_method = class_getClassMethod(
            [DWTaskManager class],
            @selector(singleton)
        );
        Method new_method = class_getClassMethod(
            [self class],
            @selector(singleton)
        );
        method_exchangeImplementations(orig_method, new_method);
    }

    + (void)restoreSingleton {
        Method new_method = class_getClassMethod(
            [DWTaskManager class],
            @selector(singleton)
        );
        Method orig_method = class_getClassMethod(
            [self class],
            @selector(singleton)
        );
        method_exchangeImplementations(orig_method, new_method);
    }

    @end

A test would then use the helper like so:

    // objectivec
    - (void)testAsynchronousTask {
        [DWTaskDisptacherTestHelper 
            executeWithFakeSingleton:^(DWTaskDisptacherTestHelper *taskDispatcherTestHelper) {
                // Perform some action that should call an asynchronous task

                // Test anything that should have been done before moving into the background

                [taskDispatcherTestHelper performNextBackgroundTask];
                [taskDispatcherTestHelper performNextForegroundTask];

                // Test that asynchronous task did what it should have done
            }
        ];
    }

This is just a relatively simple example, but I think it displays the effectiveness of this technique. It makes it easy to test the execution of tasks in any order you like without having to worry about waiting for true background tasks to finish.

It also leaves the doors open to make an even more powerful version. You can add features like throwing exceptions if a test asks the helper to perform a task that hasn’t been queued up. You can provide an interface on the task dispatcher to have tasks of different priority. You can provide a setting on the helper to automatically execute tasks as they come in if you don’t care what order they are performed in. There isn’t much of a limit to what you can do, but no matter what, it will save many headaches and prevent many hacks when trying write tests for asynchronous code.
