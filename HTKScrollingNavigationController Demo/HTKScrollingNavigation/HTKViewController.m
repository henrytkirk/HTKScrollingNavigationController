//
//  HTKViewController.m
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

#import "HTKViewController.h"
#import "HTKScrollingNavigationController.h"
#import "HTKSampleViewController.h"

@interface HTKViewController ()

/**
 * Our main scrolling navigation controller
 */
@property (nonatomic, strong) HTKScrollingNavigationController *navController;

@end

@implementation HTKViewController

- (void)loadView {
    // create base view
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // show nav controller button
    UIButton *showNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showNavButton.translatesAutoresizingMaskIntoConstraints = NO;
    showNavButton.backgroundColor = [UIColor darkGrayColor];
    [showNavButton setTitle:@"Show Demo" forState:UIControlStateNormal];
    [showNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showNavButton addTarget:self action:@selector(userDidTapShowNavButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showNavButton];
    
    // constrain it
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showNavButton(125)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(showNavButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[showNavButton(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(showNavButton)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:showNavButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:showNavButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Show our demo
    [self userDidTapShowNavButton:nil];
}

/**
 * Shows sample nav
 */
- (void)userDidTapShowNavButton:(id)sender {

    // create sample nav controller and add sample view to it
    HTKSampleViewController *sampleController = [[HTKSampleViewController alloc] init];
    self.navController = [[HTKScrollingNavigationController alloc] initWithRootViewController:sampleController];
    // show "modally" using helper.
    [self.navController showInParentViewController:self withDimmedBackground:YES];
}

@end
