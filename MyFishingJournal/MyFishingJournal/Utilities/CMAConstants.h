//
//  CMAConstants.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#ifndef MyFishingJournal_CMAConstants_h
#define MyFishingJournal_CMAConstants_h

typedef NS_ENUM(NSInteger, CMAViewControllerID) {
    CMAViewControllerID_Nil = -1,
    CMAViewControllerID_ViewEntries = 0,
    CMAViewControllerID_EditSettings = 1,
    CMAViewControllerID_AddEntry = 2,
    CMAViewControllerID_SingleEntry = 3,
    CMAViewControllerID_SingleLocation = 4,
    CMAViewControllerID_SingleBait = 5,
    CMAViewControllerID_ViewBaits = 6,
    CMAViewControllerID_Statistics = 7
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMAMeasuringSystemType) {
    CMAMeasuringSystemType_Imperial = 0,
    CMAMeasuringSystemType_Metric = 1
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMASortOrder) {
    CMASortOrder_Ascending = 0,
    CMASortOrder_Descending = 1
};

// Each value >= 0 represents an index for a row in a UITableView.
typedef NS_ENUM(NSInteger, CMAEntrySortMethod) {
    CMAEntrySortMethod_Nil = -1,
    CMAEntrySortMethod_Date = 0,
    CMAEntrySortMethod_Species = 1,
    CMAEntrySortMethod_Location = 2,
    CMAEntrySortMethod_Length = 3,
    CMAEntrySortMethod_Weight = 4,
    CMAEntrySortMethod_BaitUsed = 5
};

extern NSString *const SET_SPECIES;
extern NSString *const SET_BAITS;
extern NSString *const SET_LOCATIONS;
extern NSString *const SET_FISHING_METHODS;

// Used for splitting up NSStrings.
extern NSString *const TOKEN_FISHING_METHODS;
extern NSString *const TOKEN_LOCATION;

// User data file name.
extern NSString *const ARCHIVE_FILE_NAME;

extern NSString *const SHARE_MESSAGE;
extern NSString *const REMOVED_TEXT; // text displayed in an entry when a user define has been removed

extern NSString *const GLOBAL_FONT;

extern CGFloat const TABLE_SECTION_SPACING;

UIColor *CELL_COLOR_DARK; // initialized in AppDelegate.m
UIColor *CELL_COLOR_LIGHT; // initialized in AppDelegate.m

#endif
