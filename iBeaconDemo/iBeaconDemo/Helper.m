//
//  Helper.m
//  iBeaconDemo
//
//  Created by ChenTong on 2017/5/31.
//  Copyright © 2017年 ctinus. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+(instancetype)helper
{
    __block Helper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[Helper alloc] init];
    });
    return helper;
}

-(NSUUID *)uuid
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    return uuid;
}
@end
