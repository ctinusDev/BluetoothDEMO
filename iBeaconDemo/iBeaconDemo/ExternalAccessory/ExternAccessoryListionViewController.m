//
//  ExternAccessoryListionViewController.m
//  iBeaconDemo
//
//  Created by ctinus on 2017/12/26.
//  Copyright © 2017年 ctinus. All rights reserved.
//

#import "ExternAccessoryListionViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>

static NSString *kSPKLightingHeadphoneProtocolString = @"com.ld77.bluetooth";
@interface ExternAccessoryListionViewController ()<NSStreamDelegate>
@property (strong , nonatomic) EASession *session;
@property (strong, nonatomic) EAAccessory *accessory;

@end

@implementation ExternAccessoryListionViewController{
    uint8_t *writeData;
    uint8_t *readData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 注册通告
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    // 监听EAAccessoryDidConnectNotification通告（有硬件连接就会回调Block）
    [[NSNotificationCenter defaultCenter] addObserverForName:EAAccessoryDidConnectNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
                                                      // 从已经连接的外设中查找我们的设备(根据协议名称来查找)
                                                      [self searchOurAccessory];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:EAAccessoryDidDisconnectNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      // Do something what you want
                                                  }];
}

// 从已经连接的外设中查找我们的设备(根据协议名称来查找)
- (void)searchOurAccessory {
    NSMutableString *info = [[NSMutableString alloc] init];
    
    // search our device
    for (EAAccessory *accessory in [EAAccessoryManager sharedAccessoryManager].connectedAccessories) {
        
        if ([kSPKLightingHeadphoneProtocolString isEqualToString:[accessory.protocolStrings firstObject]] == YES) {
            
            // 硬件的协议字符串和硬件厂商提供的一致，这个就是我们要找的设备了！
            self.accessory = accessory;
            // log：可以打印一下该硬件的相关资讯
            for (NSString *proStr in accessory.protocolStrings) {
                [info appendFormat:@"protocolString = %@\n", proStr];
            }
            [info appendFormat:@"\n"];
            [info appendFormat:@"manufacturer = %@\n", accessory.manufacturer];
            [info appendFormat:@"name = %@\n", accessory.name];
            [info appendFormat:@"modelNumber = %@\n", accessory.modelNumber];
            [info appendFormat:@"serialNumber = %@\n", accessory.serialNumber];
            [info appendFormat:@"firmwareRevision = %@\n", accessory.firmwareRevision];
            [info appendFormat:@"hardwareRevision = %@\n", accessory.hardwareRevision];
            
            // Log...
            
            break;
        }
    }
}

- (BOOL)openSession {
    // 根据已经连接的EAAccessory对象和这个协议（反向域名字符串）来创建EASession对象，并打开输入、输出通道
    self.session = [[EASession alloc] initWithAccessory:self.accessory forProtocol: kSPKLightingHeadphoneProtocolString];
    if(self.session != nil) {
        // open input stream
        self.session.inputStream.delegate = self;
        [self.session.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [self.session.inputStream open];
        
        // open output stream
        self.session.outputStream.delegate = self;
        [self.session.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [self.session.outputStream open];
    }
    else {
        NSLog(@"Failed to create session");
    }
    
    return (nil != self.session);
}

// delegate回调的方法
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            //NSLog(@"Input stream is ready");
            // 接收到硬件数据了，根据指令定义对数据进行解析。
#define SPK_INPUT_DATA_BUFFER_LEN 1024
            [self.session.inputStream read:readData maxLength:SPK_INPUT_DATA_BUFFER_LEN];
            break;
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"Output stream is ready");
            // 可以发送数据给硬件了
#define SPK_OUTPUT_DATA_BUFFER_LEN 1024
            [self.session.outputStream write:writeData maxLength:SPK_OUTPUT_DATA_BUFFER_LEN];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
