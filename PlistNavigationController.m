//
//  PlistNavigationController.m
//  iPREditor
//
//  Created by jett on 15/11/5.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "PlistNavigationController.h"
#import "PlistViewController.h"

@interface PlistNavigationController ()

@end

@implementation PlistNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  //  PlistViewController *destVC = (PlistViewController *)segue.destinationViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
