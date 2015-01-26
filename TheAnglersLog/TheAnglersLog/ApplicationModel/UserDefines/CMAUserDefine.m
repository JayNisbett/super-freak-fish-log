//
//  CMAUserDefine.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/9/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAUserDefine.h"
#import "CMALocation.h"
#import "CMABait.h"
#import "CMASpecies.h"
#import "CMAFishingMethod.h"
#import "CMAWaterClarity.h"
#import "CMAConstants.h"
#import "CMAStorageManager.h"

@implementation CMAUserDefine

@dynamic objects;
@dynamic journal;

#pragma mark - Initialization

- (CMAUserDefine *)initWithName:(NSString *)aName andJournal:(CMAJournal *)aJournal {
    self.name = aName;
    self.journal = aJournal;
    self.objects = [NSMutableOrderedSet orderedSet];
    
    return self;
}

#pragma mark - Validation

- (void)validateObjects {
    for (id o in self.objects)
        [o validateProperties];
}

#pragma mark - Archiving
/*
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"CMAUserDefineName"];
        _objects = [aDecoder decodeObjectForKey:@"CMAUserDefineObjects"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"CMAUserDefineName"];
    [aCoder encodeObject:self.objects forKey:@"CMAUserDefineObjects"];
}
*/
#pragma Editing

// Does nothing if an object with the same name already exists in self.objects.
- (BOOL)addObject:(id)anObject {
    if ([self objectNamed:[anObject name]] != nil) {
        NSLog(@"Duplicate object name.");
        return NO;
    }
    
    [self.objects addObject:anObject];
    [self sortByNameProperty];
    return YES;
}

- (void)removeObjectNamed:(NSString *)aName {
    [self.objects removeObject:[self objectNamed:aName]];
}

- (void)editObjectNamed:(NSString *)aName newObject: (id)aNewObject {
    [[self objectNamed:aName] edit:aNewObject];
    [self sortByNameProperty];
}

#pragma mark - Accessing

- (NSInteger)count {
    return [self.objects count];
}

- (id)objectNamed:(NSString *)aName {
    for (id obj in self.objects)
        if ([[obj name] isEqualToString:aName])
            return obj;
    
    return nil;
}

- (BOOL)isSetOfStrings {
    return ![self.name isEqualToString:UDN_LOCATIONS] &&
           ![self.name isEqualToString:UDN_BAITS];
}

#pragma mark - Object Types

// Returns an object of correct type with the name property set to aName.
- (id)emptyObjectNamed:(NSString *)aName {
    CMAStorageManager *manager = [CMAStorageManager sharedManager];
    
    if ([self.name isEqualToString:UDN_SPECIES])
        return [[manager managedSpecies] initWithName:aName];
    
    if ([self.name isEqualToString:UDN_FISHING_METHODS])
        return [[manager managedFishingMethod] initWithName:aName];
    
    if ([self.name isEqualToString:UDN_WATER_CLARITIES])
        return [[manager managedWaterClarity] initWithName:aName];
    
    NSLog(@"Invalid user define name in [CMAUserDefine emptyObjectNamed].");
    return nil;
}

#pragma mark - Sorting

- (void)sortByNameProperty {
    self.objects = [[self.objects sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2){
        return [[o1 name] compare:[o2 name]];
    }] mutableCopy];
}

@end
