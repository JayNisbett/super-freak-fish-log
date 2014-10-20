//
//  CMAEditSettingsViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAEditSettingsViewController.h"
#import "CMAAppDelegate.h"
#import "CMAAddLocationViewController.h"

@interface CMAEditSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic) UIAlertView *addItemAlert;

@end

@implementation CMAEditSettingsViewController

- (CMAJournal *)journal {
    return [((CMAAppDelegate *)[[UIApplication sharedApplication] delegate]) journal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.title = self.settingName; // sets title according to the setting that was clicked in the previous view
    
    self.navigationController.toolbarHidden = NO;
    
    // initilize addItemAlert
    self.addItemAlert = [UIAlertView new];
    self.addItemAlert = [self.addItemAlert initWithTitle:@"" message:[NSString stringWithFormat:@"Add to %@:", self.settingName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    self.addItemAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[[self journal] userDefines] objectForKey:self.settingName] count];
}

// Initialize each cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editSettingsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[[[self journal] userDefines] objectForKey:self.settingName] nameAtIndex:indexPath.item];
    
    return cell;
}

// handles all UIAlertViews results for this screen
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // add the new user define
    if (alertView == self.addItemAlert)
        if (buttonIndex == 1) {
            [[self journal] addUserDefine:self.settingName objectToAdd:[[[alertView textFieldAtIndex:0] text] capitalizedString]];
            [self.tableView reloadData];
        }
}

- (IBAction)clickAddButton:(UIBarButtonItem *)sender {
    if ([self.settingName isEqualToString:SET_LOCATIONS])
        [self performSegueWithIdentifier:@"fromEditSettingsToAddLocation" sender:self];
    else
        [self.addItemAlert show];
}

// Enter editing mode.
- (IBAction)clickDeleteButton:(UIBarButtonItem *)sender {
    [self.tableView setEditing:YES animated:YES];
    [sender setEnabled:NO];
    [self.addButton setEnabled:NO];
    
    // add a done button that will be used to exit editing mode
    UIBarButtonItem *doneButton = [UIBarButtonItem new];
    doneButton = [doneButton initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

// Used to exit out of editing mode.
- (void)clickDoneButton {
    [self.tableView setEditing:NO animated:YES];
    [self.deleteButton setEnabled:YES];
    [self.addButton setEnabled:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete from data source
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [[self journal] removeUserDefine:self.settingName objectNamed:cell.textLabel.text];
        
        // delete from table
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromEditSettingsToAddLocation"]) {
        CMAAddLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerID_EditSettings;
    }
}

- (IBAction)unwindToEditSettings:(UIStoryboardSegue *)segue {
    self.navigationController.toolbarHidden = NO;
}

@end
