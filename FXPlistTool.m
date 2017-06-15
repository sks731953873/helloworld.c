//
//  FXPlistTool.m
//  iPREditor
//
//  Created by jett on 15/12/4.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FXPlistTool.h"

@implementation FXPlistTool : NSObject

static FXPlistTool *plistHandler = nil;

+ (instancetype)alloc{
    plistHandler = [super alloc];
    if (!plistHandler) {
        plistHandler = [[FXPlistTool alloc]init];
    }
    
    return plistHandler;
}

-(void)modifyKey:(NSMutableString *)key root:(id)root keyRoute:(NSMutableArray *)keyRoute{
    
    NSEnumerator *e = [keyRoute objectEnumerator];
    NSMutableArray *nextRoute = [keyRoute mutableCopy];
    
    if (nextRoute.count != 0) {
        [nextRoute removeObjectAtIndex:0];
    }else{
        return;
    }

    
    if ([root respondsToSelector:@selector(allKeys)]) {
        id nextValue = [root objectForKey:[e nextObject]] ;
        if (keyRoute.count == 1) {
            [root removeObjectForKey:keyRoute[0]];
            [root setValue:nextValue forKey:key];
        }else if (keyRoute.count != 0 ){
            [self modifyKey:key root:nextValue keyRoute:nextRoute];
        }
    }else if ([root respondsToSelector:@selector(objectAtIndex:)]){
        
        id nextValue = nil;
        if ([root count] == 0) {
            return;
        }else{
            nextValue = [root objectAtIndex:[[e nextObject] integerValue]];
        }
        
       
        if (keyRoute.count == 0) {
            NSLog(@"modifykey err");
        }else if (keyRoute.count != 0 ){
            [self modifyKey:key root:nextValue keyRoute:nextRoute];;
        }
    }
    
}


-(id) valueSearchFromRoot:(id)root keyRoute:(NSMutableArray *)keyRoute{
    
    id ret = nil;
    NSEnumerator *e = [keyRoute objectEnumerator];
    NSMutableArray *nextRoute = [keyRoute mutableCopy];
    if (keyRoute.count != 0) {
        [nextRoute removeObjectAtIndex:0];
    }else {
        return root;
    }
    
    if ([root respondsToSelector:@selector(allKeys)]) {
        id nextValue = [root objectForKey:[e nextObject]];
        if (keyRoute.count == 1) {
            ret =  nextValue;
        }else if (keyRoute.count != 0 ){
            ret = [self valueSearchFromRoot:nextValue keyRoute:nextRoute];
        }else {
            return ret;
        }
        
    }else if ([root respondsToSelector:@selector(objectAtIndex:)]){
        id nextValue = nil;
        if ([root count] == 0) {
            return nil;
        }else{
            nextValue = [root objectAtIndex:[[e nextObject] integerValue]];
        }
        
        if (keyRoute.count == 1) {
            ret =  nextValue;
        }else if (keyRoute.count != 0 ){
            ret = [self valueSearchFromRoot:nextValue keyRoute:nextRoute];
        }else {
            return ret;
        }
    }
    
    return ret;
}





-(void)addValue:(id)value forKey:(NSMutableString *)key root:(id)root keyRoute:(NSMutableArray *)keyRoute{
    
    NSEnumerator *e = [keyRoute objectEnumerator];
    NSMutableArray *nextRoute = [keyRoute mutableCopy];
    id nextValue = nil;
    if (nextRoute.count != 0) {
        [nextRoute removeObjectAtIndex:0];
    }
    
    if ([root respondsToSelector:@selector(allKeys)]) {
        nextValue = [root objectForKey:[e nextObject]];
        if (keyRoute.count == 0) {
            [root setValue:value forKey:key];
        }else if (keyRoute.count != 0 ){
            [self addValue:value forKey:key root:nextValue keyRoute:nextRoute];
        }
    }else if ([root respondsToSelector:@selector(objectAtIndex:)]){
        [e nextObject]?nextValue = [root objectAtIndex:[[e nextObject] integerValue]]:nil;
        if (keyRoute.count == 0) {
            [root addObject:value];
        }else if (keyRoute.count != 0 ){
            [self addValue:value forKey:key root:nextValue keyRoute:nextRoute];
        }
    }
    
}


-(void)removeValueFromRoot:(id)root keyRoute:(NSMutableArray *)keyRoute{
    
    NSEnumerator *e = [keyRoute objectEnumerator];
    NSMutableArray *nextRoute = [keyRoute mutableCopy];
    if (keyRoute.count != 0) {
        [nextRoute removeObjectAtIndex:0];
    }else{
        return;
    }
   
    if ([root respondsToSelector:@selector(allKeys)]) {
        id nextValue = [root objectForKey:[e nextObject]];
        if (keyRoute.count == 1) {
            [root removeObjectForKey:keyRoute[0]];
        }else if (keyRoute.count != 0 ){
            [self removeValueFromRoot:nextValue keyRoute:nextRoute];
        }
    }else if ([root respondsToSelector:@selector(objectAtIndex:)]){
        id nextValue = nil;
        if ([root count] == 0) {
            return;
        }else{
            nextValue = [root objectAtIndex:[[e nextObject] integerValue]];
        }
        
       
        if (keyRoute.count == 1) {
            [root removeObjectAtIndex:[keyRoute[0] integerValue]];
        }else if (keyRoute.count != 0 ){
            [self removeValueFromRoot:nextValue keyRoute:nextRoute];;
        }
    }
    
}



-(void)setValue:(id)value root:(id)root keyRoute:(NSMutableArray *)keyRoute{
    
    NSEnumerator *e = [keyRoute objectEnumerator];
    NSMutableArray *nextRoute = [keyRoute mutableCopy];
    
    if (keyRoute.count != 0) {
        [nextRoute removeObjectAtIndex:0];
    }else{
        return;
    }

    if ([root respondsToSelector:@selector(allKeys)]) {
        id nextValue = [root objectForKey:[e nextObject]];
        if (keyRoute.count == 1) {
            [root setValue:value forKey:keyRoute[0]];
        }else if (keyRoute.count != 0 ){
            [self setValue:value root:nextValue keyRoute:nextRoute];
        }
    }else if ([root respondsToSelector:@selector(objectAtIndex:)]){
        id nextValue = nil;
        if ([root count] == 0) {
            return ;
        }else{
            nextValue = [root objectAtIndex:[[e nextObject] integerValue]];
        }
        
        if (keyRoute.count == 1) {
            [root replaceObjectAtIndex:[keyRoute[0] integerValue] withObject:value];
        }else if (keyRoute.count != 0 ){
            [self setValue:value root:nextValue keyRoute:nextRoute];;
        }
    }
}



@end