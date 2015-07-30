//
//  BaseTableView.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseTableViewDelegate <NSObject>
@optional
- (void) selectItem:(id)item;
- (void) removeItem:(id)item;
@end

@interface BaseTableView : UITableView

@property (nonatomic, strong) NSMutableArray * items;

@property (nonatomic, weak) id <BaseTableViewDelegate> subDelegate;

@end
