//
//  ViewController.m
//  TestPad
//
//  Created by virgil on 12-12-6.
//  Copyright (c) 2012年 USER. All rights reserved.
//

#import "ViewController.h"
#import "ServerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *serverButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [serverButton setTitle:@"Server" forState:UIControlStateNormal];
    [serverButton addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    [serverButton setFrame:CGRectMake((self.view.frame.size.width - 100)/2, self.view.frame.size.height/3 - 40, 100, 40)];
    [self.view addSubview:serverButton];
    serverButton.tag = 1;
    
    UIButton *clientButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clientButton setTitle:@"Client" forState:UIControlStateNormal];
    [clientButton addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    [clientButton setFrame:CGRectMake((self.view.frame.size.width - 100)/2, self.view.frame.size.height/2 - 40, 100 , 40)];
    [self.view addSubview:clientButton];
    clientButton.tag = 2;
    
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)pressButton:(id)sender
{
    NSString *classString = [sender tag] == 1? @"ServerViewController":@"ClientViewController";
    UIViewController *controller = [[NSClassFromString(classString) alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
