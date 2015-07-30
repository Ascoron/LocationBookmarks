//
//  BookmarksListViewController.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 30.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "BookmarksListViewController.h"

#import "DBManager.h"

@interface BookmarksListViewController ()
{
    NSMutableArray * _source;
    
    __weak IBOutlet BaseTableView * _baseTableView;
}

@end

@implementation BookmarksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void) setupView
{
    self.title = @"Bookmarks";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(editListAction)];
    
    self.baseTableView = _baseTableView;
    
    self.baseTableView.subDelegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _source = [[[DBManager sharedManager] getAll:@"Bookmark"] mutableCopy];
    
    [self.baseTableView setItems:_source];
}

#pragma mark - action

- (void) editListAction
{
    [self.baseTableView setEditing:!self.baseTableView.editing
                          animated:YES];
}

#pragma mark - tableview delegate 

- (void) selectItem:(id)item
{
    [self showDetailsBookmark:item];
}

- (void) removeItem:(id)item
{
    [_source removeObject:item];
    
    [self.baseTableView reloadData];
    
    [[DBManager sharedManager] removeDataObject:item];
}

@end
