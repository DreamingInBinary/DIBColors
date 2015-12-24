# DIBColors
Add a color theme picker to your app with one line of code using a `UIView` category.

![Demo](/demo.gif?raw=true "Demo")

No auto layout or frame manipulation required.

####Installation

**Cocoapods**:

    pod 'DIBColors'
    
**Old Way:**

Drag three source files into your project:
- ColorScheme.h and .m
- ColorSchemeManager.h and .m
- UIView+DIBColors.h and .m

####Using It

Just import the `UIView` category:

    #import 'UIView+DIBColors.h'

Call it's only method on a `UIView` - this is designed to be called on `ViewController`'s `UIView`. The completion handler you
give it will be called when a color scheme is tapped, and it returns an array of the color theme:

- 1st index == Primary `UIColor`
- 2nd index == Seconary `UIColor`
- 3rd index == Tertiary `UIColor` (this is always white)
- 4th index == Use lightkeyboard `BOOL` (I didn't end up using this but it's still in the source)

The whole implementation looks like this:

    [self.view showColorPicker:^(NSArray *colors){
        //Primary Color -- colors[0];
        //Secondary Color -- colors[1];
        //Tertiary Color --  colors[2];
    }];
    
####A Bit More
This is part of some old code I am open sourcing for fun since the projects they are used in are about to be deleted or 
entirely refactored. This particular code was some of the first iOS code I ever wrote several years ago. That said,
it's very scattered and not very structured, so feel free to hack away at it as you see fit.

This was originially built for my first iOS app, [Spend Stack](https://itunes.apple.com/us/app/spend-stack/id825371644?mt=8), which reached #18 in paid apps under Finance when it released.

###Can I tweet at you?
Please do, [@jordanmorgan10](https://twitter.com/jordanmorgan10). As the mantra goes - pull requests welcome (it needs a lot of love).
