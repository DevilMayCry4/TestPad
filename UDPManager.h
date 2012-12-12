//
//  UDPManager.h
//  TestPad
//
//  Created by virgil on 12-12-10.
//  Copyright (c) 2012年 USER. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AsyncUdpSocket;

@protocol UDPManagereDelegate <NSObject>
 
- (void )failToStartUDP:(NSError *)error;
- (void)clientFinishGetIP:(NSArray *)array;
- (void)serversFinshStart;

@end

@interface UDPManager : NSObject
{
    AsyncUdpSocket     *_serverGroupUDP;
    AsyncUdpSocket     *_serverRealUDP;
    id                  _delegate;
    NSMutableData      *_collectData;
    NSUInteger          _dataLength;
    NSMutableArray     *_aviableIPArray;
    NSMutableArray     *_serverIPArray;
    BOOL                _servers;
}

+ (id)manager;

+ (void)releaseManager;

- (void)startAsServers:(BOOL)servers delegate:(id)delegate;

- (void)closeUDP;

 
@end

