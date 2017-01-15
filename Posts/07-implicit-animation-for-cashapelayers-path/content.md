I was recently working on a project that required some custom drawing that also needed to be animated while resizing. I started out using [Core Graphics](http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CGContext/Reference/reference.html#//apple_ref/doc/uid/TP30000950) in `-drawRect` of my custom view but when it came around to animating the drawing it was not possible.

I decided to try out using a [CAShapeLayer](https://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CAShapeLayer_class/Reference/Reference.html) that allows you to set a path, line color, fill color and more. This worked beautifully for drawing but caused headaches at first as examples online all manually animated the path property of [CAShapeLayer](https://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CAShapeLayer_class/Reference/Reference.html) with a [CABasicAnimation](https://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CABasicAnimation_class/Introduction/Introduction.html). My problem was that the view in question was within a table view cell and I was not explicitly resizing it so I couldn't find an elegant way to add my custom animation.

Then I found a method on [CALayer](https://developer.apple.com/library/ios/#documentation/graphicsimaging/reference/CALayer_class/Introduction/Introduction.html) called [-actionForKey](https://developer.apple.com/library/mac/documentation/graphicsimaging/reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/instm/CALayer/actionForKey:). This is called each time a property is changed to determine what action should be taken. You can return an animation for whatever property you desire. In my case I wanted to implicitly animate the **path** property so I implemented my own subclass of CAShapeLayer and implemented [-actionForKey](https://developer.apple.com/library/mac/documentation/graphicsimaging/reference/CALayer_class/Introduction/Introduction.html#//apple_ref/occ/instm/CALayer/actionForKey:) in the following way:

    // objectivec
    - (id<CAAction>)actionForKey:(NSString *)event {
        if ([event isEqualToString:@"path"]) {
            CABasicAnimation *animation = [CABasicAnimation
                animationWithKeyPath:event
            ];
            animation.duration = [CATransaction animationDuration];
            animation.timingFunction = [CATransaction animationTimingFunction];
            return animation;
        }
        return [super actionForKey:event];
    }

Basically this method creates a basic animation which automatically uses the before and after value. The only things I have to set are the duration and timingFunction. I use the defaults in [CATransaction](http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CATransaction_class/Introduction/Introduction.html) so that I can override them from an external class if necessary with [+setAnimationDuration:](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CATransaction_class/Introduction/Introduction.html#//apple_ref/occ/clm/CATransaction/setAnimationDuration:) and [+setAnimationTimingFunction:](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CATransaction_class/Introduction/Introduction.html#//apple_ref/occ/clm/CATransaction/setAnimationTimingFunction:).

Now any time the path is changed on the layer it will automatically animate it. I can reset the path in my `-layoutSubviews` and not worry about the rest.
