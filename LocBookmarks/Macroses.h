//
//  Macroses.h
//  LocBookmarks
//
//  Created by Paul Kovalenko on 29.07.15.
//  Copyright (c) 2015 Paul K. All rights reserved.
//

#define ALERT(title,msg,del,cancel,others) \
dispatch_async(dispatch_get_main_queue(), ^{ \
UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:del cancelButtonTitle:cancel otherButtonTitles:others, nil]; \
[alertView show];\
});

#define ALERT_ERROR(errorString)    ALERT(@"Error", errorString, nil, nil, @"Ok")

#define ALERT_INTERNET_CONNECTION   ALERT_ERROR(@"No internet connection")

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define PERFORM_BLOCK(block, ...) if (block) block(__VA_ARGS__)

#define PICKER_PRESENTATION_VIEW    [[UIApplication sharedApplication] keyWindow]

#define ValidString(pointer)    (pointer != nil && pointer.length > 0)

#define UNKNOWN_KEY     @"Unknown"

#define NOTIFICATION_CREATE_ROAD    @"NOTIFICATION_CREATE_ROAD"
#define NOTIFICATION_CENTER_PIN     @"NOTIFICATION_CENTER_PIN"