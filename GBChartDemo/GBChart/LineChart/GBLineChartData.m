//
//  GBLineChartData.m
//  GBChartDemo
//
//  Created by midas on 2018/12/21.
//  Copyright © 2018 Midas. All rights reserved.
//

#import "GBLineChartData.h"

@implementation GBLineChartDataItem

+ (id)dataItemWithY:(CGFloat)Y X:(CGFloat)X {
    
    GBLineChartDataItem *item = [[GBLineChartDataItem alloc] init];
    item.y = Y;
    item.x = X;
    return item;
}

@end

@implementation GBLineChartData

@end
