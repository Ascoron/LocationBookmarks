//
//  FSQLocation.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSQLocation : NSObject

@property (nonatomic, strong) NSString * name;

+ (FSQLocation *) locationFromDict:(NSDictionary *)dict;

@end
