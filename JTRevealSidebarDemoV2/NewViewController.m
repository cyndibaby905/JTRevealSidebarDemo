//
//  NewViewController.m
//  JTRevealSidebarDemo
//
//  Created by James Apple Tang on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewViewController.h"
#import "UINavigationItem+JTRevealSidebarV2.h"
#import "UIViewController+JTRevealSidebarV2.h"
#import "JTRevealSidebarV2Delegate.h"

@interface NewViewController () <JTRevealSidebarV2Delegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation NewViewController
@synthesize label;
@synthesize rightSidebarView;
#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 290, 30)];
    [self.view addSubview:self.label];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(revealRightSidebar:)];
    
    self.navigationItem.revealSidebarDelegate = self;
    
    UIPanGestureRecognizer *panRightSideBar = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRightSideBar:)];
    [self.view addGestureRecognizer:panRightSideBar];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark Action

- (void)revealRightSidebar:(id)sender {
    JTRevealedState state = JTRevealedStateRight;
    if (self.navigationController.revealedState == JTRevealedStateRight) {
        state = JTRevealedStateNo;
    }
    [self.navigationController setRevealedState:state];
}

- (void)panRightSideBar:(UIPanGestureRecognizer*)panGes {
    UIView *revealedView = [self viewForRightSidebar];
    
    revealedView.tag = RIGHT_SIDEBAR_VIEW_TAG;
    if (![self.navigationController.view.superview viewWithTag:RIGHT_SIDEBAR_VIEW_TAG]) {
        [self.navigationController.view.superview insertSubview:revealedView belowSubview:self.navigationController.view];
        
    }
    CGFloat width = CGRectGetWidth(revealedView.frame);
    CGPoint translate = [panGes translationInView:self.navigationController.view];
    CGRect frame = self.navigationController.view.frame;
    
    
    CGFloat offsetX = translate.x;
    if (self.navigationController.revealedState == JTRevealedStateRight) {
        offsetX = -width + translate.x;

    }
    
    
    
    if (offsetX <= -width) {
        offsetX = -width;
    }
    else if(offsetX >= 0) {
        offsetX = 0;
    }
    
    
    
    
    
    frame.origin.x = offsetX;
    self.navigationController.view.frame = frame;
    
    if (panGes.state == UIGestureRecognizerStateEnded) {
        [self revealRightSidebar:nil];
    }
    else if (panGes.state == UIGestureRecognizerStateCancelled) {
        [self revealRightSidebar:nil];
    }

}


#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ( ! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.rightSidebarView) {
        return @"RightSidebar";
    }
    return nil;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController setRevealedState:JTRevealedStateNo];
    if (tableView == self.rightSidebarView) {
        self.label.text = [NSString stringWithFormat:@"Selected %d at RightSidebarView", indexPath.row];
    }
}


#pragma mark JTRevealSidebarV2Delegate

- (UIView *)viewForRightSidebar {
    CGRect mainFrame = [[UIScreen mainScreen] applicationFrame];
    UITableView *view = self.rightSidebarView;
    if ( ! view) {
        view = self.rightSidebarView = [[UITableView alloc] initWithFrame:CGRectMake(160, mainFrame.origin.y, 160, mainFrame.size.height) style:UITableViewStyleGrouped];
        view.dataSource = self;
        view.delegate   = self;
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return view;
}

@end
