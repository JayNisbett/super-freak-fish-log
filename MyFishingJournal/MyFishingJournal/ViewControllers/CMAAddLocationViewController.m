//
//  CMASingleLocationViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/19/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMAAddLocationViewController.h"

@interface CMAAddLocationViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation CMAAddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performSegueToPreviousView {
    switch (self.previousViewID) {
        case CMAViewControllerID_EditSettings:
            [self performSegueWithIdentifier:@"unwindToEditSettings" sender:self];
            break;
            
        case CMAViewControllerID_AddEntry:
            [self performSegueWithIdentifier:@"unwindToAddEntry" sender:self];
            break;
            
        default:
            NSLog(@"Invalid previousViewID value");
            break;
    }
}

- (IBAction)clickedDone:(id)sender {
    [self performSegueToPreviousView];
}

- (IBAction)clickedCancel:(id)sender {
    [self performSegueToPreviousView];
}

@end
