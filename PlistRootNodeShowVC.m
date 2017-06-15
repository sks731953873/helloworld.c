//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "PlistRootNodeShowVC.h"
#import "PlistRootNodeTypeEditVC.h"
#import "PlistViewController.h"

@implementation PlistRootNodeShowVC
{
    AppDelegate *delegate;
    UIBarButtonItem *backButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
}

static NSString *storyboardOfPlistRootNodeTypeEdit = @"storyboardOfPlistRootNodeTypeEditID";
static NSString *cellOfKEY_VALUE = @"KEYVALUE";

-(void)setPlist:(id)plistRoot{
    _plistRoot = plistRoot;
}

- (void)viewWillAppear:(BOOL)animated{
    
    delegate.dictionary = _plistRoot;
    [self.tableView setSeparatorColor:[UIColor blackColor]];
    [self.tableView setSeparatorEffect:SEPARATOR_EFFECT];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.tableView setSeparatorStyle:SEPARATOR_STYLE];
    [self handleEvent:doneButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = [UIApplication sharedApplication].delegate;
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backTo)];
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleEvent:)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEvent:)];
    
    [editButton setTag:1];
    [doneButton setTag:2];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void) backTo{
    NSArray *vcs = self.navigationController.viewControllers;
    PlistViewController *prevc = vcs[vcs.count - 2];
    prevc.plistRoot = _plistRoot;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleEvent:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 1:{
            [backButton setTitle:@""];
            [backButton setEnabled:NO];
            self.navigationItem.rightBarButtonItem = doneButton;
            break;}
        case 2:{
            [backButton setTitle:@"Back"];
            [backButton setEnabled:YES];
            self.navigationItem.rightBarButtonItem = editButton;
            break;}
        default:
            break;
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 1 && backButton.isEnabled == NO) {
        PlistRootNodeTypeEditVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyboardOfPlistRootNodeTypeEdit];
        nextVC.plistRoot = _plistRoot;
        nextVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"KEY";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger cellRow = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOfKEY_VALUE forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOfKEY_VALUE];
    }
    
    if (cellRow == 0) {
        cell.textLabel.text = @"Key";
        cell.detailTextLabel.text = @"Root";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if(cellRow == 1){
        cell.textLabel.text = @"Type";
        if ([DIC_SET containsObject:NSStringFromClass([_plistRoot class] )]) {
            cell.detailTextLabel.text = @"Dictionary";
        }else{
            cell.detailTextLabel.text  = @"Array";
        }
        
        if (backButton.isEnabled == NO) {
            cell.backgroundColor = ACT_CELL_BGCOLOR;
            cell.textLabel.textColor = ACT_CELL_TEXTCOLOR;
            cell.detailTextLabel.textColor = ACT_CELL_TEXTCOLOR;
        }else{
            cell.backgroundColor = CELL_BGCOLOR;
            cell.textLabel.textColor = CELL_TEXTCOLOR;
            cell.detailTextLabel.textColor = CELL_TEXTCOLOR;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

@end
