//
//  HTKScrollingNavigationCollectionViewLayout.m
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

#import "HTKScrollingNavigationCollectionViewLayout.h"

@interface HTKScrollingNavigationCollectionViewLayout ()

/**
 * Our layout attributes we've previously created.
 */
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;

@end

@implementation HTKScrollingNavigationCollectionViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.itemsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)prepareLayout {

    // remove prior
    [self.itemsDictionary removeAllObjects];
    
    for (NSInteger index = 0; index < [self.collectionView numberOfItemsInSection:0]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        // if first row, set to center
        if (indexPath.row == 0) {
            attributes.center = self.collectionView.center;
            // set attributes
            self.itemsDictionary[indexPath] = attributes;
            continue;
        }
        // grab previous
        NSIndexPath *prevIndexPath = [NSIndexPath indexPathForRow:index-1 inSection:0];
        UICollectionViewLayoutAttributes *prevAttributes = self.itemsDictionary[prevIndexPath];
        // move down off-screen
        attributes.center = CGPointMake(prevAttributes.center.x, CGRectGetHeight(self.collectionView.bounds) + prevAttributes.center.y);

        // set attributes
        self.itemsDictionary[indexPath] = attributes;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    [self.itemsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UICollectionViewLayoutAttributes *attributes = (UICollectionViewLayoutAttributes *)obj;
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [layoutAttributes addObject:attributes];
        }
    }];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes;
    
    if (self.itemsDictionary[indexPath]) {
        attributes = [self.itemsDictionary[indexPath] copy];
        return attributes;
    }

    // create since we don't already have
    attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // resize
    CGRect itemRect = attributes.frame;
    if ([self.delegate respondsToSelector:@selector(sizeForViewControllerAtIndexPath:)]) {
        itemRect.size = [self.delegate sizeForViewControllerAtIndexPath:attributes.indexPath];
    }
    attributes.frame = itemRect;
    
    return attributes;
}

- (CGSize)collectionViewContentSize {
     CGSize size = self.collectionView.bounds.size;
    // our content size should only allow for scrolling up to two views at a time
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    size.height = CGRectGetHeight(self.collectionView.bounds) * count;
    return size;
}

@end
