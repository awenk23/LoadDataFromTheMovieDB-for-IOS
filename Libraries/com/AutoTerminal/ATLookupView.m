//
//  ATLookupView.m
//  AEMC
//
//  Created by i'Mac on 12/19/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "ATLookupView.h"

@interface ATLookupView () <UITableViewDelegate, NSFetchedResultsControllerDelegate>

@end

@implementation ATLookupView

#pragma mark - View Delegates
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Force to be visible. UISearchBar will put a table ontop of everything else
    self.navView.layer.zPosition = 500;
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if (![self.facade hasMediator:self.mediatorName]) {
        [self.facade registerMediator:self];
    }
    
    [self.searchDisplayController setActive:NO animated:YES];
    [self setSelectedItem:nil];
    [self performFetch];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)viewDidUnload {
    
    [self setSelectedItem:nil];
    [self setNavItem:nil];
    [super viewDidUnload];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    self.fetchedData.delegate = nil;
    self.fetchedData = nil;
    [self.facade removeMediator:self.mediatorName];
    [super viewWillDisappear:animated];
    
}

#pragma mark - Table delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Pop back to the parent view
    //[self.navigationController popViewControllerAnimated:YES];
    
    self.selectedItem = [self.fetchedData objectAtIndexPath:indexPath];
    [self resignView];
    
}

#pragma mark - Button delegates
- (IBAction)refreshButtonTapped:(id)sender {

    [self performRefresh];

}

- (IBAction)cancelButtonTapped:(id)sender {
    
    [self resignView];

}

#pragma mark - Public methods
-(void) didFetch:(NSFetchedResultsController *)fetchedData {
    
    [super didFetch:fetchedData];
    
    self.fetchedData = fetchedData;
    self.fetchedData.delegate = self;
    [self.tableView reloadData];
    
    if  (self.fetchedData.fetchedObjects.count == 0) {
        [self performRefresh];
    }
    
}

-(void) didRefresh {
    if (self.popupView) [self.popupView remove];
}

#pragma mark - Private methods
-(void) performRefresh {
    
    // if loading in progress, do nothing
    if (self.popupView.isRunning) return;
    
    // display loading message
    
    CGPoint center = self.view.center;
    center.y += 10;
    self.popupView = [[ATPopupView alloc] initWithCenter:center text:@"Loading ..."];
    [self.view addSubview:self.popupView];
    
    
    // fetch remotely
    // implement this in the subclass
    
}

-(void) performFetch {}

-(void) resignView {}

@end
