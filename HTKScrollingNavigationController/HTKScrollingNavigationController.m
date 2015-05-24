//
//  HTKScrollingNavigationController.m
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

#import "HTKScrollingNavigationController.h"
#import "HTKScrollingNavigationCollectionViewLayout.h"
#import "UIView+HTKFindFirstResponder.h"

/**
 * Default animation duration
 */
static CGFloat HTKScrollingNavigationAnimationDuration = 0.5f;

/**
 * Extends UIViewController to add scrolling navigation controller property
 */
@interface UIViewController (HTKScrollingNavigationControllerPrivateAdditions)

/**
 * If not nil, the view controller is on the scrolling navigation controller stack
 */
@property (nonatomic, readwrite) HTKScrollingNavigationController *scrollingNavigationController;

@end

/**
 * Cell identifier
 */
static NSString *scrollingCellIdentifier = @"scrollingCellIdentifier";

@interface HTKScrollingNavigationController () <UICollectionViewDataSource, UICollectionViewDelegate, HTKScrollingNavigationCollectionViewLayoutDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

/**
 * Main view
 */
@property (nonatomic, strong) UICollectionView *view;

/**
 * Array that holds our navigation stack of view controllers
 */
@property (nonatomic, strong) NSMutableArray *viewControllerStackArray;

/**
 * If the navigation is currently scrolling or not
 */
@property (nonatomic, getter = isScrolling) BOOL scrolling;

/**
 * If keyboard is present or not
 */
@property (nonatomic) BOOL keyboardInView;

/**
 * Amount that was adjusted for keyboard in view
 */
@property (nonatomic) CGFloat keyboardOffset;

/**
 * Handles user tap on background
 */
- (void)handleUserTapOnBackground:(UITapGestureRecognizer *)tapRecognizer;

/**
 * Scrolls to the cell at indexPath with completion block. This method solves
 * the problem where cells typically disappear when the cv takes into account the
 * ending contentOffset during a scroll that would move the cell offscreen.
 */
- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath withCompletionBlock:(void (^)(BOOL finished))completionBlock;

/**
 * Resets the view controllers on the stack (for use with dismissal)
 */
- (void)resetViewStackControllerArray;

/**
 * Handles notification when keyboard will show
 */
- (void)keyboardWillShow:(NSNotification *)notification;

/**
 * Handles notification when keyboard will hide
 */
- (void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation HTKScrollingNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        _viewControllerStackArray = [NSMutableArray array];
        // Add root view
        // add to stack, relayout
        rootViewController.scrollingNavigationController = self;
        [_viewControllerStackArray addObject:rootViewController];
        
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)loadView {

    // build our view
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[HTKScrollingNavigationCollectionViewLayout alloc] init]];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    // register cell
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:scrollingCellIdentifier];
    // set delegate for layout
    HTKScrollingNavigationCollectionViewLayout *flowLayout = (HTKScrollingNavigationCollectionViewLayout *)collectionView.collectionViewLayout;
    flowLayout.delegate = self;

    // add background view to collectionView
    UIView *backgroundView = [[UIView alloc] initWithFrame:collectionView.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTapOnBackground:)];
    tapGesture.delegate = self;
    [backgroundView addGestureRecognizer:tapGesture];
    collectionView.backgroundView = backgroundView;
    
    // set scrolling to disabled. future revision will account for
    // "popping" when scrolling to prior item.
    collectionView.scrollEnabled = NO;

    self.view = collectionView;
    // enable scrolling only if we have more than one on the stack
    self.view.scrollEnabled = (self.viewControllerStackArray.count > 1);
    // set background to clear
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Gesture actions

- (void)handleUserTapOnBackground:(UITapGestureRecognizer *)tapRecognizer {
    
    // don't respond if we're scrolling
    if (self.isScrolling) {
        return;
    }
    
    // default
    BOOL shouldPop = YES;
    // check if delegate responds
    if ([self.scrollingNavigationDelegate respondsToSelector:@selector(shouldPopViewControllerOnBackgroundTap)]) {
        shouldPop = [self.scrollingNavigationDelegate shouldPopViewControllerOnBackgroundTap];
    }
    if (shouldPop) {
        // notify delegate we're removing it from screen
        if ([self.scrollingNavigationDelegate respondsToSelector:@selector(willDismissViewController:fromParentViewController:)]) {
            UIViewController *controller = [self.viewControllerStackArray lastObject];
            [self.scrollingNavigationDelegate willDismissViewController:controller fromParentViewController:self];
        }
        UIViewController *poppedController = [self popViewControllerAnimated:YES];
        // We're only view on stack, so we should close
        if (!poppedController) {
            [self dismissFromParentControllerAnimated:YES];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark Push/Pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated { 

    // Don't do anything if we're moving
    if (self.isScrolling) {
        return;
    }
    
    // add to stack, relayout
    viewController.scrollingNavigationController = self;
    [self.viewControllerStackArray addObject:viewController];
    
    NSUInteger viewControllerIndex = MAX(self.viewControllerStackArray.count-1, 0);
    // our controllers indexPath
    NSIndexPath *controllerIndexPath = [NSIndexPath indexPathForRow:viewControllerIndex inSection:0];

    // add item
    [UIView performWithoutAnimation:^{
        [self.view insertItemsAtIndexPaths:@[controllerIndexPath]];
    }];
    
    // scroll to new item if we have more than one on stack
    if (self.viewControllerStackArray.count > 1) {
        [self scrollToCellAtIndexPath:controllerIndexPath withCompletionBlock:nil];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    // Don't do anything if we're moving
    if (self.isScrolling) {
        return nil;
    }
    
    // check if stack is at root
    if (self.viewControllerStackArray.count == 1) {
        // return nil and do nothing
        return nil;
    }
    
    NSInteger lastViewControllerIndex = self.viewControllerStackArray.count-1;
    UIViewController *viewController = [self.viewControllerStackArray lastObject];

    // our previous controllers indexPath we will move to
    NSIndexPath *prevItemIndexPath = [NSIndexPath indexPathForRow:lastViewControllerIndex-1 inSection:0];

    __weak HTKScrollingNavigationController *weakSelf = self;
    [self scrollToCellAtIndexPath:prevItemIndexPath withCompletionBlock:^(BOOL finished) {
        // remove reference
        viewController.scrollingNavigationController = nil;
        // remove from parent
        [viewController removeFromParentViewController];
        // remove from array
        [self.viewControllerStackArray removeLastObject];
        // remove from collectionView
        [UIView performWithoutAnimation:^{
            [weakSelf.view deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:lastViewControllerIndex inSection:0]]];
        }];
    }];

    // return controller just popped
    return viewController;
}

#pragma mark UICollectionView Delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewControllerStackArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:scrollingCellIdentifier forIndexPath:indexPath];
    // remove existing view
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // basic cell properties
    cell.backgroundColor = [UIColor clearColor];
    
    // Get the view Controller to show
    UIViewController *controller = self.viewControllerStackArray[indexPath.row];
    
    // add to cell
    [controller willMoveToParentViewController:self];
    [cell addSubview:controller.view];
    [controller didMoveToParentViewController:self];
        
    return cell;
}

#pragma mark HTKScrollingNavigationCollectionViewLayoutDelegate

- (CGSize)sizeForViewControllerAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.viewControllerStackArray.count - 1) {
        return CGSizeZero; // Not found
    }
    // return actual size of the view
    UIViewController *controller = self.viewControllerStackArray[indexPath.row];
    return controller.view.frame.size;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.scrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.scrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.scrolling = NO;
}

#pragma mark Presentation Helpers

- (void)showInParentViewController:(UIViewController *)viewController  {
    [self showInParentViewController:viewController withDimmedBackground:NO];
}

- (void)showInParentViewController:(UIViewController *)viewController withDimmedBackground:(BOOL)dimmedBackground {

    self.view.alpha = 0.01; // trick to make sure cells are drawn but not really visible.

    // add to subview
    [self willMoveToParentViewController:viewController];
    [viewController.view addSubview:self.view];
    
    // if dimmed, set to black w/ alpha
    if (dimmedBackground) {
        self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    
    // constrain it
    UIView *ourView = self.view;
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ourView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ourView)]];
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ourView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ourView)]];
    [viewController.view layoutIfNeeded];
    
    CGPoint offScreenOffset = self.view.contentOffset;
    offScreenOffset.y = -CGRectGetHeight([[UIScreen mainScreen] applicationFrame]);
    [self.view setContentOffset:offScreenOffset animated:NO];

    [UIView animateWithDuration:HTKScrollingNavigationAnimationDuration delay:0.10 usingSpringWithDamping:0.8 initialSpringVelocity:12 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.contentOffset = CGPointZero;
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self didMoveToParentViewController:viewController];
    }];
}

- (void)dismissFromParentControllerAnimated:(BOOL)animated {
    
    // Completion block run after dismissal
    void(^completionBlock)(void) = ^{
        // reset our stack
        [self resetViewStackControllerArray];
        // cleanup
        [self.view removeFromSuperview];
        [self.viewControllerStackArray removeAllObjects];
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        
        if ([self.scrollingNavigationDelegate respondsToSelector:@selector(didDismissFromParentViewController:)]) {
            [self.scrollingNavigationDelegate didDismissFromParentViewController:self];
        }
    };

    // notify delegate we're removing it from screen
    if ([self.scrollingNavigationDelegate respondsToSelector:@selector(willDismissViewController:fromParentViewController:)]) {
        [self.scrollingNavigationDelegate willDismissViewController:[self.viewControllerStackArray lastObject] fromParentViewController:self];
    }

    // get center cell
    NSIndexPath *indexPath = [self.view indexPathForItemAtPoint:self.view.center];
    UICollectionViewCell *cell = [self.view cellForItemAtIndexPath:indexPath];
    // determine content offset
    CGPoint offScreenOffset = self.view.contentOffset;
    // how far we need to move offscreen to dismiss plus 1 (otherwise cell isn't drawn)
    offScreenOffset.y = -(CGRectGetHeight(self.view.frame) - CGRectGetMinY(cell.frame)) + 1;
    
    if (animated) {
        [UIView animateWithDuration:HTKScrollingNavigationAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:5 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            // scroll offscreen
            self.view.contentOffset = offScreenOffset;
            self.view.alpha = 0.01;
        } completion:^(BOOL finished) {
            completionBlock();
        }];
        
    } else {
        completionBlock();
    }
}

#pragma mark Helpers

- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath withCompletionBlock:(void (^)(BOOL finished))completionBlock {
    
    // get center cell
    CGPoint centerPoint = CGPointMake(self.view.center.x + self.view.contentOffset.x,self.view.center.y + self.view.contentOffset.y);
    // determine indexPath of center
    NSIndexPath *centerIndexPath = [self.view indexPathForItemAtPoint:centerPoint];
    // get our cell
    UICollectionViewCell *cell = [self.view cellForItemAtIndexPath:centerIndexPath];
    
    CGFloat offSetY = indexPath.row * CGRectGetHeight(self.view.bounds);
    CGFloat offsetToMoveToY = 0;
    CGFloat pointsToShow = 5;
    
    // direction
    if (indexPath.row < centerIndexPath.row) {
        // moving down, so move so a little part of cell is still shown (otherwise it
        // will disappear)
        offsetToMoveToY = self.view.contentOffset.y + (self.view.contentOffset.y - CGRectGetMaxY(cell.frame)) + pointsToShow;
    } else {
        // moving up, so move so a little part of cell is still shown (otherwise it
        // will disappear)
        offsetToMoveToY = CGRectGetMaxY(cell.frame) - pointsToShow;
    }
    
    // move first "step" so only a little bit is shown
    [UIView animateWithDuration:HTKScrollingNavigationAnimationDuration/2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.contentOffset = CGPointMake(0, offsetToMoveToY);
    } completion:^(BOOL finished) {
        // finish animation off with bounce and move to where we need to be
        [UIView animateWithDuration:HTKScrollingNavigationAnimationDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.view.contentOffset = CGPointMake(0, offSetY);
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock(YES);
            }
        }];
    }];
}

- (void)resetViewStackControllerArray {
    for (UIViewController *controller in [self.viewControllerStackArray mutableCopy]) {
        controller.scrollingNavigationController = nil;
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (self.keyboardInView) {
        return;
    }
    
    // set offset
    self.keyboardOffset = 0;
    NSUInteger offsetBuffer = 40;
    
    // Get the currently visible cell
    CGPoint centerPoint = CGPointMake(self.view.center.x + self.view.contentOffset.x,self.view.center.y + self.view.contentOffset.y);
    // determine indexPath of center
    NSIndexPath *centerIndexPath = [self.view indexPathForItemAtPoint:centerPoint];
    // get our cell
    UICollectionViewCell *cell = [self.view cellForItemAtIndexPath:centerIndexPath];
    
    // get the size of the keyboard
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    // get our first responder
    UIView *firstResponderView = [cell findFirstResponder];
    if (!firstResponderView) {
        return; // None found
    }
    CGRect responderFrame = [self.view convertRect:firstResponderView.frame fromView:cell];
    
    if (CGRectIntersectsRect(responderFrame, keyboardFrame)) {
        // Move the frame up the difference in Y overlap
        self.keyboardOffset = (CGRectGetMaxY(responderFrame) - CGRectGetMinY(keyboardFrame)) + offsetBuffer;
        // Animate out of the way
        [UIView animateWithDuration:0.3 animations:^{
            self.view.contentOffset = CGPointMake(self.view.contentOffset.x, self.view.contentOffset.y + self.keyboardOffset);
        } completion:^(BOOL __unused finished) {
            self.keyboardInView = YES;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Animate back in place
    [UIView animateWithDuration:0.3 animations:^{
        self.view.contentOffset = CGPointMake(self.view.contentOffset.x, self.view.contentOffset.y - self.keyboardOffset);
    } completion:^(BOOL __unused finished) {
        self.keyboardInView = NO;
    }];
}

@end
