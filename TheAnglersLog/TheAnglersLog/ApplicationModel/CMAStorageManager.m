//
//  CMAStorageManager.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 2015-01-09.
//  Copyright (c) 2015 Cohen Adair. All rights reserved.
//

#import "CMAStorageManager.h"

@implementation CMAStorageManager

#pragma mark - Initializing

- (void)setSharedJournal:(CMAJournal *)sharedJournal {
    _sharedJournal = sharedJournal;
    [_sharedJournal validateProperties];
}

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static CMAStorageManager *sharedStorageManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedStorageManager = [self new];
    });
    
    return sharedStorageManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

#pragma mark - Journal Saving

// If saving to iCloud, will use CMAJournalDocument to archive and save data in a UIDocument.
// If saving to local storage, will simply archive the journal object.

- (void)saveJournal:(CMAJournal *)aJournal withFileName:(NSString *)aFileName {
    [self setSharedJournal:aJournal];
    __block CMAJournal *journal = [aJournal copy];
    
    // archive the journal in a separate thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.isCloudBackupEnabled)
            [self archiveJournal:journal toURL:[self cloudURL] withFileName:aFileName isLocal:NO];

        [self archiveJournal:journal toURL:[self localURL] withFileName:aFileName isLocal:YES]; // always save locally as well incase iCloud is disabled later
        journal = nil;
    });
}

- (void)archiveJournal:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName isLocal:(BOOL)isLocal {
    if (aURL) {
        if (isLocal)
            [self archiveJournalToLocalStorage:aJournal toURL:aURL withFileName:aFileName];
        else
            [self archiveJournalToCloudStorage:aJournal toURL:aURL withFileName:aFileName];
    } else
        NSLog(@"%@ URL = NULL", isLocal ? @"Local" : @"iCloud");
}

- (void)archiveJournalToCloudStorage:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName {
    NSURL *documentURL = [aURL URLByAppendingPathComponent:aFileName];
    
    CMAJournalDocument *document = [[CMAJournalDocument alloc] initWithFileURL:documentURL];
    document.journal = aJournal;
    
    [document saveToURL:documentURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        NSLog(@"Was iCloud save successful? %@", success ? @"YES" : @"NO");
    }];
}

- (void)archiveJournalToLocalStorage:(CMAJournal *)aJournal toURL:(NSURL *)aURL withFileName:(NSString *)aFileName {
    NSString *filePath = [aURL URLByAppendingPathComponent:aFileName].path;
    BOOL success = [NSKeyedArchiver archiveRootObject:aJournal toFile:filePath];
    
    NSLog(@"Was local save successful? %@", success ? @"YES" : @"NO");
}

#pragma mark - Cloud URL Methods

- (NSURL *)cloudURL {
    NSURL *result = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (result)
        result = [result URLByAppendingPathComponent:@"Documents"];
    else
        NSLog(@"Ubiquity URL is nil.");
    
    return result;
}

- (NSURL *)localURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *result = [NSURL fileURLWithPath:[paths firstObject]];
    
    if (!result)
        NSLog(@"Local URL is nil.");
    
    return result;
}

- (NSURL *)cloudURLWithFileName {
    return [[self cloudURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME];
}

- (NSURL *)localURLWithFileName {
    return [[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME];
}

#pragma mark - Journal Loading

// An NSMetadataQuery allows the app to receive notifications when the file is updated on iCloud.
// Reference: http://code.tutsplus.com/tutorials/working-with-icloud-document-storage--pre-37952

// Using an NSMetadataQuery is required according to the Apple Documentation because the URL can be changed at any time.

- (void)initCloudQuery {
    NSURL *cloudURL = [self cloudURL];
    
    if (cloudURL) {
        [self setCloudQuery:[NSMetadataQuery new]];
        [self.cloudQuery setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(cloudQueryDidFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:self.cloudQuery];
        [nc addObserver:self selector:@selector(cloudQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.cloudQuery];
        
        [self.cloudQuery startQuery];
    }
}

- (void)cloudQueryDidFinish:(NSNotification *)aNotification {
    [self.cloudQuery disableUpdates];
    
    NSLog(@"Cloud query finished.");
    [self loadJournalFromQueryNotification:aNotification forLiveUpdates:NO];
    
    [self.cloudQuery enableUpdates];
}

- (void)cloudQueryDidUpdate:(NSNotification *)aNotification {
    [self.cloudQuery disableUpdates];
    
    NSLog(@"Cloud query updated.");
    [self loadJournalFromQueryNotification:aNotification forLiveUpdates:YES];
    
    [self.cloudQuery enableUpdates];
}

- (void)loadJournalFromQueryNotification:(NSNotification *)aNotification forLiveUpdates:(BOOL)aBool {
    NSMetadataQuery *cloudQuery = [aNotification object];
    __block BOOL didUpdate = aBool;
    
    [cloudQuery.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = (NSMetadataItem *)obj;
        NSString *downloadingKey = [item valueForAttribute:NSMetadataUbiquitousItemDownloadingStatusKey];
        NSError *error;
        
        // download the file if it isn't already downloaded or being downloaded
        if (!self.cloudDownloadInitiated && [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusNotDownloaded]) {
            NSLog(@"Downloading data from iCloud...");
            [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:[item valueForAttribute:NSMetadataItemURLKey] error:&error];
            self.cloudDownloadInitiated = YES;
            self.cloudFileDidDownload = YES;
        }
        
        // self.cloudFileDidDownload is used so the journal data isn't updated several times during the initial query
        if (didUpdate && !self.cloudFileDidDownload)
            self.cloudFileDidDownload = [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusDownloaded];
        else
            self.cloudFileDidDownload = YES;
        
        // only update journal data if there is a working local copy (NSMetadataUbiquitousItemDownloadingStatusCurrent)
        if (self.cloudFileDidDownload && [downloadingKey isEqualToString:NSMetadataUbiquitousItemDownloadingStatusCurrent]) {
            NSLog(@"File downloaded, updating journal data.");
            [self loadJournalFromMetadataItem:item];
            self.cloudFileDidDownload = NO;
            self.cloudDownloadInitiated = NO;
        }
    }];
    
    if (cloudQuery.resultCount <= 0) {
        NSLog(@"No journal data found in iCloud, initializing from local storage.");
        [self loadJournalFromLocalStorage];
        
        // move data file to iCloud
        NSError *error;
        [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:[self localURLWithFileName] destinationURL:[self cloudURLWithFileName] error:&error];
        if (error)
            NSLog(@"Error moving file to iCloud: %@", error.localizedDescription);
        else
            NSLog(@"Successfully moved data file to iCloud.");
    }
}

- (void)loadJournalFromMetadataItem:(NSMetadataItem *)item {
    NSURL *documentURL = [item valueForAttribute:NSMetadataItemURLKey];
    CMAJournalDocument *document = [[CMAJournalDocument alloc] initWithFileURL:documentURL];
    
    // gets data from the most recently updated data file, whether it's from iCloud or local storage
    // this is done so the user's data isn't lost if iCloud was disabled for a period time
    
    NSDictionary *localFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self localURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path error:NULL];
    NSDictionary *cloudFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[self cloudURL] URLByAppendingPathComponent:ARCHIVE_FILE_NAME].path error:NULL];
    NSDate *localLastModified = [localFileAttributes fileModificationDate];
    NSDate *cloudLastModified = [cloudFileAttributes fileModificationDate];
    
    if ([localLastModified compare:cloudLastModified] == NSOrderedDescending) { // if local is newer than cloud
        NSLog(@"iCloud data found, but it's older than local data. Loading local data.");
        [self loadJournalFromLocalStorage];
        [[self sharedJournal] archive]; // save the newer, local data to iCloud
    } else
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self setSharedJournal:document.journal];
                [self postJournalChangeNotification];
            } else
                NSLog(@"Failed to load journal from iCloud.");
        }];
}

- (void)loadJournalWithCloudEnabled:(BOOL)isCloudEnabled {
    self.isCloudBackupEnabled = isCloudEnabled;
    
    if (isCloudEnabled)
        [self initCloudQuery];
    else
        [self loadJournalFromLocalStorage];
}

- (void)loadJournalFromLocalStorage {
    NSLog(@"Local path: %@", [self localURLWithFileName].path);
    
    self.sharedJournal = [NSKeyedUnarchiver unarchiveObjectWithFile:[self localURLWithFileName].path];
    
    if (!self.sharedJournal) {
        NSLog(@"No local data found, initializing new journal.");
        self.sharedJournal = [CMAJournal new];
    }
    
    [self postJournalChangeNotification];
}

#pragma mark - Notifications

- (void)postJournalChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHANGE_JOURNAL object:nil];
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)coreDataURL {
    // The directory the application uses to store the Core Data store file.
    NSURL *result = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    result = [result URLByAppendingPathComponent:@"com.theanglerslog.coredata"];
    NSLog(@"%@", result.path);
    
    return result;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TheAnglersLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self coreDataURL] URLByAppendingPathComponent:@"TheAnglersLog.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        NSLog(@"Error in persistentStoreCoordinator: %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        NSError *error = nil;
        
        if ([managedObjectContext hasChanges]) {
            NSLog(@"Saving data...");
            
            if (![managedObjectContext save:&error]) {
                NSLog(@"Failed to save data %@, %@.", error, [error userInfo]);
            } else
                NSLog(@"Saved library data.");
        }
    }
}

#pragma mark - Core Data Inserting/Deleting

- (void)insertManagedObject:(NSManagedObject *)aManagedObject {
    [self.managedObjectContext insertObject:aManagedObject];
}

- (void)deleteManagedObject:(NSManagedObject *)aManagedObject {
    [self.managedObjectContext deleteObject:aManagedObject];
}

#pragma mark - Core Data Object Initializers
// These methods are used to make initializing Core Data manged objects easier.
// The managed objects are NOT added to self.managedObjectContext.
// Example:
//   self.bait = [[CMAStorageManager sharedManager] managedBait];

- (NSEntityDescription *)entityNamed:(NSString *)aCDEString {
    return [NSEntityDescription entityForName:aCDEString
                       inManagedObjectContext:self.managedObjectContext];
}

- (CMABait *)managedBait {
    CMABait *result = [[CMABait alloc] initWithEntity:[self entityNamed:CDE_BAIT] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMALocation *)managedLocation {
    CMALocation *result = [[CMALocation alloc] initWithEntity:[self entityNamed:CDE_LOCATION] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMAFishingSpot *)managedFishingSpot {
    CMAFishingSpot *result = [[CMAFishingSpot alloc] initWithEntity:[self entityNamed:CDE_FISHING_SPOT] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMASpecies *)managedSpecies {
    CMASpecies *result = [[CMASpecies alloc] initWithEntity:[self entityNamed:CDE_SPECIES] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMAFishingMethod *)managedFishingMethod {
    CMAFishingMethod *result = [[CMAFishingMethod alloc] initWithEntity:[self entityNamed:CDE_FISHING_METHOD] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMAWaterClarity *)managedWaterClarity {
    CMAWaterClarity *result = [[CMAWaterClarity alloc] initWithEntity:[self entityNamed:CDE_WATER_CLARITY] insertIntoManagedObjectContext:nil];
    return [result initWithName:@""];
}

- (CMAUserDefine *)managedUserDefine {
    return [[CMAUserDefine alloc] initWithEntity:[self entityNamed:CDE_USER_DEFINE] insertIntoManagedObjectContext:nil];
}

- (CMAWeatherData *)managedWeatherData {
    return [[CMAWeatherData alloc] initWithEntity:[self entityNamed:CDE_USER_DEFINE] insertIntoManagedObjectContext:nil];
}

@end
