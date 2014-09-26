//
//  UIView+HTKFindFirstResponder.m
//  HTKScrollingNavigation
//
//  Created by Henry T Kirk on 9/22/14.
//  Copyright (c) 2014 Henry T Kirk. All rights reserved.
//

#import "UIView+HTKFindFirstResponder.h"

@implementation UIView (HTKFindFirstResponder)

- (id)findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        id responder = [subView findFirstResponder];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end
