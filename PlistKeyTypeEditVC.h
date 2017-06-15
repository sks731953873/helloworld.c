//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlistKeyTypeEditVC : UITableViewController
@property (nonatomic, retain) NSMutableArray *keyTree;
@property (nonatomic, retain, setter=setPlist:) id plistRoot;
@end
