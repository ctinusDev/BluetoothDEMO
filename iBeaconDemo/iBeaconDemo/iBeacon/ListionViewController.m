//
//  ListionViewController.m
//  iBeaconDemo
//
//  Created by ChenTong on 2017/5/31.
//  Copyright © 2017年 ctinus. All rights reserved.
//

#import "ListionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Helper.h"

@interface ListionViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLBeaconRegion *_region;
    NSArray *_detectedBeacons;
}
@end

@implementation ListionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self turnOnBeacon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Beacons Methods
- (void) turnOnBeacon{
    [self initLocationManager];
    [self initBeaconRegion];
    [self initDetectedBeaconsList];
    [self startBeaconRanging];
}
#pragma mark Init Beacons
- (void) initLocationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        [self checkLocationAccessForRanging];
    }
}

- (void) initDetectedBeaconsList{
    if (!_detectedBeacons) {
        _detectedBeacons = [NSArray array];
    }
}

- (void) initBeaconRegion{
    if (_region)
        return;
    
    NSUUID *uuid = [[Helper helper] uuid];
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:10001 minor:19641 identifier:MY_REGION_IDENTIFIER];
    NSAssert(_region, nil);
    _region.notifyEntryStateOnDisplay = YES;
    _region.notifyOnEntry = YES;
    _region.notifyOnExit = YES;
}

#pragma mark Beacons Ranging

- (void) startBeaconRanging{
    if (!_locationManager || !_region) {
        return;
    }
    if (_locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [_locationManager startMonitoringForRegion:_region]; //需要开启后台应用刷新才能使用
    [_locationManager startRangingBeaconsInRegion:_region];
}

- (void) stopBeaconRanging{
    NSLog(@"%s, line = %d",__FUNCTION__, __LINE__);
    if (!_locationManager || !_region) {
        return;
    }
    [_locationManager stopRangingBeaconsInRegion:_region];
    [_locationManager stopMonitoringForRegion:_region];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s, line = %d",__FUNCTION__, __LINE__);
    [_locationManager startRangingBeaconsInRegion:_region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region
{
    NSLog(@"%s, line = %d",__FUNCTION__, __LINE__);
    [_locationManager stopMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

//Location manager delegate method
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    if (beacons.count == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        _detectedBeacons = beacons;
        NSLog(@"beacons count:%zd", beacons.count);
        
        for (CLBeacon *beacon in beacons) {
            NSLog(@"%@", [self detailsStringForBeacon:beacon]);
        }
    }
}

#pragma mark Process Beacon Information
//将beacon的信息转换为NSString并返回
- (NSString *)detailsStringForBeacon:(CLBeacon *)beacon
{
    
    NSString *format = @"%@ • %@ • %@ • %@ • %f • %li";
    return [NSString stringWithFormat:format,beacon.proximityUUID, beacon.major, beacon.minor, [self stringForProximity:beacon.proximity], beacon.accuracy, beacon.rssi];
}

- (NSString *)stringForProximity:(CLProximity)proximity{
    NSString *proximityValue;
    switch (proximity) {
        case CLProximityNear:
            proximityValue = @"Near";
            break;
        case CLProximityImmediate:
            proximityValue = @"Immediate";
            break;
        case CLProximityFar:
            proximityValue = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityValue = @"Unknown";
            break;
    }
    return proximityValue;
}

- (void)checkLocationAccessForRanging {
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
}

@end
