//
//  DBManager.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "DBManager.h"

static DBManager *_sharedManager = nil;

@implementation DBManager

#pragma mark - init

+ (DBManager *)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        _sharedManager = [DBManager new];
    } );
    return _sharedManager;
}

#pragma mark - get

- (NSArray *) getAll:(NSString *)entity
{
    return [self getAll:entity
          withPredicate:nil];
}

- (NSArray *) getAll:(NSString *)entity
       withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entity
                                   inManagedObjectContext:[self managedObjectContext]]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request
                                                                 error:&error];
    if (error) {
        return nil;
    }
    
    return result;
}

- (Bookmark *) bookmarkFromLocation:(CLLocation *)location
{
    Bookmark * newBookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark"
                                                           inManagedObjectContext:[self managedObjectContext]];
    
    newBookmark.bookmarkID = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    newBookmark.coordinates = location;
    newBookmark.name = UNKNOWN_KEY;
    
    [self save];
    
    return newBookmark;
}

- (void) removeDataObject:(id)dataObject
{
    [[self managedObjectContext] deleteObject:dataObject];
    
    [self save];
}

#pragma mark - CoreData init

- (void) save
{
    [self saveContext];
}

- (void) saveContext
{
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    if (managedObjectContext != nil
        && managedObjectContext.hasChanges
        && ![managedObjectContext save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"locbookmarks"
                                              withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"locbookmarks.sqlite"]];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @(YES),
                              NSInferMappingModelAutomaticallyOption : @(YES)
                              };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *) applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
