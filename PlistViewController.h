//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlistRootNodeVC.h"
#import "PlistRootNodeShowVC.h"

@interface PlistViewController : UITableViewController <UINavigationControllerDelegate>

//get file path
@property (nonatomic, copy) NSString *fullPath;

//plist file handler
@property (nonatomic, retain, setter=setPlist:) id plistRoot;
@end
