//
//  Modify.m
//  test
//
//  Created by jett on 15/12/4.
//  Copyright (c) 2015年 jett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FXPlistTool : NSObject
-(void)modifyKey:(NSMutableString *)key root:(id)root keyRoute:(NSMutableArray *)keyRoute;
-(void)addValue:(id)value forKey:(NSMutableString *)key root:(id)root keyRoute:(NSMutableArray *)keyRoute;
-(void)removeValueFromRoot:(id)root keyRoute:(NSMutableArray *)keyRoute;
-(void)setValue:(id)value root:(id)root keyRoute:(NSMutableArray *)keyRoute;
-(id) valueSearchFromRoot:(id)root keyRoute:(NSMutableArray *)keyRoute;
@end


