//
//  Bookmark.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSString * bookmarkID;
@property (nonatomic, retain) NSString * name;

@property (nonatomic, retain) id coordinates;

@end
