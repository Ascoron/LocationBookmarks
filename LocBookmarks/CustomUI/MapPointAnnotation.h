//
//  MapPointAnnotation.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapPointAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString * locationID;

+ (MapPointAnnotation *) annotionFromBookmark:(Bookmark *)bookmark;

@end
