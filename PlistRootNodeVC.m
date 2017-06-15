//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//
#import "PlistViewController.h"
#import "PlistRootNodeVC.h"
#import "FXPlistTool.h"
#import "PlistKeyEditViewController.h"

@implementation PlistRootNodeVC
{
    //handler
    FXPlistTool *plistHandler;
    
    //set button tag in table cell
    NSUInteger NodeLableTag;
    NSUInteger KeyLableTag;
    NSUInteger KeyTypeLableTag;
    NSUInteger KeyValueLableTag;
    
    NSUInteger KeyLableTag_NoValue;
    NSUInteger KeyTypeLableTag_NoValue;
    
    //container set
    NSSet *containerSet;
    NSSet *noncontainerSet;
    
    //navigation item
    UIBarButtonItem *backButton;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *editButton;
    
    //trace plist value property
    NSMutableString *plistValueType;
    NSMutableArray *plistNodesItems;
    id plistValue;
    
    //flag,had insert a new node?
    BOOL hadInsertNewNode;
    
    AppDelegate *delegate;
}

//ID for table cell
static NSString *NodeCellID = @"NodeCellID";
static NSString *TripleLabelCellID = @"KeyCellID";
static NSString *DoubleCellID = @"ArrayCellID";

//ID for VC
static NSString *storyBoardOfPlistRoot = @"PlistRootVC";
static NSString *storyboardOfPlistKeyTypeShowVC = @"PlistKeyTypeShowVCID";
static NSString *storyBoardOfPlistKeyEditVC = @"PlistKeyEditVCID";

-(void)setPlist:(id)plistRoot{
    _plistRoot = plistRoot;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //sort key-value pair by key name in ASCII way
    NSComparator cmptr = ^(id obj1, id obj2){
        if (!([obj1 length]<4)&&!([obj2 length]<4)) {
            
            NSString *prefix1 = [obj1 substringToIndex:4];
            NSString *prefix2 = [obj2 substringToIndex:4];
            
            if ([prefix1 isEqualToString:@"Item"]&&[prefix2 isEqualToString:@"Item"]) {
                NSInteger suffix_value1 = [[obj1 substringFromIndex:4] intValue];
                NSInteger suffix_value2 = [[obj2 substringFromIndex:4] intValue];
                return suffix_value1<suffix_value2?NSOrderedAscending:NSOrderedDescending;
            }
            
        }
        
        return [obj1 compare:obj2 options:NSNumericSearch];
        
    };
    
    //Defualt no node insert
    hadInsertNewNode = NO;
    
    //get plist value
    plistValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:_keyTree];
    
    if (plistValue == nil) {
        [self backTo];
    }else{
        
        //store key name
        if ([plistValue isKindOfClass:[NSDictionary class]]) {
            plistNodesItems = [NSMutableArray arrayWithArray:[[plistValue allKeys] sortedArrayUsingComparator:cmptr]];
        }else if ([plistValue isKindOfClass:[NSArray class]]){
            plistNodesItems = [NSMutableArray array];
            [plistValue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [plistNodesItems addObject:[NSString stringWithFormat:@"Item %lu", (unsigned long)idx]];
            }];
        }else{
            [self backTo];
            return;
        }
        
        //set plist value type
        plistValueType = [NSMutableString stringWithString:NSStringFromClass([plistValue class])];
        
        //set navigation title
        self.navigationItem.title = (_keyTree.count != 0) ? [NSString stringWithFormat:@"%@", [_keyTree lastObject]] : @"Root";
        
        //data type store in
        NSMutableArray *containerlArr = [NSMutableArray arrayWithArray:[DIC_SET allObjects]];
        [containerlArr addObjectsFromArray:[ARR_SET allObjects]];
        containerSet = [NSSet setWithArray:containerlArr];
        
        NSMutableArray *noncontainerArr = [NSMutableArray arrayWithArray:[STR_SET allObjects]];
        [noncontainerArr addObjectsFromArray:[BLN_SET allObjects]];
        [noncontainerArr addObjectsFromArray:[NUM_SET allObjects]];
        [noncontainerArr addObjectsFromArray:[DATA_SET allObjects]];
        [noncontainerArr addObjectsFromArray:[DATE_SET allObjects]];
        
        noncontainerSet = [NSSet setWithArray:noncontainerArr];
        
        self.tableView.separatorEffect = SEPARATOR_EFFECT;
        self.tableView.separatorStyle = SEPARATOR_STYLE;
        
        [self.tableView reloadData];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //button tag in table cell
    NodeLableTag = 1;
    KeyLableTag = 1;
    KeyTypeLableTag = 2;
    KeyValueLableTag = 3;
    KeyLableTag_NoValue = 1;
    KeyTypeLableTag_NoValue = 2;
    
    //init data
    plistHandler = [[FXPlistTool alloc] init];
    delegate = [UIApplication sharedApplication].delegate;
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backTo)];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEvent:)];
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleEvent:)];
    
    editButton.tag  = 1;
    doneButton.tag = 2;
    self.navigationItem.leftBarButtonItem  = backButton;
    self.navigationItem.rightBarButtonItem = editButton;
    
    
   // UIView *footerView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    UIView *footerView= [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = footerView;
   
}

- (void)backTo{
    
    //remove last key item route
    [_keyTree removeLastObject];
    
    //set current plist root for poped VC
    NSArray *vcs = [self.navigationController viewControllers];
    id prevc = nil;
    if (vcs.count >= 2) {
        prevc = vcs[vcs.count - 2];
        [prevc setPlist:self.plistRoot];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)handleEvent:(UIBarButtonItem *)sender{
    
    switch (sender.tag) {
            //edit mode
        case 1:{
            backButton.title = @"";
            [backButton setEnabled:NO];
            [self.tableView setEditing:YES];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:plistNodesItems.count+1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            self.navigationItem.rightBarButtonItem = doneButton;
            break;}
            
            //done
        case 2:{
            backButton.title = @"Back";
            [backButton setEnabled:YES];
            [self.tableView setEditing:NO];
            NSUInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
            NSIndexPath *index = [NSIndexPath indexPathForRow:lastRow inSection:0];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            hadInsertNewNode?[self viewWillAppear:YES]:nil;
            hadInsertNewNode = NO;
            self.navigationItem.rightBarButtonItem = editButton;
            break;}
        default:
            break;
    }
    
    
}

//data type change to String
-(NSString *)setType:(NSString *)type{
    if ([STR_SET containsObject:type]) {
        return @"String";
    }else if ([DATE_SET containsObject:type]){
        return @"Date";
    }else if ([DIC_SET containsObject:type]){
        return @"Dictionary";
    }else if([ARR_SET containsObject:type]){
        return @"Array";
    }else if([BLN_SET containsObject:type]){
        return @"Boolean";
    }else if([DATA_SET containsObject:type]){
        return @"Data";
    }else if ([NUM_SET containsObject:type]){
        return @"Integer";
    }
    return @"";
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //in edit mode,show delete or insert cell
    return indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1?UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    //cell can edit?
    return (indexPath.row != 0 && self.tableView.editing == YES)?YES:NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger lastRow = [tableView numberOfRowsInSection:indexPath.section] - 1;
    BOOL isArray =    [plistValue isKindOfClass:[NSArray class]];
    return indexPath != 0&&indexPath.row != lastRow &&tableView.editing&&isArray?YES:NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{

    NSInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
    NSInteger firstRow = 0;
    
    if (destinationIndexPath.row == firstRow || destinationIndexPath.row == lastRow || sourceIndexPath == destinationIndexPath) {
        return;
    }

       id tmpKey = [plistNodesItems objectAtIndex:sourceIndexPath.row - 1];
    [plistNodesItems removeObject:tmpKey];
    [plistNodesItems insertObject:tmpKey atIndex:destinationIndexPath.row -1];

    NSMutableArray *stmp = [_keyTree mutableCopy];
    NSMutableArray *dtmp = [_keyTree mutableCopy];
    
    [dtmp addObject:[NSNumber numberWithInteger:destinationIndexPath.row - 1]];
    [stmp addObject:[NSNumber numberWithInteger:sourceIndexPath.row - 1]];
    
    id sValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:stmp];
    id dValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:dtmp];
    
    [plistHandler setValue:sValue root:_plistRoot keyRoute:dtmp];
    [plistHandler setValue:dValue root:_plistRoot keyRoute:stmp];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableView.editing?plistNodesItems.count + 2:plistNodesItems.count + 1;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    
    NSInteger lastRow = [self.tableView numberOfRowsInSection:0] - 1;
    NSInteger firstRow = 0;
    
    if (proposedDestinationIndexPath.row == firstRow || proposedDestinationIndexPath.row == lastRow || sourceIndexPath == proposedDestinationIndexPath) {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert:{
            
            NSSet *keySet = [NSSet setWithArray:plistNodesItems];
            NSMutableString *key = [NSMutableString string];
            for (NSUInteger i = 0; ;i++) {
                if ([DIC_SET containsObject:plistValueType]) {
                    key = [NSMutableString stringWithFormat:@"New Item - %lu", (unsigned long)i];
                }else if([ARR_SET containsObject:plistValueType]){
                    key = [NSMutableString stringWithFormat:@"Item %lu", (unsigned long)i];
                }
                
                if ([keySet containsObject:key]) {
                    continue;
                }else{
                    [plistNodesItems addObject:key];
                    [plistHandler addValue:@"New Item" forKey:key root:_plistRoot keyRoute:_keyTree];
                    break;
                }
            }
            
            hadInsertNewNode = YES;
                    [self.tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
            break;}
        default:
            break;
    }
    
}

//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSString *clickKey = plistNodesItems[indexPath.row - 1];
        
        if ([DIC_SET containsObject:plistValueType]) {
            [_keyTree addObject:plistNodesItems[indexPath.row - 1]];
        }else if ([ARR_SET containsObject:plistValueType]){
            [_keyTree addObject:[NSNumber numberWithInteger:indexPath.row - 1]];
        }
        
        [plistNodesItems removeObject:clickKey];
        [plistHandler removeValueFromRoot:_plistRoot keyRoute:_keyTree];
        [_keyTree removeLastObject];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
    }];
    
    
    NSArray *arr = @[deleleAction];
    
    return arr;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    if ([DIC_SET containsObject:plistValueType]) {
        [_keyTree addObject:plistNodesItems[indexPath.row - 1]];
    }else if ([ARR_SET containsObject:plistValueType]){
        [_keyTree addObject:[NSNumber numberWithInteger:indexPath.row - 1]];
    }
    
    PlistKeyEditViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardOfPlistKeyEditVC];
    nextVC.plistRoot = _plistRoot;
    nextVC.keyTree = _keyTree;
    [self.navigationController pushViewController:nextVC animated:YES];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return;
    }
    
    NSString *clickKeyType = nil;
    if ([DIC_SET containsObject:plistValueType]) {
        [_keyTree addObject:plistNodesItems[indexPath.row - 1]];
        clickKeyType = NSStringFromClass([plistValue[_keyTree[_keyTree.count -1]] class]);
    }else if ([ARR_SET containsObject:plistValueType]){
        [_keyTree addObject:[NSNumber numberWithInteger:indexPath.row - 1]];
        clickKeyType = NSStringFromClass([plistValue[indexPath.row - 1] class]);
    }
    
    if ([containerSet containsObject:clickKeyType]) {
        PlistRootNodeVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardOfPlistRoot];
        nextVC.plistRoot = _plistRoot;
        nextVC.keyTree = _keyTree;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    else if([noncontainerSet containsObject:clickKeyType]){
        PlistKeyEditViewController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardOfPlistKeyEditVC];
        nextVC.plistRoot = _plistRoot;
        nextVC.keyTree = _keyTree;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    NSString *keyType = nil;
    NSUInteger rowNo = indexPath.row;
    NSUInteger rowCounts = [self.tableView numberOfRowsInSection:indexPath.section];
    
    if (rowNo != 0) {
        if (self.tableView.editing&&rowNo == rowCounts - 1) {
            
        }
        else if ([DIC_SET containsObject:plistValueType]) {
            keyType =  NSStringFromClass( [[plistValue objectForKey:plistNodesItems[rowNo - 1]] class] );
        }else if ([ARR_SET containsObject:plistValueType]){
            keyType = NSStringFromClass([[plistValue objectAtIndex:rowNo - 1] class]);
        }
    }
    
    if (rowNo == rowCounts -1&&self.tableView.editing) {
        cell = [tableView dequeueReusableCellWithIdentifier:NodeCellID ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NodeCellID];
        }
        
        UILabel *nodeLable = (UILabel *)[cell viewWithTag:NodeLableTag];
        nodeLable.text = @"Add New Node";
    } else if (rowNo == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:NodeCellID ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NodeCellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *nodeLable = (UILabel *)[cell viewWithTag:NodeLableTag];
        nodeLable.text = @"Nodes";
    } else if ([containerSet containsObject:keyType]){
        
        cell = [tableView dequeueReusableCellWithIdentifier:DoubleCellID ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DoubleCellID];
        }
        
        UILabel *keyLable = (UILabel *)[cell viewWithTag:KeyLableTag_NoValue];
        UILabel *keyTypeLable = (UILabel *)[cell viewWithTag:KeyTypeLableTag_NoValue];
        
        
        keyTypeLable.text = [self setType:keyType];
        keyLable.text = plistNodesItems[rowNo - 1];
        
    }else if([noncontainerSet containsObject:keyType]){
        cell = [tableView dequeueReusableCellWithIdentifier:TripleLabelCellID ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TripleLabelCellID];
        }
        
        UILabel *keyLable = (UILabel *)[cell viewWithTag:KeyLableTag];
        UILabel *keyTypeLable = (UILabel *)[cell viewWithTag:KeyTypeLableTag] ;
        UILabel *keyValueLable = (UILabel *)[cell viewWithTag:KeyValueLableTag];
        
        if ([DIC_SET containsObject:plistValueType]) {
            [_keyTree addObject:plistNodesItems[rowNo - 1]];
        }else if ([ARR_SET containsObject:plistValueType]){
            [_keyTree addObject:[NSNumber numberWithInteger:rowNo - 1]];
        }
        
        NSString *keyValue = [NSString stringWithFormat:@"%@",[plistHandler valueSearchFromRoot:_plistRoot keyRoute:_keyTree]];
        NSString *keyValueTrim = [keyValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        if ([keyValueTrim isEqualToString:@"1"]&&[BLN_SET containsObject:keyType]){
            keyValueLable.text = @"true";
        }else if ([keyValueTrim isEqualToString:@"0"]&&[BLN_SET containsObject:keyType]){
            keyValueLable.text = @"false";
        }else if ([keyValueTrim isEqualToString:@""]) {
            keyValueLable.text = @"null";
        }else{
            keyValueLable.text = keyValueTrim;
        }
        
        keyLable.text = plistNodesItems[rowNo - 1];
        keyTypeLable.text = [self setType:keyType];
        [_keyTree removeLastObject];
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
@end
