//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "Appdelegate.h"
#import "PlistKeyTypeEditVC.h"
#import "PlistKeyEditViewController.h"
#import "FXPlistTool.h"

@implementation PlistKeyTypeEditVC
{
    FXPlistTool *plistHandler;
    
    NSUInteger rowAt;
    NSInteger clickRow;
    
    UIBarButtonItem *doneButton;
    UIBarButtonItem *cancelButton;
    NSArray *keyTypeArrs;
    
    NSMutableString *plistKeyType;
    id plistValue;
    
    AppDelegate *delegate;
}

typedef NS_ENUM(NSUInteger, KEYTYPE){
    ARR_LINE = 0,
    DIC_LINE,
    STR_LINE,
    NUM_LINE,
    BLN_LINE,
    DATE_LINE,
    DATA_LINE,
};


static NSString *plistKeyTypeCellEdit = @"plistKeyTypeCellEdit";

-(void)setPlist:(id)plistRoot{
    _plistRoot = plistRoot;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.tableView.separatorEffect = SEPARATOR_EFFECT;
    self.tableView.separatorStyle = SEPARATOR_STYLE;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = [UIApplication sharedApplication].delegate;
    plistHandler = [[FXPlistTool alloc]init];
    
    keyTypeArrs = @[@"Array", @"Dictionary", @"String", @"Integer", @"Boolean", @"Date", @"Data"];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEvent:)];
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backTo)];
    
    [cancelButton setTag:1];
    [doneButton setTag:2];
    
    UIView *footerView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    footerView.backgroundColor = [UIColor lightGrayColor];
    [self.tableView setTableFooterView:footerView];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    plistValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:_keyTree];
    plistKeyType = [NSMutableString stringWithString:NSStringFromClass([plistValue class])];
    rowAt = [self typeNo:plistKeyType];
    clickRow = -1;
    
    
}

- (void) backTo{
    NSArray *vcs = [self.navigationController viewControllers];
    id prevc = nil;
    if (vcs.count >= 2) {
        prevc = vcs[vcs.count - 2];
        [prevc setPlist:self.plistRoot];
    }

    [self.navigationController popViewControllerAnimated:YES];
}


-(NSUInteger)typeNo:(NSString *)keyType{
    NSUInteger ret = -1;
    if ([ARR_SET containsObject:keyType]) {
        ret = 0;
    }else if([DIC_SET containsObject:keyType]){
        ret = 1;
    }else if([STR_SET containsObject:keyType]){
        ret = 2;
    }else if([NUM_SET containsObject:keyType]){
        ret = 3;
    }else if([BLN_SET containsObject:keyType]){
        ret = 4;
    }else if([DATE_SET containsObject:keyType]){
        ret = 5;
    }else if([DATA_SET containsObject:keyType]){
        ret = 6;
    }
    
    return ret;
}

- (void) handleEvent:(UIBarButtonItem *)sender{
    
    if (clickRow == rowAt||clickRow < 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    switch (clickRow) {
            //Array
        case ARR_LINE:{
            if([plistValue respondsToSelector:@selector(allValues)]){
                plistValue = [NSMutableArray arrayWithArray:[plistValue allValues]];
            }else{
                plistValue = [NSMutableArray array];
            }
            break;}
            //Dictionary
        case DIC_LINE:{
            if ([plistValue respondsToSelector:@selector(objectAtIndex:)]) {
                NSMutableDictionary *dicTemp = [NSMutableDictionary dictionary];
                for (NSUInteger i = 0; i < [plistValue count]; i++) {
                    [dicTemp setObject:plistValue[i] forKey:[NSString stringWithFormat:@"Item %ld", (unsigned long)i]];
                }
                plistValue = dicTemp;
            }else{
                plistValue = [NSMutableDictionary dictionary];
            }
            break;}
            //String
        case STR_LINE:{
            if (rowAt == ARR_LINE || rowAt == DIC_LINE) {
                plistValue = @"";
            }else if(rowAt == BLN_LINE){
                NSUInteger isTrue = [plistValue integerValue];
                if (isTrue == 1) {
                    plistValue = @"true";
                }else{
                    plistValue = @"false";
                }
            }else{
                plistValue = [NSString stringWithFormat:@"%@", plistValue];
            }
            
            break;}
            
        case NUM_LINE:{
            plistValue = [NSNumber numberWithInteger:0];
            break;}
            //Boolean
        case BLN_LINE:{
            plistValue = [NSNumber numberWithBool:NO];
            break;}
            //Date/time
        case DATE_LINE:{
            plistValue = [NSDate date];
            break;}
            //Data
        case DATA_LINE:{
            if (rowAt == ARR_LINE || rowAt == DIC_LINE) {
                plistValue = [NSData data];
            }else{
                NSString *tmpStr = [NSString stringWithFormat:@"%@", plistValue];
                plistValue = [NSData dataWithBytes:tmpStr.UTF8String length:tmpStr.length];
            }
            break;}
        default:
            break;
    }
    
  
    [plistHandler setValue:plistValue root:_plistRoot keyRoute:_keyTree];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return keyTypeArrs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:plistKeyTypeCellEdit];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:plistKeyTypeCellEdit];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", keyTypeArrs[indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    clickRow = [[self.tableView indexPathForSelectedRow] row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    if ([self.keyType isEqualToString:@"Array"]&&indexPath.row == 0) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }else if([self.keyType isEqualToString:@"Dictionary"]&&indexPath.row == 1){
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//}

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



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    rowAt = [self typeNo:plistKeyType];
    if (rowAt == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
}



@end
