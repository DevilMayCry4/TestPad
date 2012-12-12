//
//  ClientViewController.m
//  TestPad
//
//  Created by virgil on 12-12-10.
//  Copyright (c) 2012年 USER. All rights reserved.
//

#import "ClientViewController.h"
#import "AsyncUdpSocket.h"
#import "CodeText.h"
#import "LocalIp.h"
#import "UDPManager.h"
@interface ClientViewController ()

@end

@implementation ClientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_startButton setTitle:@"start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(startPress) forControlEvents:UIControlEventTouchUpInside];
    [_startButton setFrame:CGRectMake((self.view.frame.size.width - 100)/2, self.view.frame.size.height/3 - 40, 100, 40)];
    [self.view addSubview:_startButton];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = _startButton.center;
    _activityView.hidden = YES;
    [self.view addSubview:_activityView];
    [_activityView release];
    
 
}


- (void)startPress
{
    [[UDPManager manager] startAsServers:NO delegate:self];
    _startButton.hidden = YES;
    _activityView.hidden = NO;
    [_activityView startAnimating];
}


- (void )failToStartUDP:(NSError *)error
{
    _startButton.hidden = NO;
    _activityView.hidden = YES;
    [_activityView stopAnimating];
    NSLog(@"error %@",[error localizedDescription]);
}


- (void)clientFinishGetIP:(NSArray *)array
{
    _startButton.hidden = NO;
    _activityView.hidden = YES;
    [_activityView stopAnimating];
    for (id object  in array)
    {
        NSLog(@"array  object %@",object);
    }
}

- (void)serversFinshStart
{
    _startButton.hidden = NO;
    _activityView.hidden = YES;
    [_activityView stopAnimating];
    NSLog(@"ok");
}

- (void)dealloc
{
    [[UDPManager manager] closeUDP];
    [super dealloc];
}
@end
