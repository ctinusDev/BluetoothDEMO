//
//  Helper.h
//  iBeaconDemo
//
//  Created by ChenTong on 2017/5/31.
//  Copyright © 2017年 ctinus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MY_REGION_IDENTIFIER @"com.example.apple-samplecode.AirLocate"
@interface Helper : NSObject

+(instancetype)helper;

@property (strong, nonatomic) NSUUID *uuid;
@end
