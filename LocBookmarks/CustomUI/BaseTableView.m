//
//  BookmarksTableView.m
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#import "BaseTableView.h"

#import "FSQLocation.h"

@interface BaseTableView ()
<UITableViewDataSource, UITableViewDelegate>

@end

@implementation BaseTableView

- (BaseTableView *) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:(NSCoder *)aDecoder];
    if (self) {
        [self tableViewSetup];
    }
    return self;
}

- (BaseTableView *) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self tableViewSetup];
    }
    return self;
}

- (void) tableViewSetup
{
    self.delegate = self;
    self.dataSource = self;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

- (void) setItems:(NSMutableArray *)items
{
    _items = items;
    
    [self reloadData];
}

#pragma mark - delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }

    id object = _items[indexPath.row];
    
    if ([object isKindOfClass:[Bookmark class]]) {
        Bookmark * bookmark = (Bookmark *)object;
        cell.textLabel.text = bookmark.name;
    }
    else if ([object isKindOfClass:[FSQLocation class]]) {
        FSQLocation * location = (FSQLocation *)object;
        cell.textLabel.text = location.name;
    }
    
    cell.textLabel.minimumScaleFactor = 0.5;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0.5)];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_subDelegate respondsToSelector:@selector(selectItem:)]) {
        [_subDelegate selectItem:_items[indexPath.row]];
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.editing;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete
        && [_subDelegate respondsToSelector:@selector(removeItem:)]) {
        [_subDelegate removeItem:_items[indexPath.row]];
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

@end
