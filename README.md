HTKScrollingNavigationController
======================

Scrolling navigation controller for iOS 7.x with slide-up transitions. It uses UICollectionView under the hood and currently supports vertical sliding.

Example usage:

'''Objective-C
    HTKSampleViewController *sampleController = [[HTKSampleViewController alloc] init];
    // pass sampleViewController as root
    HTKScrollingNavigationController *navController = [[HTKScrollingNavigationController alloc] initWithRootViewController:sampleController];
    // show "modally" using helper.
    [navController showInParentViewController:self withDimmedBackground:YES];
'''

Sample video:

[![YouTube Sample Video](http://img.youtube.com/vi/SplhvitXf88/0.jpg)](http://www.youtube.com/watch?v=SplhvitXf88)

Screen shot:

![Sample Screenshot](http://htk-github.s3.amazonaws.com/HTKScrollingNavigationController_SS1.png)


Questions? Email: henrytkirk@gmail.com or Web: http://www.henrytkirk.info