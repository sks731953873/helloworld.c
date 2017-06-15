//
//  PlistViewController.m
//  iPREditor
//
//  Created by jett on 11/4/15.
//  Copyright (c) 2015 jett. All rights reserved.
//

#import "AppDelegate.h"
#import "PlistKeyEditViewController.h"
#import "FXPlistTool.h"
#import "PlistKeyTypeEditVC.h"
#import "PlistRootNodeVC.h"

@implementation PlistKeyEditViewController
{
    
    FXPlistTool *plistHandler;
    
    UIBarButtonItem *backButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    
    NSInteger valueTextTag;
    NSUInteger ITEM_KEY_TAG;
    NSUInteger ITEM_VALUE_TAG;
    NSUInteger bln_key_tag;
    NSUInteger bln_img_tag;
    
    NSSet *normalSet;
    NSSet *specialSet;
    
    NSMutableString *plistParentType;
    NSMutableString *plistValueType;
    NSMutableString *plistKey;
    NSMutableString *replacePlistKey;
    id plistValue;
    
    BOOL isHadeBackBn;
    AppDelegate *delegate;
}

static NSString *DoubleCell = @"DoubleCellID";
static NSString *SingleCell = @"SingleCellID";
static NSString *cellIDOfDIC_ARR = @"DIC_ARR";
static NSString *storyboardOfPlistKeyTypeEditVC = @"PlistKeyTypeEditVCID";
static NSString *cellOfBLNCELL = @"BLNCELL";
static NSString *cellOfDateCell = @"DATECELL";
static NSString *cellOfTIMECELL = @"TIMECELL";
static NSString *cellOfTYPECELL = @"TYPECELL";

-(void)setPlist:(id)plistRoot{
    _plistRoot = plistRoot;
}

-(void)setFlag:(BOOL)flag{
    _flag = flag;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    plistHandler = [[FXPlistTool alloc]init];
    
    isHadeBackBn = NO;
    ITEM_KEY_TAG = 1;
    ITEM_VALUE_TAG = 2;
    valueTextTag = 1;
    bln_key_tag = 1;
    bln_img_tag = 2;
    
    backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backTo)];
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(handleEvent:)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEvent:)];
    
    [editButton setTag:1];
    [doneButton setTag:2];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.rightBarButtonItem = editButton;
    
    NSMutableArray *sepcialArr = [NSMutableArray arrayWithArray:[DIC_SET allObjects]];
    [sepcialArr addObjectsFromArray:[ARR_SET allObjects]];
    specialSet = [NSSet setWithArray:sepcialArr];
    
    NSMutableArray *normalArr = [NSMutableArray arrayWithArray:[STR_SET allObjects]];
    [normalArr addObjectsFromArray:[NUM_SET allObjects]];
    [normalArr addObjectsFromArray:[DATA_SET allObjects]];
    normalSet = [NSSet setWithArray:normalArr];
    delegate = [UIApplication sharedApplication].delegate;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    _flag = NO;
    plistValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:_keyTree];
    if (plistValue == nil) {
        [self backTo];
    }else{
        
        plistValueType = [NSMutableString stringWithString:NSStringFromClass([plistValue class])];
        
        id parentValue = nil;
        NSMutableArray *keyTree = [_keyTree mutableCopy];
        [keyTree removeLastObject];
        parentValue = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:keyTree];
        plistParentType = [NSMutableString stringWithString:NSStringFromClass([parentValue class])];
        
        if ([DIC_SET containsObject:plistParentType]) {
            plistKey = [NSMutableString stringWithString:_keyTree[_keyTree.count - 1]];
        }else{
            plistKey = [NSMutableString stringWithString:@"Item"];
        }
        
        
        if (_flag) {
            self.tableView.separatorStyle = SEPARATOR_STYLE;
            self.tableView.separatorEffect = SEPARATOR_EFFECT;
        }
    
        [self.tableView reloadData];
    }
    
}



- (void) backTo{
    
    [_keyTree removeLastObject];
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
        case 1:{
            isHadeBackBn = YES;
            [backButton setTitle:@""];
            [backButton setEnabled:NO];
            self.navigationItem.rightBarButtonItem = doneButton;
            [self.tableView reloadData];
            break;}
        case 2:{
            isHadeBackBn = NO;
            [backButton setTitle:@"Back"];
            [backButton setEnabled:YES];
            self.navigationItem.rightBarButtonItem = editButton;
            
            NSIndexPath *clickIndex = [self.tableView indexPathForSelectedRow];
            if ([BLN_SET containsObject:plistValueType]&&clickIndex.section == 1) {
                
                if (clickIndex.row == 0) {
                    plistValue = [NSNumber numberWithBool:NO];
                }else {
                    plistValue = [NSNumber numberWithBool:YES];
                }
               
                [plistHandler setValue:plistValue root:_plistRoot keyRoute:_keyTree];
            }
            
            [self.tableView reloadData];
            break;}
        default:
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([BLN_SET containsObject:plistValueType]&&isHadeBackBn == YES&&indexPath.section == 1) {
        if ([plistValue integerValue] == 0&&indexPath.row==0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else if([plistValue integerValue] == 1&&indexPath.row==1){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1&& isHadeBackBn &&indexPath.section==0) {
        PlistKeyTypeEditVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:storyboardOfPlistKeyTypeEditVC];
        
        nextVC.plistRoot = _plistRoot;
        nextVC.keyTree = _keyTree;
        nextVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nextVC animated:YES];

        return;
    }
    

    if ([BLN_SET containsObject:plistValueType]&&isHadeBackBn == YES&&indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        return;
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([BLN_SET containsObject:plistValueType]&&isHadeBackBn == YES&&indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return [specialSet containsObject:plistValueType]?1:2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BOOL isNeed = ([BLN_SET containsObject:plistValueType]&&isHadeBackBn)||([DATE_SET containsObject:plistValueType]&&isHadeBackBn);
    return section == 0? 2:(isNeed?2:1);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:{
            
            UILabel *keyLabel = nil;
            UITextField *keyNameField = nil;
            
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"KEYCELL" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KEYCELL"];
                }
                
                keyLabel = (UILabel *)[cell viewWithTag:1];
                keyLabel.text = @"Key";
                
                keyNameField = (UITextField *)[cell viewWithTag:100];
                keyNameField.text = plistKey;
                keyNameField.delegate = self;
                keyNameField.clearButtonMode = UITextFieldViewModeNever;
                keyNameField.keyboardType = UIKeyboardTypeAlphabet;
            
                
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle =  UITableViewCellSelectionStyleNone;
                if ([ARR_SET containsObject:plistParentType]) {
                    cell.userInteractionEnabled = NO;
                }
                
                
            }else{
                
                cell = [tableView dequeueReusableCellWithIdentifier:DoubleCell forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DoubleCell];
                }
                
                cell.textLabel.text = @"Type";
                cell.detailTextLabel.text = [self setType:plistValueType];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if (isHadeBackBn) {
                if (indexPath.row == 0&&[DIC_SET containsObject:plistParentType]) {
                    if (keyNameField != nil&& keyLabel != nil) {
                        keyLabel.textColor = ACT_CELL_TEXTCOLOR;
                        keyNameField.textColor = ACT_CELL_TEXTCOLOR;
                        [keyNameField becomeFirstResponder];
                    }
                }
                
                if (indexPath.row == 1) {
                    cell.textLabel.textColor = ACT_CELL_TEXTCOLOR;
                    cell.detailTextLabel.textColor = ACT_CELL_TEXTCOLOR;
                }
            }else{
                
                if (indexPath.row == 0) {
                    if (keyNameField != nil&& keyLabel != nil) {
                        keyLabel.textColor = CELL_TEXTCOLOR;
                        keyNameField.textColor = CELL_TEXTCOLOR;
                    }
                }
                
                if (indexPath.row == 1) {
                    cell.textLabel.textColor = CELL_TEXTCOLOR;
                    cell.detailTextLabel.textColor = CELL_TEXTCOLOR;
                }
            }
            
            
            break;}
        case 1:{
            
            if ([normalSet containsObject:plistValueType]) {
                cell = [tableView dequeueReusableCellWithIdentifier:SingleCell forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SingleCell];
                }
                
                UITextField *valueText = (UITextField *)[cell viewWithTag:valueTextTag];
                valueText.text = [NSString stringWithFormat:@"%@", plistValue];
                valueText.delegate = self;
                valueText.keyboardAppearance = UIKeyboardAppearanceLight;
                valueText.clearButtonMode = UITextFieldViewModeWhileEditing;
                valueText.keyboardType = [plistValue isKindOfClass:[NSNumber class]]?UIKeyboardTypeNumberPad:UIKeyboardTypeAlphabet;
                
                if (isHadeBackBn ) {
                    valueText.textColor = TEXT_ACT_COLOR;
                }else{
                    valueText.textColor = TEXT_COLOR;
                }
                
            }else if ([BLN_SET containsObject:plistValueType]){
                cell = [tableView dequeueReusableCellWithIdentifier:cellOfBLNCELL forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [tableView dequeueReusableCellWithIdentifier:cellOfBLNCELL forIndexPath:indexPath];
                }
                NSInteger keyValue = [plistValue integerValue];
                
                if (isHadeBackBn == NO&&indexPath.row == 0){
                    if (keyValue == 0) {
                        cell.textLabel.text = @"false";
                    }else {
                        cell.textLabel.text = @"true";
                    }
                }else if (isHadeBackBn == YES&&indexPath.row == 0){
                    cell.textLabel.text = @"false";
                }else if (indexPath.row == 1){
                    cell.textLabel.text = @"true";
                }
            }else if([DATE_SET containsObject:plistValueType]){
                
                if (indexPath.row == 1) {
                    cell = [tableView dequeueReusableCellWithIdentifier:cellOfDateCell forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellOfDateCell];
                    }
                    
                    UUDatePicker *datePicker = [[UUDatePicker alloc] initWithframe:CGRectMake(0, 0, cell.frame.size.width, 217) Delegate:self PickerStyle:0];
                    
                    datePicker.valueDate = plistValue;
                    [cell.contentView  addSubview:datePicker];
                   // cell.layer.borderWidth = 1;
                }
                
                if (indexPath.row == 0) {
                    cell = [tableView dequeueReusableCellWithIdentifier:cellOfTIMECELL forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [tableView dequeueReusableCellWithIdentifier:cellOfTIMECELL forIndexPath:indexPath];
                    }
                    
                    //        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601];
                    //        NSInteger weekday =  [calendar component:NSCalendarUnitWeekday fromDate:_keyValue] - 1;
                    //      NSString *weekDayStr = [self weekDay:weekday];
                    cell.textLabel.text = [NSString stringWithFormat:@"%@", plistValue];
                }
                cell.userInteractionEnabled = isHadeBackBn;
                break;}
        default:
            break;}
    }
    
    return cell;
}

-(void)uuDatePicker:(UUDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute second:(NSString *)second weekDay:(NSString *)weekDay{
    
    NSTimeZone *GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateFormatter *dtf = [[NSDateFormatter alloc]init];
    [dtf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dtf setTimeZone:GTMzone];
    NSString *timeStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year,month,day,hour,minute,second];
    
    plistValue = [dtf dateFromString:timeStr] ;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
    
   
    [plistHandler setValue:plistValue root:_plistRoot keyRoute:_keyTree];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([DATE_SET containsObject:plistValueType]&&indexPath.section == 1&&indexPath.row == 1) {
        return 217;
    }else{
        
        return 44;
    }
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0 ? @"KEY":@"VALUE";
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (!isHadeBackBn) {
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self handleEvent:doneButton];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.returnKeyType = UIReturnKeyDone;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField.tag == 100) {
        NSString *tmpKey = [plistKey copy];
        
        NSMutableArray *upperRoute = [_keyTree mutableCopy];
        [upperRoute removeLastObject];
        
        NSDictionary *upperDict = [plistHandler valueSearchFromRoot:_plistRoot keyRoute:upperRoute];
        NSMutableSet *siblingSet = [NSMutableSet setWithArray:[upperDict allKeys]];
        [siblingSet removeObject:tmpKey];
       
        if ([siblingSet containsObject:textField.text]) {
            replacePlistKey = [NSMutableString stringWithString:textField.text];
            NSString *title = [NSString stringWithFormat:@"The key you entered(\"%@\")is already present in the dictionary.Do you want to replace the existing key/value pair?", replacePlistKey];
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Warning" message:title preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
            
            UIAlertAction *replaceButton = [UIAlertAction actionWithTitle:@"Replace Existing Pair" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                plistKey = [NSMutableString stringWithString:replacePlistKey];
                [plistHandler modifyKey:plistKey root:_plistRoot keyRoute:_keyTree];
                [_keyTree removeLastObject];
                [_keyTree addObject:plistKey];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            
            [alertView addAction:cancelButton];
            [alertView addAction:replaceButton];
            [self presentViewController:alertView animated:YES completion:^{
            
                
            }];
        }else{
        
            plistKey = [NSMutableString stringWithString:textField.text];
            [plistHandler modifyKey:plistKey root:_plistRoot keyRoute:_keyTree];
            [_keyTree removeLastObject];
            [_keyTree addObject:plistKey];
        }
        
    }else{
        
        if ([STR_SET containsObject:plistValueType]) {
            plistValue= [textField.text mutableCopy];
        }else if([NUM_SET containsObject:plistValueType]){
            plistValue = [NSNumber numberWithInteger:[textField.text integerValue]];
        }else if ([DATA_SET containsObject:plistValueType]){
            plistValue = [NSData dataWithData:[textField.text dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [plistHandler setValue:plistValue root:_plistRoot keyRoute:_keyTree];
        
    }
   
}


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



-(NSString *)weekDay:(NSInteger)weekDay{
    
    switch (weekDay) {
        case 0:
            return @"Sun";
        case 1:
            return @"Mon";
        case 2:
            return @"Tue";
        case 3:
            return @"Wed";
        case 4:
            return @"Thu";
        case 5:
            return @"Fri";
        case 6:
            return @"Sat";
            
        default:
            break;
    }
   
    return @"";
}


@end
