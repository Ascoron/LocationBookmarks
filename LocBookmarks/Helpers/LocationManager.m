//
//  LocationManager.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()
<CLLocationManagerDelegate>
{
    CLLocationManager * _locationManager;
    
    CLGeocoder * _geocoder;
    
    CLLocation * _currentUserLocation;
}

@property (nonatomic, copy) void (^complite)(CLLocation * location, CLPlacemark * placemark);

@end

@implementation LocationManager

static LocationManager * _sharedLocationManager = nil;

+ (LocationManager *) sharedManager
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedLocationManager = [self new];
    });
    return _sharedLocationManager;
}

- (id)init
{
    self = [super init];
    
    if(self) {
        _locationManager = [CLLocationManager new];
        _geocoder = [CLGeocoder new];
        
        [_locationManager setDelegate:self];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [_locationManager setHeadingFilter:kCLHeadingFilterNone];
        [_locationManager startUpdatingLocation];
        
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

- (void) getCurrentLocation:(void (^)(CLLocation *, CLPlacemark *))complite
{
    if (_currentUserLocation) {
        PERFORM_BLOCK(complite, _currentUserLocation, nil);
    }
    else {
        self.complite = complite;
        if (IS_OS_8_OR_LATER) {
            [_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
}

- (void) startDetectingLocation
{
    self.complite = nil;
    if (IS_OS_8_OR_LATER) {
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    [_locationManager stopUpdatingLocation];
    
    PERFORM_BLOCK(self.complite, nil, nil);
}

- (void) locationManager:(CLLocationManager *)manager
      didUpdateLocations:(NSArray *)locations
{
    CLLocation * lastLocation = [locations lastObject];
    
    _currentUserLocation = lastLocation;
    
    if (self.complite) {
        [_locationManager stopUpdatingLocation];
        
        [self getDataFromLocation:lastLocation];
    }
}

- (void) getDataFromLocation:(CLLocation *) location
{
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (!error
                            && placemarks
                            && placemarks.count > 0) {
                            CLPlacemark * placemarkLoc = [placemarks firstObject];
                            
                            PERFORM_BLOCK(self.complite, location, placemarkLoc);
                            
                            [self startDetectingLocation];
                        }
                        else {
                            [self startDetectingLocation];
                        }
                    }];
}

@end
