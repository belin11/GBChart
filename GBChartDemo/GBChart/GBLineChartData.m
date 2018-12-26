//
//  GBLineChartData.m
//  GBChartDemo
//
//  Created by midas on 2018/12/21.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBLineChartData.h"

@implementation GBLineChartDataItem

+ (id)dataItemWithY:(CGFloat)Y {
    
    GBLineChartDataItem *item = [[GBLineChartDataItem alloc] init];
    item.y = Y;
    return item;
}

@end

@implementation GBLineChartData

@end
