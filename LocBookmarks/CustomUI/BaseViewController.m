//
//  BaseViewController.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "BaseViewController.h"

#import "BookmarkDetailsViewController.h"

#import "APIClient.h"

#import "DBManager.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - actions 

- (void) showDetailsBookmark:(Bookmark *)bookmark
{
    BookmarkDetailsViewController * bookmarkDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BookmarkDetailsVC"];
    bookmarkDetailsVC.bookmark = bookmark;
    [self.navigationController pushViewController:bookmarkDetailsVC
                                         animated:YES];
}

- (void) searchFSQLocationsLatitude:(double)latitude
                          longitude:(double)longitude
                          fromPoint:(CGPoint)point
{
    [MBProgressHUD showHUDAddedTo:PICKER_PRESENTATION_VIEW
                         animated:YES];
    
    [APIClient getFSQLocationsLatitude:latitude
                             longitude:longitude
                               success:^(NSArray *locations) {
                                   [MBProgressHUD hideAllHUDsForView:PICKER_PRESENTATION_VIEW
                                                            animated:YES];
                                   
                                   if (locations.count > 0) {
                                       [self showPopoverFor:locations
                                             navigationItem:nil
                                                      point:point];
                                   }
                                   else {
                                       ALERT_ERROR(@"No locations found");
                                   }
                                   
                               } failure:^(NSError *error) {
                                   [MBProgressHUD hideAllHUDsForView:PICKER_PRESENTATION_VIEW
                                                            animated:YES];
                                   
                                   ALERT_ERROR(@"Some error happened");
                               }];
}

- (void) showAllBookmarks
{
    [self showPopoverFor:[[DBManager sharedManager] getAll:@"Bookmark"]
          navigationItem:self.navigationItem.leftBarButtonItem
                   point:CGPointZero];
}

- (void) showPopoverFor:(NSArray *)array
         navigationItem:(UIBarButtonItem *)navigationItem
                  point:(CGPoint)point
{
    [self initPopoverController];
    
    CGRect maxFrame = self.listPopoverController.contentViewController.view.frame;
    CGFloat contentHeight = array.count * 44;
    
    if (maxFrame.size.height > contentHeight) {
        if (IS_OS_8_OR_LATER) {
            [self.listPopoverController.contentViewController setPreferredContentSize:CGSizeMake(maxFrame.size.width, contentHeight)];
        }
        else {
            self.listPopoverController.contentViewController.contentSizeForViewInPopover = CGSizeMake(maxFrame.size.width, contentHeight);
        }
    }
    
    [self.baseTableView setW:self.listPopoverController.contentViewController.view.width];
    
    if (navigationItem) {
        [self.listPopoverController presentPopoverFromBarButtonItem:navigationItem
                                           permittedArrowDirections:WYPopoverArrowDirectionDown
                                                           animated:YES completion:^{
                                                               [self.baseTableView setW:self.listPopoverController.contentViewController.view.width];
                                                           }];
    }
    else
    {
        [self.listPopoverController presentPopoverFromRect:CGRectMake(point.x, point.y, 10, 10)
                                                    inView:self.view
                                  permittedArrowDirections:WYPopoverArrowDirectionAny
                                                  animated:YES
                                                completion:^{
                                                    [self.baseTableView setW:self.listPopoverController.contentViewController.view.width];
                                                }];
    }
    
    
    [self.baseTableView setItems:[array mutableCopy]];
}

#pragma mark - popover delegate

- (void) initPopoverController
{
    UIViewController * containerController = [UIViewController new];
    
    self.baseTableView = [BaseTableView new];
    self.baseTableView.frame = containerController.view.frame;
    self.baseTableView.subDelegate = self;
    [containerController.view addSubview:self.baseTableView];
    
    self.listPopoverController = [[WYPopoverController alloc] initWithContentViewController:containerController];
    self.listPopoverController.delegate = self;
}

- (BOOL) popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void) popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    self.listPopoverController.delegate = nil;
    self.listPopoverController = nil;
}

#pragma mark - memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
