//
//  ClientViewController.h
//  TestPad
//
//  Created by virgil on 12-12-10.
//  Copyright (c) 2012年 USER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncUdpSocket;

@interface ClientViewController : UIViewController
{
    UIButton                *_startButton;
    UIActivityIndicatorView *_activityView;
    NSMutableArray          *_ipArray;
    AsyncUdpSocket          *_udpSocket;
    AsyncUdpSocket          *_realGroup;
    NSMutableData           *_collectData;
    NSUInteger               _dataLength;
}

@end
