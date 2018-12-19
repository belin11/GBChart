//
//  GBRadarChartDataItem.m
//  GBChartDemo
//
//  Created by midas on 2018/12/11.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBRadarChartDataItem.h"

@implementation GBRadarChartDataItem

+ (instancetype)dataItemWithValue:(CGFloat)value description:(NSString *)description {
    
    GBRadarChartDataItem *item = [[GBRadarChartDataItem alloc] init];
    item.value = value;
    item.textDescription = description;
    return item;
}

- (void)setValue:(CGFloat)value {
    
    if (value < 0) {
        value = 0;
        NSLog(@"Value value can not be negative");
    }
    _value = value;

}



@end
