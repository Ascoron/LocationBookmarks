//
//  BaseMapView.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "BaseMapView.h"

#import "MapPointAnnotation.h"

#import "DBManager.h"

@interface BaseMapView ()
<MKMapViewDelegate>

@end

@implementation BaseMapView

- (BaseMapView *) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        self.delegate = self;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void) addMapAnnotations:(NSArray *)array
{
    for (Bookmark * bookmark in array) {
        [self addAnnotation:[MapPointAnnotation annotionFromBookmark:bookmark]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (!pinView
        && ![annotation isKindOfClass:[MKUserLocation class]]) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:@"pinView"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer * renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 2.0;
    return renderer;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MapPointAnnotation * annotation = view.annotation;
    
    Bookmark * bookmark = [[[DBManager sharedManager] getAll:@"Bookmark"
                                               withPredicate:[NSPredicate predicateWithFormat:@"bookmarkID == %@", annotation.locationID]] firstObject];
    
    if (bookmark
        && [_subDelegate respondsToSelector:@selector(selectMapBookmark:)]) {
        [_subDelegate selectMapBookmark:bookmark];
    }
}

@end
