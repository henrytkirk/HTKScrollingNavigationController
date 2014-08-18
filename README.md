HTKScrollingNavigationController
======================

Scrolling navigation controller for iOS 7.x with slide-up transitions. It uses UICollectionView under the hood and currently supports vertical sliding.

## Adding to your project:
### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add HTKScrollingNavigationController to your project.

1. Add a pod entry for HTKScrollingNavigationController to your Podfile `pod 'HTKScrollingNavigationController', '~> 0.0.1'`
2. Install the pod(s) by running `pod install`.
3. Include `HTKScrollingNavigationController.h` where you wish to use it.
4. Include the category `UIViewController+HTKScrollingNavigationControllerAdditions.h` so your viewControllers can access the self.scrollingNavigationController property.

### Example usage:

```Objective-C
    HTKSampleViewController *sampleController =  [[HTKSampleViewController alloc] init];
    // pass sampleViewController as root
    HTKScrollingNavigationController *navController =  [[HTKScrollingNavigationController alloc] initWithRootViewController:sampleController];
    // show "modally" using helper.
    [navController showInParentViewController:self withDimmedBackground:YES];
```

## Sample video:

[![YouTube Sample Video](http://img.youtube.com/vi/SplhvitXf88/0.jpg)](http://www.youtube.com/watch?v=SplhvitXf88)

## Screen shot:

![Sample Screenshot](http://htk-github.s3.amazonaws.com/HTKScrollingNavigationController_SS1.png)


Questions? Email: henrytkirk@gmail.com or Web: http://www.henrytkirk.info