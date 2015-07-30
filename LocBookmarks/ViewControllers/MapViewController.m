//
//  MapViewController.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "BookmarksListViewController.h"

#import "DBManager.h"

#import "FSQLocation.h"

#import "MapPointAnnotation.h"

#import "BaseMapView.h"

typedef enum {
    MapTypeDefault = 0,
    MapTypeRoute
} MapType;

@interface MapViewController ()
<BaseMapViewDelegate>
{
    __weak IBOutlet BaseMapView * _mapView;
    
    MapType _mapType;
    
    MapPointAnnotation * _newAnnotation;
    MapPointAnnotation * _centerAnnotation;
    
    MKPolyline * _routeOverlay;
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self addNotifications];
}

- (void) setupView
{
    _mapView.subDelegate = self;
    
    UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(longPressAction:)];
    longPressGesture.minimumPressDuration = 1;
    _mapView.userInteractionEnabled = YES;
    [_mapView addGestureRecognizer:longPressGesture];
}

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCreateRoadNotification:)
                                                 name:NOTIFICATION_CREATE_ROAD
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveCenterPinNotification:)
                                                 name:NOTIFICATION_CENTER_PIN
                                               object:nil];
}

- (void) receiveCreateRoadNotification:(NSNotification*)notification
{
    Bookmark * bookmark = [self bookmarkFromNotificationDict:notification.userInfo];
    
    [self selectBookmark:[self bookmarkFromNotificationDict:notification.userInfo]];
}

- (void) receiveCenterPinNotification:(NSNotification*)notification
{
    Bookmark * bookmark = [self bookmarkFromNotificationDict:notification.userInfo];
    
    for (MapPointAnnotation * annotationObject in _mapView.annotations) {
        if ([annotationObject isKindOfClass:[MKPointAnnotation class]]
            && [annotationObject.locationID isEqualToString:bookmark.bookmarkID]) {
            _centerAnnotation = annotationObject;
        }
    }
    
    if (!_centerAnnotation) {
        _centerAnnotation = [MapPointAnnotation annotionFromBookmark:bookmark];
    }
    
    MKCoordinateRegion region = _mapView.region;
    region.center = ((CLLocation *)(bookmark.coordinates)).coordinate;
    MKCoordinateSpan span = _mapView.region.span;
    span.latitudeDelta = 1;
    span.longitudeDelta = 1;
    region.span = span;
    [_mapView setRegion:region
               animated:YES];
}

- (Bookmark *) bookmarkFromNotificationDict:(NSDictionary *)dict
{
    return (Bookmark *)dict[@"bookmark"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateMapView];
    
    if (_centerAnnotation) {
        [_mapView addAnnotation:_centerAnnotation];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _centerAnnotation = nil;
}

- (void) updateMapView
{
    [_mapView removeAnnotations:_mapView.annotations];
    [self clearOverlays];
    
    if (_mapType == MapTypeDefault) {
        [_mapView addMapAnnotations:[[DBManager sharedManager] getAll:@"Bookmark"]];
    }
    else if (_mapType == MapTypeRoute) {
        [self showAllBookmarks];
    }
}

#pragma mark - actions

- (IBAction) routeAction
{
    if (_mapType == MapTypeDefault) {
        _mapType = MapTypeRoute;
    }
    else if (_mapType == MapTypeRoute) {
        _mapType = MapTypeDefault;
    }
    
    [self updateMapView];
}

- (void) longPressAction:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint
                                                  toCoordinateFromView:_mapView];
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude
                                                       longitude:touchMapCoordinate.longitude];
    
    _newAnnotation = [MapPointAnnotation annotionFromBookmark:[[DBManager sharedManager] bookmarkFromLocation:location]];
    
    [_mapView addAnnotation:_newAnnotation];
    
    [self searchFSQLocationsLatitude:_newAnnotation.coordinate.latitude
                           longitude:_newAnnotation.coordinate.longitude
                           fromPoint:touchPoint];
}

#pragma mark - bookmarks table delegate

- (void) createDirection:(MKDirectionsTransportType)type
              toBookmark:(Bookmark *)bookmark
{
    MKDirectionsRequest * directionsRequest = [MKDirectionsRequest new];
    directionsRequest.transportType = type;
    directionsRequest.requestsAlternateRoutes = YES;

    MKMapItem * source = [MKMapItem mapItemForCurrentLocation];
    [directionsRequest setSource:source];
    
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:((CLLocation *)bookmark.coordinates).coordinate
                                                              addressDictionary:nil];
    
    MKMapItem * destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    [directionsRequest setDestination:destination];
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    [MBProgressHUD showHUDAddedTo:PICKER_PRESENTATION_VIEW
                         animated:YES];
    
    [self.listPopoverController dismissPopoverAnimated:YES];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *currentRoute = [response.routes firstObject];
        
        if (currentRoute != nil) {
            [_mapView removeAnnotations:_mapView.annotations];
            
            [_mapView showAnnotations:@[_mapView.userLocation, [MapPointAnnotation annotionFromBookmark:bookmark]]
                             animated:YES];
            
            [self plotRouteOnMap:currentRoute];
            
            [MBProgressHUD hideAllHUDsForView:PICKER_PRESENTATION_VIEW
                                     animated:YES];
        }
        else {
            ALERT(@"Sorry", @"There are no routes found", nil, @"Ok", nil);
        }
    }];
}

- (void)plotRouteOnMap:(MKRoute *)route
{
    [self clearOverlays];
    
    _routeOverlay = route.polyline;
    
    [_mapView addOverlay:_routeOverlay
                   level:MKOverlayLevelAboveLabels];
}

- (void) clearOverlays
{
    if(_routeOverlay) {
        [_mapView removeOverlay:_routeOverlay];
    }
}

- (void) selectItem:(id)item
{
    if ([item isKindOfClass:[FSQLocation class]]) {
        FSQLocation * location = (FSQLocation *)item;
        
        Bookmark * bookmark = [[[DBManager sharedManager] getAll:@"Bookmark"
                                                  withPredicate:[NSPredicate predicateWithFormat:@"bookmarkID == %@", _newAnnotation.locationID]] firstObject];
        
        bookmark.name = location.name;
        
        [[DBManager sharedManager] save];
        
        [_mapView removeAnnotation:_newAnnotation];
        _newAnnotation = nil;
        
        [_mapView addAnnotation:[MapPointAnnotation annotionFromBookmark:bookmark]];
        
        [self.listPopoverController dismissPopoverAnimated:YES];
    }
    else if ([item isKindOfClass:[Bookmark class]]) {
        [self selectBookmark:item];
    }
}

- (void) selectBookmark:(Bookmark *)bookmark
{
    [[[UIAlertView alloc] initWithTitle:@"Select transport type"
                                message:nil
                       cancelButtonItem:nil
                       otherButtonItems:
      [RIButtonItem itemWithLabel:@"Automobile"
                           action:^{
                               [self createDirection:MKDirectionsTransportTypeAutomobile
                                          toBookmark:bookmark];
                           }],
      [RIButtonItem itemWithLabel:@"Walking"
                           action:^{
                               [self createDirection:MKDirectionsTransportTypeWalking
                                          toBookmark:bookmark];
                           }], nil]
     show];
}

#pragma mark - mapview subDelegate

- (void) selectMapBookmark:(Bookmark *)bookmark
{
    [self showDetailsBookmark:bookmark];
}

@end
