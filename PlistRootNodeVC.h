//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface PlistRootNodeVC : UITableViewController 

//set key moving route  
@property (nonatomic, retain) NSMutableArray *keyTree;
@property (nonatomic, retain, setter=setPlist:) id plistRoot;

@end
