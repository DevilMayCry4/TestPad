//
//  UDPManager.m
//  TestPad
//
//  Created by virgil on 12-12-10.
//  Copyright (c) 2012年 USER. All rights reserved.
//

#import "UDPManager.h"
#import "AsyncUdpSocket.h"
#import "LocalIp.h"
#define kServerGroupIP   @"225.0.0.0"
#define kServerGroupPort  11521
#define kRealServerPort   11512
#define CommandType       @"CommanType"
#define TypeAskServerIP     0
#define TypeAnswerServerIP 1
#define AskServerIP       @"AskServerIP"
#define AnswerServerIP    @"AnswerServerIP"
#define InfoKey           @"InfoKey"
#define biginIP           @"225.0.0."   
@implementation UDPManager


static  UDPManager *_manager = nil;

+ (id)manager
{
    if (!_manager)
    {
        _manager = [[UDPManager alloc] init];
        
    }
    return _manager;
}


+ (void)releaseManager
{
    [_manager release];
    _manager = nil;
}


- (void)startAsServers:(BOOL)servers delegate:(id<UDPManagereDelegate>)delegate
{
    _delegate = delegate;
    _servers = servers;
    _serverIPArray = [[NSMutableArray alloc] init];
    _aviableIPArray = [[NSMutableArray alloc] init];
    
    for (NSInteger count = 1;  count< 256; count++)
    {
        [_aviableIPArray addObject:[biginIP stringByAppendingFormat:@"%d",count]];
    }

    _serverGroupUDP = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    if([_serverGroupUDP bindToPort:kServerGroupPort  error:&error])
    {
        [_serverGroupUDP enableBroadcast:YES error:nil];
        [_serverGroupUDP joinMulticastGroup:kServerGroupIP error:nil];
        [_serverGroupUDP receiveWithTimeout:-1 tag:0];
        [self sendCommand:TypeAskServerIP info:[NSNull null] socket:_serverGroupUDP];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self
                                       selector:servers?@selector(createRealGroup):@selector(returnServerIP)
                                       userInfo:nil
                                        repeats:NO];
         NSLog(@"start group udp success");
    }
    else
    {
        NSLog(@"start group udp fail ");
        if ([_delegate respondsToSelector:@selector(failToStartUDP:)])
        {
            [_delegate failToStartUDP:error];
        }
    }
}


- (void)createRealGroup
{
    _serverRealUDP = [[AsyncUdpSocket alloc] initWithDelegate:self];
     NSError *error = nil;
    if([_serverRealUDP bindToPort:kRealServerPort  error:&error])
    {
        [_serverRealUDP enableBroadcast:YES error:nil];
        [_serverRealUDP joinMulticastGroup:[_aviableIPArray objectAtIndex:0] error:nil];
        [_serverRealUDP receiveWithTimeout:-1 tag:0];
        if ([_delegate respondsToSelector:@selector(serversFinshStart)])
        {
            [_delegate serversFinshStart];
        }
        NSLog(@"start real udp success");
    }
    else
    {
        [_serverGroupUDP close];
        if ([_delegate respondsToSelector:@selector(failToStartUDP:)])
        {
            [_delegate failToStartUDP:error];
        }
        NSLog(@"start real udp fail ");
    }
}

- (void)returnServerIP
{
    if ([_delegate respondsToSelector:@selector(clientFinishGetIP:)])
    {
        [_delegate clientFinishGetIP:_serverIPArray];
    }
}


- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    if (![[LocalIp  deviceIPAdress] isEqualToString:host])
    {
        if(!_collectData)
        {
            NSRange range ;
            range.length = sizeof(NSUInteger);
            range.location = 0;
            NSData *suData = [data subdataWithRange:range];
            [suData getBytes:&_dataLength length:sizeof(NSUInteger)];
            range.location = sizeof(NSUInteger);
            range.length = data.length - sizeof(NSUInteger);
            if(_dataLength == data.length )
            {
                [self dealWith:[data subdataWithRange:range] socket:sock];
            }
            else
            {
                _collectData = [[NSMutableData alloc] init];
                [_collectData appendData:[data subdataWithRange:range]];
            }
        }
        else
        {
            [_collectData appendData:data];
            if(_dataLength == _collectData.length + sizeof(NSUInteger))
            {
                [self dealWith:_collectData socket:sock];
            }
            
        }
       
    }
    [sock receiveWithTimeout:-1 tag:1];
    return YES;
}


- (void)dealWith:(NSData *)data socket:(AsyncUdpSocket *)socket
{
    id  dictinary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([dictinary isKindOfClass:[NSDictionary class]])
    {
        NSInteger  type = [[dictinary objectForKey:CommandType] intValue];
        switch (type)
        {
            {
            case  TypeAskServerIP:
                  [self sendCommand:TypeAnswerServerIP info:[_aviableIPArray objectAtIndex:0] socket:socket];
            break;
            }
                
            {
             case TypeAnswerServerIP:
                  NSLog(@"ip  %@",[dictinary objectForKey:InfoKey]);
                  [_aviableIPArray removeObject:[dictinary objectForKey:InfoKey]];
                  [_serverIPArray addObject:[dictinary objectForKey:InfoKey]];
             break;
            }
                
            default:
                break;
        }
        
    }
    _dataLength = 0;
    [_collectData  release]; 
    _collectData = nil;
}


- (void)sendCommand:(NSInteger)type info:(id)info socket:(AsyncUdpSocket *)socket
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:info,InfoKey,[NSNumber numberWithInt:type],CommandType,nil];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    NSUInteger dataLength = [data length] + sizeof(NSUInteger);
    NSLog(@"data length %d",dataLength);
    NSData *subData = [[NSData alloc] initWithBytes:&dataLength length:sizeof(NSUInteger)];
    NSMutableData *mData = [[[NSMutableData alloc] initWithData:subData] autorelease];
    [mData appendData:data];
    if (socket == _serverGroupUDP)
    {
        [socket sendData:mData toHost:kServerGroupIP port:kServerGroupPort withTimeout:-1 tag:1];
    }
    else
    {
        [socket sendData:mData toHost:[_aviableIPArray objectAtIndex:0] port:kRealServerPort withTimeout:-1 tag:1];
    }
}


- (void)closeUDP
{
    [_serverGroupUDP close];
    [_serverRealUDP close];
}
@end
