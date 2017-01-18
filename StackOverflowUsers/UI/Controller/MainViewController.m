//
//  MainViewController.m
//  StackOverflowUsers
//
//  Created by Artur Felipe on 1/18/17.
//  Copyright © 2017 Artur Felipe. All rights reserved.
//

#import "MainViewController.h"
#import "ListUsersCommand.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>{
    
}

@property NSMutableArray *objects;

@property (weak, nonatomic) IBOutlet UITableView *tableViewSearchResult;

@property (strong, nonatomic) UIActivityIndicatorView *activityindicator;

@end

@implementation MainViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadServerData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActivityIndicator{
    _activityindicator = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [_activityindicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityindicator setColor:[UIColor blackColor]];
    [self.view addSubview:_activityindicator];
    [_activityindicator startAnimating];
}

- (void)hideActivityIndicator{
    [_activityindicator stopAnimating];
}

- (void)loadServerData{
    [self showActivityIndicator];
    
    [[ListUsersCommand sharedInstance] listUsersWithBlock:^(NSDictionary *result, NSError *error) {
        [self hideActivityIndicator];
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        } else {
            self.objects = [[result objectForKey:@"result"] mutableCopy];
            
            [self.tableViewSearchResult reloadData];
        }
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultcell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDictionary *aDict = self.objects[indexPath.row];
    
    UIImageView *profileImageView = [cell.contentView viewWithTag:1];
    [profileImageView setImageWithURL:[NSURL URLWithString:[aDict objectForKey:@"profile_image"]]
                     placeholderImage:[UIImage imageNamed:@"Placeholder"]
                              options:SDWebImageRefreshCached
          usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UILabel *nameLabel = [cell.contentView viewWithTag:2];
    nameLabel.text = [aDict objectForKey:@"display_name"];
    
    UILabel *reputationLabel = [cell.contentView viewWithTag:3];
    reputationLabel.text = [NSString stringWithFormat:@"Reputation: %@", [aDict objectForKey:@"reputation"]];
    
    UILabel *badgeLabel = [cell.contentView viewWithTag:4];
    badgeLabel.text = [NSString stringWithFormat:@"Badges G: %@, S: %@, B: %@", [[aDict objectForKey:@"badge_counts"] objectForKey:@"gold"], [[aDict objectForKey:@"badge_counts"] objectForKey:@"silver"], [[aDict objectForKey:@"badge_counts"] objectForKey:@"bronze"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];        
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {    
    return NO;
}

@end
