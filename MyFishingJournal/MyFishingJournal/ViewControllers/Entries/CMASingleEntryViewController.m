//
//  CMASingleEntryViewController.m
//  MyFishingJournal
//
//  Created by Cohen Adair on 10/26/14.
//  Copyright (c) 2014 Cohen Adair. All rights reserved.
//

#import "CMASingleEntryViewController.h"
#import "CMASingleLocationViewController.h"
#import "CMASingleBaitViewController.h"
#import "CMAAddEntryViewController.h"
#import "CMAAppDelegate.h"
#import "CMAConstants.h"
#import "CMAFishingMethod.h"
#import "CMAWeatherDataView.h"
#import "CMAStorageManager.h"

// Used to store information on the cells that will be shonw on the table.
// See initTableSettings.
@interface CMATableCellProperties : NSObject

@property (strong, nonatomic)NSString *labelText;
@property (strong, nonatomic)NSString *detailText;
@property (strong, nonatomic)NSString *reuseIdentifier;
@property (nonatomic)CGFloat height;
@property (nonatomic)BOOL hasSeparator;

+ (CMATableCellProperties *)withLabelText:(NSString *)aLabelText
                            andDetailText:(NSString *)aDetailText
                       andReuseIdentifier:(NSString *)aReuseIdentifier
                                andHeight:(CGFloat)aHeight
                             hasSeparator:(BOOL)aBool;

- (id)initWithLabelText:(NSString *)aLabelText
          andDetailText:(NSString *)aDetailText
     andReuseIdentifier:(NSString *)aReuseIdentifier
              andHeight:(CGFloat)aHeight
           hasSeparator:(BOOL)aBool;

@end

@implementation CMATableCellProperties

+ (CMATableCellProperties *)withLabelText:(NSString *)aLabelText
                            andDetailText:(NSString *)aDetailText
                       andReuseIdentifier:(NSString *)aReuseIdentifier
                                andHeight:(CGFloat)aHeight
                             hasSeparator:(BOOL)aBool {
    
    return [[self alloc] initWithLabelText:aLabelText
                             andDetailText:aDetailText
                        andReuseIdentifier:aReuseIdentifier
                                 andHeight:aHeight
                              hasSeparator:aBool];
}

- (id)initWithLabelText:(NSString *)aLabelText
          andDetailText:(NSString *)aDetailText
     andReuseIdentifier:(NSString *)aReuseIdentifier
              andHeight:(CGFloat)aHeight
           hasSeparator:(BOOL)aBool {
    
    if (self = [super init]) {
        _labelText = aLabelText;
        _detailText = aDetailText;
        _reuseIdentifier = aReuseIdentifier;
        _height = aHeight;
        _hasSeparator = aBool;
    }
    
    return self;
}

@end

@interface CMASingleEntryViewController ()

@property (strong, nonatomic)UICollectionView *imageCollectionView;

@property (strong, nonatomic)UIBarButtonItem *actionButton;
@property (strong, nonatomic)UIBarButtonItem *editButton;

@property (strong, nonatomic)NSOrderedSet *entryImageArray;
@property (strong, nonatomic)NSMutableArray *tableCellProperties;

@end

@implementation CMASingleEntryViewController

#pragma mark - Global Accessing

- (CMAJournal *)journal {
    return [[CMAStorageManager sharedManager] sharedJournal];
}

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavigationBarItems];
    [self initTableSettings];
    [self setEntryImageArray:[self.entry images]];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; // removes empty cells at the end of the list
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.imageCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Initializing

#define kSubtitleCellHeight 55
#define kRightDetailCellHeight 35
#define kImageCollectionIndex 0
#define kWeatherCellTitlePadding 25

// Creates a CMATableCellProperties object for each cell that will be shown on the table.
// Only self.entry properties that were specified by the user are shown.
// Sets self.tableCellProperties property.
- (void)initTableSettings {
    self.tableCellProperties = [NSMutableArray array];
    
    // images
    [self.tableCellProperties addObject:
     [CMATableCellProperties withLabelText: nil
                             andDetailText: nil
                        andReuseIdentifier: @"collectionViewCell"
                                 andHeight: 0
                              hasSeparator: NO]];
    
    // species and date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy 'at' h:mm a"];
    [self.tableCellProperties addObject:
     [CMATableCellProperties withLabelText: self.entry.fishSpecies.name
                             andDetailText: [dateFormatter stringFromDate:self.entry.date]
                        andReuseIdentifier: @"subtitleCell"
                                 andHeight: kSubtitleCellHeight
                              hasSeparator: YES]];
    
    // location
    if (self.entry.location && ![self.entry.location removedFromUserDefines]) {
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Location"
                                 andDetailText: [self.entry locationAsString]
                            andReuseIdentifier: @"locationCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: YES]];
    }
    
    // bait used
    if (self.entry.baitUsed && ![self.entry.baitUsed removedFromUserDefines])
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Bait Used"
                                 andDetailText: self.entry.baitUsed.name
                            andReuseIdentifier: @"baitUsedCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: YES]];
    
    // weather conditions
    if (self.entry.weatherData)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: nil
                                 andDetailText: nil
                            andReuseIdentifier: @"weatherDataCell"
                                     andHeight: kWeatherCellHeightExpanded + kWeatherCellTitlePadding
                                  hasSeparator: YES]];
    
    // length
    if (self.entry.fishLength && [self.entry.fishLength integerValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Length"
                                 andDetailText: [NSString stringWithFormat:@"%@%@", self.entry.fishLength.stringValue, [[self journal] lengthUnitsAsString:YES]]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // weight
    if (self.entry.fishWeight && [self.entry.fishWeight integerValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Weight"
                                 andDetailText: [self.entry weightAsStringWithMeasurementSystem:[[self journal] measurementSystem] shorthand:YES]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // quantity
    if (self.entry.fishQuantity && [self.entry.fishQuantity integerValue] >= 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Quantity"
                                 andDetailText: [self.entry.fishQuantity stringValue]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // fishing methods
    if (self.entry.fishingMethods)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Methods"
                                 andDetailText: [self.entry fishingMethodsAsString]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: YES]];
    
    // water clarity
    if (self.entry.waterClarity)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Clarity"
                                 andDetailText: [self.entry.waterClarity name]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // water depth
    if (self.entry.waterDepth && [self.entry.waterDepth integerValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Depth"
                                 andDetailText: [NSString stringWithFormat:@"%ld%@", (long)[self.entry.waterDepth integerValue], [[self journal] depthUnitsAsString:YES]]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: NO]];
    
    // water temperature
    if (self.entry.waterTemperature && [self.entry.waterTemperature integerValue] > 0)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Water Temperature"
                                 andDetailText: [NSString stringWithFormat:@"%ld%@", (long)[self.entry.waterTemperature integerValue], [[self journal] temperatureUnitsAsString:YES]]
                            andReuseIdentifier: @"rightDetailCell"
                                     andHeight: kRightDetailCellHeight
                                  hasSeparator: YES]];
    
    // notes
    if (self.entry.notes)
        [self.tableCellProperties addObject:
         [CMATableCellProperties withLabelText: @"Notes"
                                 andDetailText: self.entry.notes
                            andReuseIdentifier: @"subtitleCell"
                                     andHeight: kSubtitleCellHeight
                                  hasSeparator: NO]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMATableCellProperties *properties = [self.tableCellProperties objectAtIndex:indexPath.row];
    
    if (indexPath.item == kImageCollectionIndex) {
        if ([self.entry imageCount] > 0)
            return self.tableView.frame.size.width;
        else
            return 0;
    }
    
    // Notes cell; need to get the occupied space from the notes string
    if ([properties.labelText isEqualToString:@"Notes"]) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:GLOBAL_FONT size:15]};
        CGRect rect = [self.entry.notes boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:attributes
                                                     context:nil];
        return rect.size.height + 40; // + 40 for the "Notes" title
    }
    
    return [[self.tableCellProperties objectAtIndex:indexPath.item] height];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableCellProperties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMATableCellProperties *p = [self.tableCellProperties objectAtIndex:indexPath.item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:p.reuseIdentifier];
    
    // images collection view
    if (indexPath.item == kImageCollectionIndex) {
        self.imageCollectionView = (UICollectionView *)[cell viewWithTag:100];
        return cell;
    }
    
    // weather data cell
    if ([p.reuseIdentifier isEqualToString:@"weatherDataCell"]) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CMAWeatherDataView" owner:self options:nil];
        CMAWeatherDataView *view = (CMAWeatherDataView *)[nib objectAtIndex:0];
        [view setFrame:CGRectMake(0, kWeatherCellTitlePadding, 0, kWeatherCellHeightExpanded)];
        [view setBackgroundColor:[UIColor redColor]];
        
        [view.weatherImageView setImage:self.entry.weatherData.weatherImage];
        [view.temperatureLabel setText:[self.entry.weatherData temperatureAsStringWithUnits:[[self journal] temperatureUnitsAsString:YES]]];
        [view.windSpeedLabel setText:[self.entry.weatherData windSpeedAsStringWithUnits:[[self journal] speedUnitsAsString:YES]]];
        [view.skyConditionsLabel setText:[self.entry.weatherData skyConditionsAsString]];
        
        [cell addSubview:view];
    } else {    
        cell.textLabel.text = p.labelText;
        cell.detailTextLabel.text = p.detailText;
    }
    
    // add separator to required cells
    if ((p.hasSeparator && !(indexPath.item == [self.tableCellProperties count] - 1)) || // if property has a separator AND the index path isn't the last
        
        // OR the indexPath isn't the last AND the next property contains "Water" OR "Notes"
        (!(indexPath.item == [self.tableCellProperties count] - 1) &&
        (([[[self.tableCellProperties objectAtIndex:indexPath.row + 1] labelText] containsString:@"Water"] && ![[[self.tableCellProperties objectAtIndex:indexPath.row] labelText] containsString:@"Water"]) ||
        [[[self.tableCellProperties objectAtIndex:indexPath.row + 1] labelText] isEqualToString:@"Notes"])))
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, p.height - 0.5, self.view.frame.size.width - 15, 0.5)];
        [line setBackgroundColor:[UIColor colorWithWhite:0.80 alpha:1.0]];
        [cell addSubview:line];
    } else {
        // needed for proper rendering after an unwind from Add Entry Scene
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, p.height - 0.5, self.view.frame.size.width - 15, 0.5)];
        [line setBackgroundColor:[UIColor whiteColor]];
        [cell addSubview:line];
    }
    
    return cell;
}

#pragma mark - Images Views

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.entry imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCollectionCell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    [imageView setImage:[self.entryImageArray objectAtIndex:indexPath.item]];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout: (UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize;
    
    cellSize.width = collectionView.frame.size.width;
    cellSize.height = collectionView.frame.size.height;
    
    return cellSize;
}

#pragma mark - Events

- (void)clickActionButton {
    [self shareEntry];
}

- (void)clickEditButton {
    [self performSegueWithIdentifier:@"fromSingleEntryToAddEntry" sender:self];
}

#pragma mark - Sharing

- (void)shareEntry {
    NSMutableArray *shareItems = [NSMutableArray array];
    
    [shareItems addObjectsFromArray:(NSArray *)self.entryImageArray];
    [shareItems addObject:[[[NSDateFormatter alloc] init] stringFromDate:self.entry.date]];
    [shareItems addObject:[NSString stringWithFormat:@"Length: %@", [self.entry.fishLength stringValue]]];
    [shareItems addObject:[NSString stringWithFormat:@"Weight: %@", [self.entry.fishLength stringValue]]];
    [shareItems addObject:SHARE_MESSAGE];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    activityController.popoverPresentationController.sourceView = self.view;
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeAddToReadingList];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)initNavigationBarItems {
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickActionButton)];
    self.editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(clickEditButton)];
    
    self.navigationItem.rightBarButtonItems = @[self.editButton, self.actionButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromSingleEntryToAddEntry"]) {
        CMAAddEntryViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleEntry;
        destination.entry = self.entry;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleEntryToSingleLocation"]) {
        CMASingleLocationViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.previousViewID = CMAViewControllerIDSingleEntry;
        destination.location = self.entry.location;
        destination.fishingSpotFromSingleEntry = self.entry.fishingSpot;
        destination.navigationItem.title = destination.location.name;
    }
    
    if ([segue.identifier isEqualToString:@"fromSingleEntryToSingleBait"]) {
        CMASingleBaitViewController *destination = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        destination.bait = self.entry.baitUsed;
        destination.isReadOnly = YES;
    }
}

- (IBAction)unwindToSingleEntry:(UIStoryboardSegue *)segue {
    // set the detail label text after selecting an option from the Edit Settings view
    if ([segue.identifier isEqualToString:@"unwindToSingleEntryFromAddEntry"]) {
        CMAAddEntryViewController *source = segue.sourceViewController;
        [self setEntry:source.entry];
        [self setEntryImageArray:[self.entry images]];
        
        [self initTableSettings];
        
        source.entry = nil;
    }
}

@end
