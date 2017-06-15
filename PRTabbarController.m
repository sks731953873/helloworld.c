//
//  PRTabbarController.m
//  iPREditor
//
//  Created by admin on 11/4/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import "PRTabbarController.h"
#import "PlistViewController.h"
#import "PlistRootNodeVC.h"
#import "PlistRootNodeShowVC.h"
#import "PlistRootNodeTypeEditVC.h"
#import "PlistKeyTypeEditVC.h"
#import "PlistKeyEditViewController.h"
#import "Appdelegate.h"
@interface PRTabbarController ()

@end

@implementation PRTabbarController{
    AppDelegate *delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = [UIApplication sharedApplication].delegate;
    [self.navigationController setNavigationBarHidden:YES];
    
    UITabBarItem *setting = self.tabBar.items[0];
    setting.image = [[UIImage imageNamed:@"setting_32px_gray.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    setting.selectedImage = [[UIImage imageNamed:@"setting_32px.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    setting.title = @"Setting";
    setting.badgeValue = nil;
    
    UITabBarItem *plistItem = self.tabBar.items[1];
    plistItem.image = [UIImage imageNamed:@"plist_32.png"];
    plistItem.selectedImage = [UIImage imageNamed:@"plist_32_selected.png"];
    plistItem.title = @"Plist";
    plistItem.badgeValue = nil;
    
    
    UITabBarItem *previewItem = self.tabBar.items[2];
    previewItem.image = [UIImage imageNamed:@"Search_gray.png"];
    previewItem.selectedImage = [UIImage imageNamed:@"Search_blue.png"];
    previewItem.title = @"Preview";
    previewItem.badgeValue = nil;

    self.delegate = self;
       // Do any additional setup after loading the view.
}

- (nullable id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
                     animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                       toViewController:(UIViewController *)toVC
{
    
    id handle = [NSMutableDictionary dictionaryWithContentsOfFile:delegate.temFilePath];
    if (!handle) {
        handle = [NSMutableArray arrayWithContentsOfFile:delegate.temFilePath];
    }
    
    id plistUI = [(UINavigationController*)toVC topViewController];
    
    
    BOOL isPlistViewController = [plistUI isMemberOfClass:[PlistViewController class]];
    BOOL isPlistRootNodeVC = [plistUI isMemberOfClass:[PlistRootNodeVC class]];
    BOOL isPlistRootNodeShowVC = [plistUI isMemberOfClass:[PlistRootNodeShowVC class]];
    BOOL isPlistRootNodeTypeEditVC = [plistUI isMemberOfClass:[PlistRootNodeTypeEditVC class]];
    BOOL isPlistKeyTypeEditVC = [plistUI isMemberOfClass:[PlistKeyTypeEditVC class]];
    BOOL isPlistKeyEditViewController = [plistUI isMemberOfClass:[PlistKeyEditViewController class]];
    
    if (isPlistViewController) {
        [(PlistViewController*)plistUI setPlist:handle];
    }else if(isPlistRootNodeVC ){
        [(PlistRootNodeVC*)plistUI setPlist:handle];
    }else if(isPlistRootNodeShowVC){
        [(PlistRootNodeShowVC*)plistUI setPlist:handle];
    }else if(isPlistRootNodeTypeEditVC){
        [(PlistRootNodeTypeEditVC*)plistUI setPlist:handle];
    }else if(isPlistKeyTypeEditVC){
        [(PlistKeyTypeEditVC*)plistUI setPlist:handle];
    }else if(isPlistKeyEditViewController){
        [(PlistKeyEditViewController*)plistUI setPlist:handle];
    }
    
    //---from PlistUI
    id fromPlistUI = [(UINavigationController*)fromVC topViewController];
    id fromPlistTab = [[(id)fromVC viewControllers] firstObject];
    BOOL isFromPlistTab = [fromPlistTab isMemberOfClass:[PlistViewController class]];
    if (isFromPlistTab) {
        BOOL noChanged = [handle isEqual:[(id)fromPlistUI plistRoot]];
        
        if (!noChanged) {
            delegate.isChanged = YES;
        }        
    }
    
    BOOL isFromPlistViewController = [fromPlistUI isMemberOfClass:[PlistViewController class]];
    BOOL isFromPlistRootNodeVC = [fromPlistUI isMemberOfClass:[PlistRootNodeVC class]];
    BOOL isFromPlistRootNodeShowVC = [fromPlistUI isMemberOfClass:[PlistRootNodeShowVC class]];
    BOOL isFromPlistRootNodeTypeEditVC = [fromPlistUI isMemberOfClass:[PlistRootNodeTypeEditVC class]];
    BOOL isFromPlistKeyTypeEditVC = [fromPlistUI isMemberOfClass:[PlistKeyTypeEditVC class]];
    BOOL isFromPlistKeyEditViewController = [fromPlistUI isMemberOfClass:[PlistKeyEditViewController class]];
    
    if (isFromPlistViewController) {
        [[(PlistViewController*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
    }else if(isFromPlistRootNodeVC ){
        [[(PlistRootNodeVC*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
    }else if(isFromPlistRootNodeShowVC){
        [[(PlistRootNodeShowVC*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
        
    }else if(isFromPlistRootNodeTypeEditVC){
        [[(PlistRootNodeTypeEditVC*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
        
    }else if(isFromPlistKeyTypeEditVC){
        [[(PlistKeyTypeEditVC*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
        
    }else if(isFromPlistKeyEditViewController){
        [[(PlistKeyEditViewController*)fromPlistUI plistRoot] writeToFile:delegate.temFilePath atomically:YES];
        
    }
    
    
      return nil;
}

@end
