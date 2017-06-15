//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "PlistViewController.h"
#import "PlistTool.h"
#import "FXPlistTool.h"
#import "AppDelegate.h"
#import "PlistKeyTypeEditVC.h"
#import "PlistKeyEditViewController.h"
#import "PlistViewController.h"

@implementation PlistViewController{
    AppDelegate *delegate;
    BOOL isPlistFile;
}

//set cell identifier of storyboard
static NSString *NodeCellID = @"NodeCellID";
static NSString *TripleLabelCellID = @"TripleLableCellID";
static NSString *DoubleCellID = @"DoubleLableCellID";

//set root node show view controller identifier
static NSString *storyBoardOfPlistRootNodeShow = @"PlistRootNodeShowVC";

//set plist hander method
-(void)setPlist:(id)plistRoot{
    _plistRoot = plistRoot;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //judge  _plistRoot is plist format
    isPlistFile = [NSPropertyListSerialization propertyList:_plistRoot isValidForFormat:NSPropertyListXMLFormat_v1_0];
    
    //set table view property
    self.tableView.separatorEffect = SEPARATOR_EFFECT;
    self.tableView.separatorStyle = SEPARATOR_STYLE;
    [self.tableView reloadData];
    self.navigationController.delegate = self;
}



- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{

    
    BOOL isPlistKeyTypeEditVC = [fromVC isMemberOfClass:[PlistKeyTypeEditVC class]];
    BOOL isPlistKeyEditViewController = [toVC isMemberOfClass:[PlistKeyEditViewController class]];
    BOOL isPlistViewController = [toVC isMemberOfClass:[PlistViewController class]];
    
    if (isPlistKeyEditViewController&&isPlistKeyTypeEditVC) {
        [(PlistKeyEditViewController *)toVC setFlag:YES];
    }
    
    if (isPlistViewController) {
        
//        NSString *tmpFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%u",arc4random()]];
//        [[(id)toVC plistRoot] writeToFile:tmpFile atomically:YES];
//        
//        id tmpRoot = [NSMutableDictionary dictionaryWithContentsOfFile:tmpFile];
//        if (!tmpRoot) {
//            tmpRoot = [NSMutableArray arrayWithContentsOfFile:tmpFile];
//        }

        id handle = [NSMutableDictionary dictionaryWithContentsOfFile:delegate.temFilePath];
        if (!handle) {
            handle = [NSMutableArray arrayWithContentsOfFile:delegate.temFilePath];
        }
        
//        NSString *fileStr = [handle descriptionInStringsFileFormat];
//        NSString *changeStr = [[(id)toVC plistRoot] descriptionInStringsFileFormat];
//        BOOL noChanged = [fileStr isEqualToString:changeStr];
      
        BOOL noChanged = [handle isEqual:[(id)toVC plistRoot]];
       
        
        
        if (!noChanged) {
            delegate.isChanged = YES;
        }
    
    }
    
    return nil;
}




- (void)viewDidLoad {
    
    //share app delegate
    delegate = [UIApplication sharedApplication].delegate;
    
    //set navigation titile
    self.navigationItem.title = [self.fullPath lastPathComponent];
    self.navigationItem.hidesBackButton = NO;
    
    //set close file button in left item of navigation
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeFile:)];
    
    //remove remaining black line at tail of table
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    footerView.backgroundColor = [UIColor grayColor];
    [self.tableView setTableFooterView:footerView];
    
}

//close file event
- (void)closeFile:(id)sender {
    if (delegate.isChanged == YES) {
        
        //pop up a alert view to hint user
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"File Changed" message:@"What Do you wanna do?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        
        UIAlertAction *overwriteButton = [UIAlertAction actionWithTitle:@"OverWrite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            delegate.isChanged = NO;
            [_plistRoot writeToFile:_fullPath atomically:YES];
            [delegate.navi popViewControllerAnimated:YES];
        }];
        
        UIAlertAction *discardButton = [UIAlertAction actionWithTitle:@"Discard change" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            delegate.isChanged = NO;
            [delegate.navi popViewControllerAnimated:YES];
        }];
        
        [alertView addAction:overwriteButton];
        [alertView addAction:discardButton];
        [alertView addAction:cancelButton];
        
        [self presentViewController:alertView animated:YES completion:^(){}];
    }else{
        [delegate.navi popViewControllerAnimated:YES];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //set table rows
    return isPlistFile?2:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    //first row always show Nodes
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:NodeCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NodeCellID];
        }
        UILabel *NodeLable = (UILabel *)[cell viewWithTag:1];
        NodeLable.text = @"Nodes";
        
    }else if(indexPath.row == 1){   //show root node row
        cell = [tableView dequeueReusableCellWithIdentifier:DoubleCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DoubleCellID];
        }
        
        UILabel *keyLable = (UILabel *)[cell viewWithTag:1];
        UILabel *keyTypeLable = (UILabel *)[cell viewWithTag:2];
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        keyTypeLable.text = @"";
        if ([_plistRoot isKindOfClass:[NSArray class]]) {
            keyLable.text = @"Array";
        }else{
            keyLable.text = @"Dictionary";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //select root node row
    if (indexPath.row == 1) {
        
        PlistRootNodeVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PlistRootVC"];
        nextVC.keyTree = [NSMutableArray array];
        nextVC.plistRoot = _plistRoot;
        [self.navigationController pushViewController:nextVC animated:YES];
        
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //tap root node row accessory,switch to next vc
    if (indexPath.row == 1) {
        PlistRootNodeShowVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardOfPlistRootNodeShow];
        nextVC.plistRoot = _plistRoot;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

@end
