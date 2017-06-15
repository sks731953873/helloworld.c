//
//  PlistTool.m
//  FileToolTest
//
//  Created by Luke on 10/27/15.
//  Copyright (c) 2015 Luke. All rights reserved.
//

#import "PlistTool.h"
#import "FileTool.h"

@implementation PlistTool

static PlistTool* plistTool = nil;
static FileTool* fileTool = nil;

+ (PlistTool*)instance {
    
    if(!plistTool) {
        plistTool = [[PlistTool alloc] init];
        fileTool = [FileTool instance];
    }
    return plistTool;
}

/*
 *增加结点 key-value对
 *target为NULL，将会在当前dictionary下创建子结点
 *recursion 为YES:
 *           会找出所有的target新增结点
 *          为NO:
 *            只会在第一个找到的target新增结点
 */
- (BOOL)insertKey: (NSString*) key withValue: (id) value inDictionary: (id) dictionary atKey: (NSString*) target recursion: (BOOL) recursion {
    
    //dict
    if ([dictionary respondsToSelector:@selector(objectForKey:)]) {
        
        if (target ==  NULL) {
            [dictionary setObject:value forKey:key];
            return YES;
        }
        
        //要递归增加
        if (recursion == YES) {
            //当前层可以找到
            if ([dictionary objectForKey:target]) {
                [dictionary setObject:value forKey:key];
            } else {
                for (NSString* childKey in [dictionary allKeys]) {
                    [self insertKey:key withValue:value inDictionary:[dictionary objectForKey:childKey] atKey:target recursion:recursion];
                }
            }

            
        }
        //不递归的话就找到第一个taget后，增加
        else {
            
            //当前层可以找到
            if ([dictionary objectForKey:target]) {
                [dictionary setObject:value forKey:key];
                return YES;
            } else {
                for (NSString* childKey in [dictionary allKeys]) {
                    BOOL result = [self insertKey:key withValue:value inDictionary:[dictionary objectForKey:childKey] atKey:target recursion:recursion];
                    if (result == YES) {
                        return YES;
                    }
                }
            }
        }
    }
    //array
    else if ([dictionary respondsToSelector:@selector(objectAtIndex:)]) {
        
        for (int i = 0; i < [dictionary count]; i++) {
            BOOL result = [self insertKey:key withValue:value inDictionary:[dictionary objectAtIndex:i] atKey:target recursion:recursion];
            if (result == YES) {
                if (recursion == NO) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

 /*
  *删除key,连同key-value一起删除
  *返回删除的个数
  *删除一个不存在的key,不会报任何异常
  *
  */
- (NSInteger)removeKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion {
    
    NSInteger sum = 0;
    //dict
    if ([dictionary respondsToSelector:@selector(objectForKey:)]) {
        //1.删除本层先
        if([dictionary objectForKey:key]) {
            [dictionary removeObjectForKey:key];
            sum = sum + 1;
        }
        //2.递归删除
        if (recursion == YES) {
            for (NSString* childKey in [dictionary allKeys]) {
                sum = sum + [self removeKey:key inDictionary:[dictionary objectForKey:childKey] recursion:recursion];
            }
        }
    }
    //array
    else if ([dictionary respondsToSelector:@selector(objectAtIndex:)]) {
        
        for (int i = 0; i < [dictionary count]; i++) {
            
            sum = sum + [self removeKey:key inDictionary:[dictionary objectAtIndex:i] recursion:recursion];
        }
    }
    return sum;
}

/*
 *获取key的值
 *获取一个不存在的key,会返回NULL
 *在当前dictionary下获取key 若是递归获取，只会获取第一个遇到的值
 *   <key>Test</key>
 *   <string></string>
 *   if(dictionary objectForKey:Test)  条件为真
 */
- (id)valueForKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion {
    
    //是dict
    if ([dictionary respondsToSelector:@selector(objectForKey:)]) {
        
        //key存在
        if ([dictionary objectForKey:key]) {
            
            return [dictionary objectForKey:key];
        }
        //key不存在,需要递归查询
        if (recursion == YES) {
            
            for (NSString* childKey in [dictionary allKeys]) {
                id result = [self valueForKey:key inDictionary:[dictionary objectForKey:childKey] recursion:recursion];
                if (result) {
                    return result;
                }
            }
        }
    }
    //是一个array,array里面可能包含dict
    else if ([dictionary respondsToSelector:@selector(objectAtIndex:)]) {
        
        for (int i = 0; i < [dictionary count]; i++) {
            id result = [self valueForKey:key inDictionary:[dictionary objectAtIndex:i] recursion:recursion];
            if (result) {
                return result;
            }
        }
    }
    return NULL;
}

/*
 *改,修改key对应的值
 *recursion为YES:
 *          修改所有的key
 *recursion为false:
 *          修改当前dictionary的key
 */
- (NSInteger)setValue: (id)value forKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion {
    
    NSInteger sum = 0;
    
    //dict
    if ([dictionary respondsToSelector:@selector(objectForKey:)]) {
        
        if (recursion == YES) {
            
            if ([dictionary objectForKey:key]) {
                [dictionary setObject:value forKey:key];
                sum = sum + 1;
            }
            for (NSString* childKey in [dictionary allKeys]) {
                
                sum = sum + [self setValue:value forKey:key inDictionary:[dictionary objectForKey:childKey] recursion:recursion];
            }
            
        } else {
            //如果存在的话
            //if ([dictionary objectForKey:key]) {
                [dictionary setObject:value forKey:key];
                sum = sum + 1;
            //}
        }
    }
    //array
    else if ([dictionary respondsToSelector:@selector(objectAtIndex:)]) {
        
        for (int i = 0; i < [dictionary count]; i++) {
            sum = sum + [self setValue:value forKey:key inDictionary:[dictionary objectAtIndex:i] recursion:recursion];
        }
    }
    return sum;
}

/*
 *
 *写进文件，文件不存在会自动创建；文件存在，会覆盖内容
 *
 *
 */
- (BOOL)write: (id)dictionary toFile: (NSString*) filePath {
    
    if ([dictionary respondsToSelector:@selector(writeToFile:atomically:)]) {
        [fileTool createFile:filePath];
        [dictionary writeToFile:filePath atomically:YES];
        return YES;
    }
    return NO;
}

//查询key是否存在
- (BOOL)existsKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion {
    
    //如果是一个dict
    if ([dictionary respondsToSelector:@selector(objectForKey:)]) {
        
        //1.先判断首层是否存在
        if ([dictionary objectForKey:key]) {
            return YES;
        }
        //2.首层不存在，往下挖。
        if (recursion == YES) {
            
            for (NSString* childKey in [dictionary allKeys]) {
                if([self existsKey:key inDictionary:[dictionary objectForKey:childKey] recursion:recursion]) {
                    return YES;
                }
            }
        } else {
            return NO;
        }
    }
    //如果是一个array
    else if ([dictionary respondsToSelector:@selector(objectAtIndex:)]) {
        
        //NSLog(@"in array");
        for (int i = 0; i < [dictionary count]; i++) {
            
            if ([self existsKey:key inDictionary:[dictionary objectAtIndex:i] recursion:recursion]) {
                return YES;
            }
        }
    }
    //都不是的话，直接返回NO
    return NO;
}

@end
