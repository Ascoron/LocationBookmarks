//
//  DBManager.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "FSQLocation.h"

@interface DBManager : NSObject

@property (nonatomic, strong) NSManagedObjectModel         * managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext       * managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

+ (DBManager *) sharedManager;

- (void) save;

- (NSArray *) getAll:(NSString *)entity;
- (NSArray *) getAll:(NSString *)entity
       withPredicate:(NSPredicate *)predicate;

- (Bookmark *) bookmarkFromLocation:(CLLocation *)location;

- (void) removeDataObject:(id)dataObject;

@end
