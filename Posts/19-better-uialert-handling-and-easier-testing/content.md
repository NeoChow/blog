# The Problem

The normal way to handle UIAlerts can be somewhat cumbersome. If you are interested in what the user has selected in the alert, you must make an object the delegate of the alert and implement `-alertView:clickedButtonAtIndex:`. There are two major things I don’t like about this paradigm:

1. The logic of what to do when an alert is dismissed is separated from the logic to display it which are normally strongly connected. In order to read the code you have to understand the displaying and dismissing as separate entities instead of being able to visualize the entire flow of the process in one place.
2. If multiple alerts are being used, the delegate callback gets filled with multiple if statements to determine which alert it is handling, further hurting the readability

# The Improvement

To fix these issues, I designed my own category on NSObject to display and handle alerts. Essentially, you ask the object to display an alert and optionally provide a block that is called when a button is clicked that provides the name of the button clicked. The interface of the category looks like this:

    // objectivec"
    // NSObject+DWAlert.h
    @interface NSObject (DWAlert)

    - (void)displayAlertWithTitle:(NSString *)title
        message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles
        onButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked;

    @end

The cancel button title and other button titles are all optional. An example usage of this interface is:

    // objectivec
    [self displayAlertWithTitle:@"Alert!"
        message:@"An alert message"
        cancelButtonTitle:nil
        otherButtonTitles:@[@"Ok", @"Other"]
        onButtonClicked:^(NSString *buttonTitle) {
            if ([buttonTitle isEqualToString:@"Other"]) {
                // Perform some action
            }
        }
    ];

That is a concise block of logic. You can see everything that the user sees including what choices they have and what will happen with each choice that they pick.

To implement this, I created a private class that acts as the delegate and is attached to the object as an [associative reference](http://nshipster.com/associated-objects/). The delegate is created with a callback block for when the alert is clicked. The implementation looks like this:

    // objectivec
    // NSObject+DWAlert.m
    #import "NSObject+DWAlert.h"

    #import <objc/runtime.h>

    @interface BlockAlertViewDelegate : NSObject<UIAlertViewDelegate>

    @property (nonatomic, copy) void(^onButtonClicked)(NSString *buttonTitle);

    - (id)initWithOnButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked;

    @end

    @implementation BlockAlertViewDelegate

    - (id)initWithOnButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked {
        self = [super init];
        if (self) {
            self.onButtonClicked = onButtonClicked;
        }
        return self;
    }

    - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (self.onButtonClicked) {
            self.onButtonClicked([alertView buttonTitleAtIndex:buttonIndex]);
        }
    }

    @end

    @implementation NSObject (DWAlert)

    - (void)displayAlertWithTitle:(NSString *)title
        message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles
        onButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked
    {
        BlockAlertViewDelegate *delegate = [[BlockAlertViewDelegate alloc]
            initWithOnButtonClicked:onButtonClicked
        ];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
            message:me}ssage
            delegate:delegate
            cancelButtonTitle:cancelButtonTitle
            otherButtonTitles:nil
        ];
        for (NSString *otherButtonTitle in otherButtonTitles) {
            [alert addButtonWithTitle:otherButtonTitle];
        }

        static const NSString *sDelegateAssociatedObjectKey = @"DWAlertDelegate";
        objc_setAssociatedObject(
            alert,
            &sDelegateAssociatedObjectKey,
            delegate,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC
        );

        [alert show];
    }

    @end

# Easy Testing

Not only does this improve the readability, but it also makes it much easier to write tests for with the help of a test helper class. My test helper lets me write a test like this:

    // objectivec
    [DWAlertSpecHelper executeWithHelper:^(DWAlertSpecHelper *alertHelper) {
        // Perform something that should trigger an alert

        XCTAssertEqualObjects(alertHelper.title, @“Expected Title);
        XCTAssertEqualObjects(alertHelper.message, @“expected message”);
        XCTAssertNil(alertHelper.cancelButtonTitle);
        NSArray *expectedTitles = @[@"Ok", @"Sign In"];
        XCTAssertEqualObjects(alertHelper.otherButtonTitles, expectedTitles);

        [alertHelper dismissWithButtonWithTitle:@"Sign In"];

        // Test post clicked conditions
    }];

Testing UIAlerts are otherwise impossible / very difficult because there is no good way to check if an alert is being displayed nor a way to programmatically dismiss it.

The helper class [swizzles](http://nshipster.com/method-swizzling/) the implementation above of `-displayAlertWithTitle:message:cancelButtonTitle:otherButtonTitles:onButtonClicked` with an implementation that simply captures the arguments for testing and allows the manual triggering of the clicked callback. (No alert is actually displayed during testing, we just want to make sure the method is called with the correct arguments). My implementation looks like this:

    // objectivec
    // DWAlertSpecHelper.h
    @interface DWAlertSpecHelper : NSObject

    @property (nonatomic, strong, readonly) NSString *title;
    @property (nonatomic, strong, readonly) NSString *message;
    @property (nonatomic, strong, readonly) NSString *cancelButtonTitle;
    @property (nonatomic, strong, readonly) NSArray *otherButtonTitles;

    + (void)executeWithHelper:(void(^)(DWAlertSpecHelper *alertHelper))task;
    - (void)dismissWithButtonWithTitle:(NSString *)buttonTitle;
    - (void)reset;

    @end

    // DWAlertSpecHelper.m
    #import "DWAlertSpecHelper.h"

    #import <objc/runtime.h>

    #import "NSObject+DWAlert.h"

    @interface DWAlertSpecHelper ()

    @property (nonatomic, strong, readwrite) NSString *title;
    @property (nonatomic, strong, readwrite) NSString *message;
    @property (nonatomic, strong, readwrite) NSString *cancelButtonTitle;
    @property (nonatomic, strong, readwrite) NSArray *otherButtonTitles;
    @property (nonatomic, copy) void(^onButtonClicked)(NSString *buttonTitle);

    + (void)swizzleMethods;

    + (instancetype)singleton;

    - (void)fakeDisplayAlertWithTitle:(NSString *)title
        message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles
        onButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked;

    @end

    @implementation DWAlertSpecHelper

    + (instancetype)singleton {
        static id sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
        return sharedInstance;
    }

    + (void)swizzleMethods {
        Method method1 = class_getInstanceMethod(
            [NSObject class],
            @selector(displayAlertWithTitle:message:cancelButtonTitle:otherButtonTitles:onButtonClicked:)
        );
        Method method2 = class_getInstanceMethod(
            [DWAlertSpecHelper class],
            @selector(fakeDisplayAlertWithTitle:message:cancelButtonTitle:otherButtonTitles:onButtonClicked:)
        );
        method_exchangeImplementations(method1, method2);
    }

    + (void)executeWithHelper:(void(^)(DWAlertSpecHelper *alertHelper))task {
        if (!task) { return; }

        [[DWAlertSpecHelper singleton] reset];
        [self swizzleMethods];
        task([DWAlertSpecHelper singleton]);
        [self swizzleMethods];
    }

    - (void)fakeDisplayAlertWithTitle:(NSString *)title
        message:(NSString *)message
        cancelButtonTitle:(NSString *)cancelButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles
        onButtonClicked:(void(^)(NSString *buttonTitle))onButtonClicked
    {
        [DWAlertSpecHelper singleton].title = title;
        [DWAlertSpecHelper singleton].message = message;
        [DWAlertSpecHelper singleton].cancelButtonTitle = cancelButtonTitle;
        [DWAlertSpecHelper singleton].otherButtonTitles = otherButtonTitles;
        [DWAlertSpecHelper singleton].onButtonClicked = onButtonClicked;
    }

    - (void)dismissWithButtonWithTitle:(NSString *)buttonTitle {
        if (self.onButtonClicked) {
            self.onButtonClicked(buttonTitle);
        }
    }

    - (void)reset {
        self.title = nil;
        self.message = nil;
        self.cancelButtonTitle = nil;
        self.otherButtonTitles = nil;
        self.onButtonClicked = nil;
    }

    @end
