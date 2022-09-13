//
//  HTKSampleViewController.m
//  HTKScrollingNavigation
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

#import "HTKSampleViewController.h"
#import "UIViewController+HTKScrollingNavigationControllerAdditions.h"

@interface HTKSampleViewController ()

@end

@implementation HTKSampleViewController

- (void)loadView {

    // create some random size.
    CGSize randomSize = CGSizeMake(arc4random_uniform(500) + 250, arc4random_uniform(250) + 250);
    CGRect viewFrame = CGRectMake(0, 0, randomSize.width, randomSize.height);
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    
    // randomly size and determine background color
    NSArray *bgColorArray = @[[UIColor redColor], [UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor], [UIColor yellowColor], [UIColor whiteColor], [UIColor cyanColor], [UIColor magentaColor], [UIColor brownColor]];
    // set random color
    self.view.backgroundColor = bgColorArray[arc4random_uniform((int)bgColorArray.count)];
    
    // add two buttons one for push, one for pop
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pushButton.translatesAutoresizingMaskIntoConstraints = NO;
    pushButton.backgroundColor = [UIColor blackColor];
    [pushButton setTitle:@"Push!" forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pushButton addTarget:self action:@selector(userDidTapPushButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pushButton];
    
    UIButton *popButton = [UIButton buttonWithType:UIButtonTypeCustom];
    popButton.translatesAutoresizingMaskIntoConstraints = NO;
    popButton.backgroundColor = [UIColor blackColor];
    [popButton setTitle:@"Pop!" forState:UIControlStateNormal];
    [popButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [popButton addTarget:self action:@selector(userDidTapPopButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:popButton];
    
    // close / dismiss button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    closeButton.backgroundColor = [UIColor blackColor];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(userDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // constrain views
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(pushButton, popButton, closeButton);
    // vertically
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pushButton(44)]-20-[popButton(==pushButton)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[closeButton(44)]" options:0 metrics:nil views:viewDict]];
    // Horizontally
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[closeButton(75)]" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pushButton(100)]" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[popButton(100)]" options:0 metrics:nil views:viewDict]];
    // align center to view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pushButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pushButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

/**
 * User taps on push button
 */
- (void)userDidTapPushButton:(id)sender {
    
    HTKSampleViewController *sampleViewController = [[HTKSampleViewController alloc] init];
    [self.scrollingNavigationController pushViewController:sampleViewController animated:YES];
}

/**
 * User taps on pop button
 */
- (void)userDidTapPopButton:(id)sender {
    
    [self.scrollingNavigationController popViewControllerAnimated:YES];
}

/**
 * User taps on close button
 */
- (void)userDidTapCloseButton:(id)sender {
    
    [self.scrollingNavigationController dismissFromParentControllerAnimated:YES];
}

@end
