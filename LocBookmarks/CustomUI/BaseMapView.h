//
//  BaseMapView.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol BaseMapViewDelegate <NSObject>
@optional
- (void) selectMapBookmark:(Bookmark *)bookmark;
@end

@interface BaseMapView : MKMapView

- (void) addMapAnnotations:(NSArray *)array;

@property (nonatomic, weak) id <BaseMapViewDelegate> subDelegate;

@end
