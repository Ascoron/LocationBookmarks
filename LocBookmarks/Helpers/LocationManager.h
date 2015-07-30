//
//  LocationManager.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (LocationManager *) sharedManager;

@property (nonatomic, strong) NSMutableArray * fsqLocations;

- (void) getCurrentLocation:(void (^)(CLLocation *location, CLPlacemark *placemark))complite;


@end
