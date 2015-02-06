//
//  CMAEntry.h
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMALocation.h"
#import "CMASpecies.h"
#import "CMABait.h"
#import "CMAWaterClarity.h"
#import "CMAWeatherData.h"
#import "CMAImage.h"

@class CMAJournal;

@interface CMAEntry : NSManagedObject

// date and time
@property (strong, nonatomic)NSDate *date;

// photos
@property (strong, nonatomic)NSMutableOrderedSet *images;

// fish details
@property (strong, nonatomic)CMASpecies *fishSpecies;
@property (strong, nonatomic)NSNumber *fishLength;
@property (strong, nonatomic)NSNumber *fishWeight;
@property (strong, nonatomic)NSNumber *fishOunces;
@property (strong, nonatomic)NSNumber *fishQuantity;
@property (nonatomic)CMAFishResult fishResult;

// catch details
@property (strong, nonatomic)CMABait *baitUsed;
@property (strong, nonatomic)NSMutableSet *fishingMethods;
@property (strong, nonatomic)CMALocation *location;
@property (strong, nonatomic)CMAFishingSpot *fishingSpot;

// weather conditions
@property (strong, nonatomic)CMAWeatherData *weatherData;

// water conditions
@property (strong, nonatomic)NSNumber *waterTemperature;
@property (strong, nonatomic)CMAWaterClarity *waterClarity;
@property (strong, nonatomic)NSNumber *waterDepth;

// notes
@property (strong, nonatomic)NSString *notes;

// journal
@property (strong, nonatomic)CMAJournal *journal;

// initializing
- (id)initWithDate:(NSDate *)aDate;
- (void)validateProperties;

// accessing
- (NSInteger)imageCount;
- (NSInteger)fishingMethodCount;
- (NSString *)locationAsString;
- (NSString *)fishingMethodsAsString;
- (NSString *)weightAsStringWithMeasurementSystem:(CMAMeasuringSystemType)aMeasurementSystem shorthand:(BOOL)useShorthand;
- (NSString *)fishResultAsString;

// editing
- (void)edit:(CMAEntry *)aNewEntry;
- (void)addImage:(CMAImage *)anImage;
- (void)removeImage:(CMAImage *)anImage;

@end
