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
    CMAViewControllerIDNil = -1,
    CMAViewControllerIDViewEntries = 0,
    CMAViewControllerIDEditSettings = 1,
    CMAViewControllerIDAddEntry = 2,
    CMAViewControllerIDSingleEntry = 3,
    CMAViewControllerIDSingleLocation = 4,
    CMAViewControllerIDSingleBait = 5,
    CMAViewControllerIDViewBaits = 6,
    CMAViewControllerIDStatistics = 7,
    CMAViewControllerIDSelectFishingSpot = 8
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMAMeasuringSystemType) {
    CMAMeasuringSystemTypeImperial = 0,
    CMAMeasuringSystemTypeMetric = 1
};

// Each value represents the index for an item in a UISegmentedControlView.
typedef NS_ENUM(NSInteger, CMASortOrder) {
    CMASortOrderAscending = 0,
    CMASortOrderDescending = 1
};

// Each value >= 0 represents an index for a row in a UITableView.
typedef NS_ENUM(NSInteger, CMAEntrySortMethod) {
    CMAEntrySortMethodNil = -1,
    CMAEntrySortMethodDate = 0,
    CMAEntrySortMethodSpecies = 1,
    CMAEntrySortMethodLocation = 2,
    CMAEntrySortMethodLength = 3,
    CMAEntrySortMethodWeight = 4,
    CMAEntrySortMethodBaitUsed = 5
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
