//
//  MapPointAnnotation.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "MapPointAnnotation.h"

@implementation MapPointAnnotation

+ (MapPointAnnotation *) annotionFromBookmark:(Bookmark *)bookmark
{
    MapPointAnnotation * annotation = [MapPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(((CLLocation *)bookmark.coordinates).coordinate.latitude, ((CLLocation *)bookmark.coordinates).coordinate.longitude);
    annotation.title = bookmark.name;
    annotation.locationID = bookmark.bookmarkID;
    return annotation;
}

@end
