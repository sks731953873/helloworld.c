//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "PlistRootNodeTypeEditVC.h"
#import "PlistRootNodeShowVC.h"
#import "AppDelegate.h"

@implementation PlistRootNodeTypeEditVC
{
    AppDelegate *delegate;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
    NSInteger selectRow;
    
    NSString *rootType;
}

-(void)setPlist:(id)plistRoot{
    NSArray *vcs = [self.navigationController viewControllers];
    id prevc = nil;
    if (vcs.count >= 2) {
        prevc = vcs[vcs.count - 2];
        [prevc setPlist:self.plistRoot];
    }
    _plistRoot = plistRoot;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    selectRow = -1;
    delegate.dictionary = _plistRoot;
    rootType = NSStringFromClass([_plistRoot class]);
    
    self.tableView.separatorEffect = SEPARATOR_EFFECT;
    self.tableView.separatorStyle = SEPARATOR_STYLE;
    
    NSArray *cells = self.tableView.visibleCells;
    if ([DIC_SET containsObject:rootType]) {
        [cells[1] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cells[0] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = [UIApplication sharedApplication].delegate;
    self.labelArray.text = @"Array";
    self.labelDic.text = @"Dictionary";
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEvent:)];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleEvent:)];
    
    [cancelButton setTag:1];
    [doneButton setTag:2];
    
    UIView *footerView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    footerView.backgroundColor = [UIColor lightGrayColor];
    [self.tableView setTableFooterView:footerView];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) handleEvent:(UIBarButtonItem *)sender{
    
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            break;}
        case 2:{
            if (selectRow < 0) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            if (selectRow == 0 && [ARR_SET containsObject:rootType]) {
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if (selectRow == 1 && [DIC_SET containsObject:rootType]){
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                
                if([_plistRoot respondsToSelector:@selector(objectAtIndex:)]){
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    for (NSUInteger i = 0; i < [_plistRoot count]; i++) {
                        [dic setObject:_plistRoot[i] forKey:[NSString stringWithFormat:@"Item %ld", (unsigned long)i]];
                    }
                    _plistRoot = dic;
                }else if([_plistRoot respondsToSelector:@selector(allValues)]){
                    _plistRoot = [NSMutableArray arrayWithArray: [_plistRoot allValues]];
                }
                
                NSArray *vcs = self.navigationController.viewControllers;
                PlistRootNodeShowVC *prevc = vcs[vcs.count - 2];
                prevc.plistRoot = _plistRoot;
         
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;}
        default:
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectRow = indexPath.row;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL firstLoad = YES;
    if (firstLoad) {
        
        NSArray *indexArr = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *index in indexArr) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        firstLoad = NO;
    }
    return indexPath;
}

@end
