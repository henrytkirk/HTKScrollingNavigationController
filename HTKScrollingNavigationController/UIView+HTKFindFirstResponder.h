//
//  UIView+HTKFindFirstResponder.h
//  HTKScrollingNavigation
//
//  Created by Henry T Kirk on 9/22/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Category that returns the current first responder object.
 */
@interface UIView (HTKFindFirstResponder)

/**
 * Returns first responder
 */
- (id)findFirstResponder;

@end
