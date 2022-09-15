//
//  HTKScrollingNavigationController.h
//  HTKScrollingNavigationController
//
//  Created by Henry T Kirk on 7/28/14.
//
//  Copyright (c) 2014 Henry T. Kirk (http://www.henrytkirk.info)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UIKit/UIKit.h>

@class HTKScrollingNavigationController;

@protocol HTKScrollingNavigationControllerDelegate <NSObject>

@optional;

/**
 * Return YES/NO if should pop that view controller when user taps on background. Default is YES.
 */
- (BOOL)shouldPopViewControllerOnBackgroundTap:(UIViewController *)viewController;

/**
 * Called when the currently displayed viewController is about to pop off screen.
 */
- (void)willDismissViewController:(UIViewController *)viewController fromParentViewController:(HTKScrollingNavigationController *)scrollingNavigationController;

/**
 * Called when dismissFromParentControllerAnimated: is called.
 */
- (void)didDismissFromParentViewController:(HTKScrollingNavigationController *)scrollingNavigationController;

@end

/**
 * Fire this notification if you need to refresh the currently displayed content.
 */
extern NSString* const HTKRefreshScrollingNavigationControllerContent;

/**
 * A navigation controller which pushes and pops view controllers on and 
 * off the screen in a vertically scrolling fashion.
 */
@interface HTKScrollingNavigationController : UIViewController

/**
 * Delegate
 */
@property (nonatomic, weak) id<HTKScrollingNavigationControllerDelegate> scrollingNavigationDelegate;

/**
 * Convenience initializer. Loads the root view controller without animation.
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 * Pushes the view controller onto the stack with optional animation. If animated,
 * it will scroll vertically onto the screen.
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 * Removes top view controller from the stack with optional animation. If animated,
 * it will scroll vertically off the screen. If you pop the root view controller,
 * it will do nothing. Returns the view controller that was removed.
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

/**
 * Refreshes the content currently being displayed. This would be necessary for macOS resizing, etc.
 * This is also invoked when the 'HTKRefreshScrollingNavigationControllerContent' notification is posted.
 */
- (void)refreshContent;

#pragma mark Presentation Helpers

/**
 * Shows the ScrollingNavigationController in the parent controller passed with 
 * default scrolling in animation and no dimmed background.
 */
- (void)showInParentViewController:(UIViewController *)viewController;

/**
 * Shows the ScrollingNavigationController in the parent controller passed with 
 * default scrolling in animation and optional dimmed background.
 */
- (void)showInParentViewController:(UIViewController *)viewController withDimmedBackground:(BOOL)dimmedBackground;

/**
 * Dismisses the ScrollingNavigationController with optional scrolling 
 * out animation.
 */
- (void)dismissFromParentControllerAnimated:(BOOL)animated;

/// Is a ViewController of the class provided presented or not to the user.
/// Note: Presented means that it could be scrolled off-screen, and is part of the stack.
- (BOOL)isViewControllerPresented:(Class)viewControllerClass;

@end
