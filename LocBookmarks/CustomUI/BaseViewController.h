//
//  BaseViewController.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>

#import "BaseTableView.h"

@interface BaseViewController : UIViewController
<BaseTableViewDelegate, WYPopoverControllerDelegate>

@property (nonatomic, strong) BaseTableView * baseTableView;

@property (nonatomic, strong) WYPopoverController * listPopoverController;

- (void) showDetailsBookmark:(Bookmark *)bookmark;

- (void) initPopoverController;

- (void) searchFSQLocationsLatitude:(double)latitude
                          longitude:(double)longitude
                          fromPoint:(CGPoint)point;

- (void) showAllBookmarks;

@end
