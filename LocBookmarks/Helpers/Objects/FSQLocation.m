//
//  FSQLocation.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "FSQLocation.h"

@implementation FSQLocation

+ (FSQLocation *) locationFromDict:(NSDictionary *)dict
{
    FSQLocation * fsqLocation = [FSQLocation new];
    
    if (ValidString(((NSString *)dict[@"name"]))) {
        fsqLocation.name = dict[@"name"];
    }
    
    return fsqLocation;
}

@end
