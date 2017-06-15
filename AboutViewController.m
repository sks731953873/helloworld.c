//
//  AboutViewController.m
//  iPREditor
//
//  Created by Luke on 3/11/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController


static NSString *APPLOGO = @"APPLOGO";
static NSString *SOFTWARE = @"SOFTWARE";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *infoPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    NSString *version_String = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    UIView *backView = [[UIView alloc] initWithFrame:self.icon.frame];
    UIImageView *iconView = (UIImageView *)[self.icon viewWithTag:1];
    iconView.image = [UIImage imageNamed:@"40@2x.png"];
    
    self.icon.selectedBackgroundView = backView;
    self.icon.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    
    backView.frame = self.software.frame;
    self.software.textLabel.textAlignment = NSTextAlignmentCenter;
    self.software.textLabel.text = @"iPREdtior";
    self.software.selectedBackgroundView = backView;
    self.software.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.version.textLabel.text = @"Version";
    self.version.detailTextLabel.text = version_String;
    self.version.selectedBackgroundView = backView;
    self.version.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.company.textLabel.adjustsFontSizeToFitWidth = true;
    self.company.textLabel.textAlignment = NSTextAlignmentLeft;
    self.company.textLabel.text = @"Copyright @ 2015-2016 FOXCONN-SW-COREOS.All Rights Reserved.";
    self.company.selectedBackgroundView = backView;
    self.company.backgroundView.backgroundColor = [UIColor clearColor];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backTo)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(void)backTo{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
