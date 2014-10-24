//
//  CMAUserDefine.h
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAUserDefine : NSObject

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSMutableSet *objects;

// instance creation
+ (CMAUserDefine *)withName: (NSString *)aName;

// initialization
- (id)initWithName: (NSString *)aName;

// editing
- (void)addObject: (id)anObject;
- (void)removeObjectNamed: (NSString *)aName;
- (void)editObjectNamed: (NSString *)aName newObject: (id)aNewObject;

// accessing
- (NSInteger)count;
- (NSString *)nameAtIndex: (NSInteger)anIndex;
- (BOOL)isSetOfStrings;

@end
