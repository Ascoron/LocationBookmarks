//
//  APIClient.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@interface APIClient : NSObject

+ (void) getFSQLocationsLatitude:(double)latitude
                       longitude:(double)longitude
                         success:(void (^)(NSArray * locations))success
                         failure:(void (^)(NSError * error))failure;

@end
