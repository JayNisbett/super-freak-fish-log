//
//  CMAEntryTestCase.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/3/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMAEntry.h"

@interface CMAEntryTestCase : XCTestCase

@end

@implementation CMAEntryTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (CMAEntry *)sampleEntryOne {
    CMAEntry *entry = [CMAEntry onDate:[NSDate date]];
    [entry setFishSpecies:[CMASpecies withName:@"Steelhead"]];
    [entry setFishLength:[NSNumber numberWithInt:30]];
    [entry setFishWeight:[NSNumber numberWithInt:5]];
    [entry setFishingMethods:[NSMutableSet setWithObjects:@"Boat", @"Troll", nil]];
    
    return entry;
}

- (void)testAddRemoveImage {
    CMAEntry *myEntry = [self sampleEntryOne];
    
    UIImage *image1 = [UIImage imageNamed:@"no-image.png"];
    UIImage *image2 = [UIImage imageNamed:@"apple-logo.png"];
    UIImage *image3 = [UIImage imageNamed:@"orange.jpeg"];
    
    // addImage
    XCTAssert([myEntry imageCount] == 0, @"Wrong image count; should be 0");
    [myEntry addImage:image1];
    XCTAssert([myEntry imageCount] == 1, @"Wrong image count; should be 1");
    [myEntry addImage:image2];
    [myEntry addImage:image3];
    XCTAssert([myEntry imageCount] == 3, @"Wrong image count; should be 3");
    
    // removeImage
    [myEntry removeImage:image1];
    [myEntry removeImage:image2];
    XCTAssert([myEntry imageCount] == 1, @"Wrong image count; should be 1");
    [myEntry removeImage:image3];
    XCTAssert([myEntry imageCount] == 0, @"Wrong image cound; should be 0");
}

- (void)testFishingMethodCount {
    CMAEntry *myEntry = [self sampleEntryOne];
    XCTAssert([myEntry fishingMethodCount] == 2, @"Wrong fishing method count; should be 2");
}

@end
