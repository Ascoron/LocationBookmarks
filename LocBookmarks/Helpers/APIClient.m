//
//  APIClient.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "APIClient.h"
#import "Reachability.h"
#import "LocationManager.h"

#import "FSQLocation.h"

#define kFSQClientID        @"A21JH4TDV31S0PUDAEGHENLCQCADYXZMNLJTTSAZEQV53CJU"
#define kFSQClientSecret    @"G4G1XOKFDKGZWTKGVQFFJ15BXKFPGM0GQFV5VSEUCKKL3E1X"
#define kFSQVersion         @"20120609"
#define kFSQRadius          @"200"
#define kFSQLimit           @"50"
#define kFSQAltAcc          @"5000.0"
#define kFSQLlAcc           @"5000.0"

@implementation APIClient

+ (void) getFSQLocationsLatitude:(double)latitude
                       longitude:(double)longitude
                         success:(void (^)(NSArray * locations))success
                        failure:(void (^)(NSError * error))failure
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        
        NSDictionary *parameters = @{
                                     @"ll" : [NSString stringWithFormat:@"%.2f,%.2f", latitude, longitude],
                                     @"client_id" : kFSQClientID,
                                     @"client_secret" : kFSQClientSecret,
                                     @"v" : kFSQVersion,
                                     @"radius" : kFSQRadius,
                                     @"limit" : kFSQLimit,
                                     @"altAcc" : kFSQAltAcc,
                                     @"llAcc" : kFSQLlAcc
                                     };
        
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:@"https://api.foursquare.com/v2/venues/search"
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 DLog(@"\n%@\n%@", operation, responseObject);
                 
                 if (responseObject[@"response"]
                     && responseObject[@"response"][@"venues"]) {
                     
                     [LocationManager sharedManager].fsqLocations = [NSMutableArray new];
                     
                     for (NSDictionary * dict in responseObject[@"response"][@"venues"]) {
                         [[LocationManager sharedManager].fsqLocations addObject:[FSQLocation locationFromDict:dict]];
                     }
                 }
                 
                 NSLog(@"Foursquare fetched");
                 
                 PERFORM_BLOCK(success, [LocationManager sharedManager].fsqLocations);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"\n%@\n%@", operation, error);
                 
                 PERFORM_BLOCK(failure, nil);
             }];
    }
    else {
        ALERT_INTERNET_CONNECTION;
    }
}

@end
