//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "UUDatePicker.h"
#import "FXCheckBox.h"
#import <UIKit/UIKit.h>

@interface PlistKeyEditViewController : UITableViewController <UITextFieldDelegate, UUDatePickerDelegate>
@property (nonatomic, retain) NSMutableArray *keyTree;
@property (nonatomic, retain, setter=setPlist:) id plistRoot;
@property (nonatomic, assign, setter=setFlag:) BOOL flag;

@end
