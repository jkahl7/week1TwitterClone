//
//  HotelViewController.m
//  MotelTonight
//
//  Created by Josh Kahl on 2/9/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

#import "HotelViewController.h"
#import "AppDelegate.h"
#import "Hotel.h"
#import "RoomViewController.h"

@interface HotelViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *hotels;

@end

@implementation HotelViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.dataSource = self;
  self.tableView.delegate   = self;
  
  //need to grab a refrence to the AppDelegate - a shared instance
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  // grab a refrence to the contextManager in appDelegate
  NSManagedObjectContext *context = appDelegate.managedObjectContext;
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Hotel"];
  
  NSError *fetchError;
  
  NSArray *results = [context executeFetchRequest:fetchRequest error: &fetchError];
  
  if (!fetchError)
  {
    self.hotels = results;
    [self.tableView reloadData];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.hotels.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
  
  Hotel *hotel = self.hotels[indexPath.row];
  
  cell.textLabel.text = hotel.name;
  
  return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
  RoomViewController *toVC = [[RoomViewController alloc] init];
  
  toVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RoomVC"];
 
  Hotel *hotel = self.hotels[indexPath.row];
  
  NSArray *roomArray = hotel.rooms.allObjects;
  
  toVC.rooms = roomArray;

  [self.navigationController pushViewController:toVC animated:true];
  
}


@end
