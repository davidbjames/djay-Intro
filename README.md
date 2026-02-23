# Algoriddim djay Engineering Task - David James

Onboarding flow for djay app, including custom finale page.

Supported on iPhone, including iPhone SE (1st Gen), iPhone 16 Pro and iPhone 16 Pro Max.

Portrait and lansdscape orientation.

Minimum deployment target: iOS 15.5

### Screencast

https://share.zight.com/yAuNXb2k

### Tech Used

* `UIKit` only
* `Combine`
* Core Animation - for gradients including `CAGradientLayer` and `CABasicAnimation`
* Key frame animations - for finale page
* `SpriteKit` - for finale page, nodes, particle emitters, actions
* Autolayout - dynamic/animatable portrait/landscape
* `UILayoutGuide`
* `UIPageViewController`
* `NSDefaults` and `Codable` - for onboarding state
* Swizzling for debugging layout

### Improvements

Improvements I'd like to make:
* All screens use dynamic text styles, but on the finale this can cause breakage on devices with large dynamic type. I would suggest using fixed font sizes (adjusted for device) on the finale page to accomodate the content better, but I'm open to other approaches.
* Support for dark mode. I didn't do this since there were no designs to follow, and maybe doesn't make sense for this flow anyways.
* Fine tune launch gradient image to match actual gradient layer. (it's actually pretty close right now and not noticeable)
* iPad support, including split screen and slide over (see next)
* Snapshot testing

### Caveats

* Some content is hidden to accomodate landscape and smaller screen sizes
* Used `UIView` methods I created: `isVerySmallScreen` and `isCompactVerticalSize` -- Since this is an iPhone only exercise, I took the liberty of checking for very small screens (like iPhone SE) and for landscape orientation, in order to have more precise control of layouts. Obviously, this doesn't work for iPad split screen.
