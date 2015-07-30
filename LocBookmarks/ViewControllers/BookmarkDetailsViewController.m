//
//  BookmarkDetailsViewController.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "BookmarkDetailsViewController.h"

#import "DBManager.h"

#import "FSQLocation.h"

@interface BookmarkDetailsViewController ()
{
    __weak IBOutlet UILabel * _nameLabel;
    
    __weak IBOutlet UIButton * _centerButton;
    __weak IBOutlet UIButton * _roadButton;
}

@end

@implementation BookmarkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self setupNavigationBar];
}

- (void) setupNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(removeAction)];
}

- (void) setupView
{
    _nameLabel.text = _bookmark.name;

    if ([_bookmark.name isEqualToString:UNKNOWN_KEY]) {
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(getLocations)];
        tapGesture.numberOfTapsRequired = 1;
        [_nameLabel addGestureRecognizer:tapGesture];
        _nameLabel.userInteractionEnabled = YES;
    }
    else {
        _nameLabel.userInteractionEnabled = NO;
        
        _centerButton.hidden = NO;
        _roadButton.hidden = NO;
    }
}

#pragma mark - bookmarks table delegate

- (void) selectItem:(id)item
{
    if ([item isKindOfClass:[FSQLocation class]]) {
        FSQLocation * location = (FSQLocation *)item;
        
        _bookmark.name = location.name;
        
        [[DBManager sharedManager] save];
        
        [self setupView];
        
        [self.listPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - actions

- (void) getLocations
{
    [self searchFSQLocationsLatitude:((CLLocation *)_bookmark.coordinates).coordinate.latitude
                           longitude:((CLLocation *)_bookmark.coordinates).coordinate.longitude
                           fromPoint:_nameLabel.center];
}

- (void) removeAction
{
    [[DBManager sharedManager] removeDataObject:_bookmark];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) centerLocationAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CENTER_PIN
                                                        object:self
                                                      userInfo:@{@"bookmark": _bookmark}];
}

- (IBAction) roadToLocationAction:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATE_ROAD
                                                        object:self
                                                      userInfo:@{@"bookmark": _bookmark}];
}

@end
