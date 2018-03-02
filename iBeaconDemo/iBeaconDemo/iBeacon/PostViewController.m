//
//  PostViewController.m
//  iBeaconDemo
//
//  Created by ChenTong on 2017/5/31.
//  Copyright © 2017年 ctinus. All rights reserved.
//

#import "PostViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Helper.h"


@interface PostViewController ()<CBPeripheralManagerDelegate>
{
    CBPeripheralManager *peripheralManager;
    CLBeaconRegion *region;
    NSNumber *power;
}
@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!peripheralManager)
    {
        peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    else
    {
        peripheralManager.delegate = self;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAdvertisedRegion];
    });
}

- (void)updateAdvertisedRegion
{
    if(peripheralManager.state < CBPeripheralManagerStatePoweredOn)
    {
        NSString *title = NSLocalizedString(@"Bluetooth must be enabled", @"");
        NSString *message = NSLocalizedString(@"To configure your device as a beacon", @"");
        NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Cancel button title in configuration Save Changes");
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        [errorAlert show];
        
        return;
    }
    
    [peripheralManager stopAdvertising];

        // We must construct a CLBeaconRegion that represents the payload we want the device to beacon.
        NSDictionary *peripheralData = nil;
        
        region = [[CLBeaconRegion alloc] initWithProximityUUID:[[Helper helper] uuid] major:10001 minor:19641 identifier:MY_REGION_IDENTIFIER];
        peripheralData = [region peripheralDataWithMeasuredPower:@(-59)];
        
        // The region's peripheral data contains the CoreBluetooth-specific data we need to advertise.
        if(peripheralData)
        {
            [peripheralManager startAdvertising:peripheralData];
        }

}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    if(peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"Broadcasting...");
    }else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        NSLog(@"Stopped");
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    
    if (error) {
         NSLog(@"Failed advertising: %@", error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    peripheralManager.delegate = nil;
    [peripheralManager stopAdvertising];
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
