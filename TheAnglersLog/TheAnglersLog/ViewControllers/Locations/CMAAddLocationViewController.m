//
//  CMASingleLocationViewController.m
//  TheAnglersLog
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddLocationViewController.h"
#import "CMAAddFishingSpotViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAlerts.h"
#import "CMAUtilities.h"

@interface CMAAddLocationViewController ()

@property (weak, nonatomic)IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;

@property (weak, nonatomic)UITextField *locationNameTextField;

@property (strong, nonatomic)NSMutableOrderedSet *addedFishingSpots;
@property (nonatomic)BOOL isEditingLocation;

@end

NSInteger const SECTION_TITLE = 0;
NSInteger const SECTION_FISHING_SPOTS = 1;
NSInteger const SECTION_ADD = 2;

@implementation CMAAddLocationViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setEditing:YES];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
    
    self.isEditingLocation = (self.previousViewID == CMAViewControllerIDSingleLocation || self.previousViewID == CMAViewControllerIDSelectFishingSpot);
    
    if (self.isEditingLocation) {
        self.navigationItem.title = @"Edit Location";
    } else {
        self.location = [[CMAStorageManager sharedManager] managedLocation];
    }
    
    self.addedFishingSpots = [NSMutableOrderedSet orderedSet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == SECTION_ADD && [self.location fishingSpotCount] <= 0)
        return CGFLOAT_MIN;
    
    return TABLE_SECTION_SPACING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_FISHING_SPOTS)
        return [self.location fishingSpotCount];
    
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_FISHING_SPOTS)
        return YES;
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

// Initialize each cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_TITLE) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationNameCell" forIndexPath:indexPath];
        
        self.locationNameTextField = (UITextField *)[cell viewWithTag:100];
        if (self.isEditingLocation)
            self.locationNameTextField.text = self.location.name;
        
        return cell;
    }
    
    if (indexPath.section == SECTION_FISHING_SPOTS) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fishingSpotCell" forIndexPath:indexPath];

        CMAFishingSpot *fishingSpot = [self.location.fishingSpots objectAtIndex:indexPath.item];
        NSString *coordinateText = [NSString stringWithFormat:@"Lat: %f, Long: %f", fishingSpot.location.coordinate.latitude, fishingSpot.location.coordinate.longitude];
        
        cell.textLabel.text = fishingSpot.name;
        cell.detailTextLabel.text = coordinateText;
        
        return cell;
    }
    
    if (indexPath.section == SECTION_ADD) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addFishingSpotCell" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SECTION_TITLE:
        case SECTION_ADD:
            return UITableViewCellEditingStyleNone;
        
        case SECTION_FISHING_SPOTS:
            return UITableViewCellEditingStyleDelete;
            
        default:
            return UITableViewCellEditingStyleDelete;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSLog(@"addedFishingSpots: %ld before delete.", (long)[self.addedFishingSpots count]);
        
        // remove fishing spot from addedFishingSpots if needed
        id obj;
        for (CMAFishingSpot *s in self.addedFishingSpots)
            if ([s.name isEqualToString:[cell.textLabel.text capitalizedString]]) {
                obj = s;
                break;
            }
        
        [self.addedFishingSpots removeObject:obj];
        NSLog(@"addedFishingSpots: %ld after delete.", (long)[self.addedFishingSpots count]);
        
        [self.location removeFishingSpotNamed:cell.textLabel.text];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Location Creation

- (BOOL)checkUserInputAndSetLocation:(CMALocation *)aLocation {
    // validate fishing spot name
    if ([self.locationNameTextField.text isEqualToString:@""]) {
        [CMAAlerts errorAlert:@"Please enter a location name." presentationViewController:self];
        return NO;
    }
    
    // make sure the location name doesn't already exist
    if (!self.isEditingLocation)
        if ([[[self journal] userDefineNamed:UDN_LOCATIONS] objectNamed:self.locationNameTextField.text] != nil) {
            [CMAAlerts errorAlert:@"A location by that name already exists. Please choose a new name or edit the existing location." presentationViewController:self];
            return NO;
        }
    
    // make sure there is at least one fishing spot
    if ([self.location fishingSpotCount] <= 0) {
        [CMAAlerts errorAlert:@"Please add at least one fishing spot." presentationViewController:self];
        return NO;
    }
    
    [aLocation setName:[self.locationNameTextField.text mutableCopy]];
    [aLocation setFishingSpots:self.location.fishingSpots];
    
    return YES;
}

#pragma mark - Events

- (IBAction)clickedDone:(id)sender {
    CMALocation *locationToAdd = [[CMAStorageManager sharedManager] managedLocation];
    
    [CMAUtilities addSceneConfirmWithObject:locationToAdd
                                  objToEdit:self.location
                            checkInputBlock:^BOOL () { return [self checkUserInputAndSetLocation:locationToAdd]; }
                             isEditingBlock:^BOOL () { return self.isEditingLocation; }
                            editObjectBlock:^void () { [[self journal] editUserDefine:UDN_LOCATIONS objectNamed:self.location.name newProperties:locationToAdd]; }
                             addObjectBlock:^BOOL () { return [[self journal] addUserDefine:UDN_LOCATIONS objectToAdd:locationToAdd]; }
                              errorAlertMsg:@"A location with that name already exists. Please select a new name or edit the existing location."
                             viewController:self
                                 segueBlock:^void () { [self performSegueToPreviousView]; }
                            removeObjToEdit:YES];
}

- (IBAction)clickedCancel:(id)sender {
    // clean up core data
    if (!self.isEditingLocation) {
        [[CMAStorageManager sharedManager] deleteManagedObject:self.location];
        self.location = nil;
    }
    
    // remove all added fishing spots
    for (CMAFishingSpot *s in self.addedFishingSpots) {
        if (self.isEditingLocation)
            [self.location removeFishingSpotNamed:s.name]; // removeFishingSpot deletes core data
        else
            [[CMAStorageManager sharedManager] deleteManagedObject:s];
    }
    
    self.addedFishingSpots = nil;
    
    [self performSegueToPreviousView];
}

#pragma mark - Navigation

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerIDEditSettings:
            [self performSegueWithIdentifier:@"unwindToEditSettingsFromAddLocation" sender:self];
            break;
            
        case CMAViewControllerIDSingleLocation:
            [self performSegueWithIdentifier:@"unwindToSingleLocationFromAddLocation" sender:self];
            break;
            
        case CMAViewControllerIDSelectFishingSpot:
            [self performSegueWithIdentifier:@"unwindToSelectFishingSpotFromAddLocation" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromFishingSpotCellToAddFishingSpot"]) {
        CMAAddFishingSpotViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        NSString *selectedCellText = [[[self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]] textLabel] text];
        destination.fishingSpot = [self.location fishingSpotNamed:selectedCellText];
        destination.locationFromAddLocation = self.location;
    }
    
    if ([segue.identifier isEqualToString:@"fromAddFishingSpotCellToAddFishingSpot"]) {
        CMAAddFishingSpotViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.locationFromAddLocation = self.location;
    }
}

- (IBAction)unwindToAddLocation:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToAddLocationFromAddFishingSpot"]) {
        CMAAddFishingSpotViewController *source = [segue sourceViewController];
        
        if (source.fishingSpot) {
            // making this connection automatically adds source.fishingSpot to self.location
            source.fishingSpot.myLocation = self.location;
            
            [self.addedFishingSpots addObject:source.fishingSpot];
        }
        
        source.fishingSpot = nil;
        source.locationFromAddLocation = nil;
        
        [self.tableView reloadData];
    }
}

@end
