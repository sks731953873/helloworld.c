//
//  PlistTool.h
//  FileToolTest
//
//  Created by Luke on 10/27/15.
//  Copyright (c) 2015 Luke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlistTool : NSObject

+ (PlistTool*)instance;

//增，在与target同级下，新增结点
- (BOOL)insertKey: (NSString*) key withValue: (id) value inDictionary: (id) dictionary atKey: (NSString*) target recursion: (BOOL) recursion;

//删，删除某个key,recursion是否删除所有同名不同层的Key
- (NSInteger)removeKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion;

//查，获取key对应的值,recursion是否递归获取，但只会获取第一个值,因为key无序，所以如果有多个值，获取是无序的第一个值
- (id)valueForKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion;

//改,修改key对应的值
- (NSInteger)setValue: (id)value forKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion;

//写进文件
- (BOOL)write: (id)dictionary toFile: (NSString*) filePath;

//是否存在,recursion是否递归查询
- (BOOL)existsKey: (NSString*) key inDictionary: (id) dictionary recursion: (BOOL) recursion;


@end
