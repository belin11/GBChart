//
//  GBRadarChartDataItem.h
//  GBChartDemo
//
//  Created by midas on 2018/12/11.
//  Copyright © 2018 Midas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface GBRadarChartDataItem : NSObject

+ (instancetype)dataItemWithValue:(CGFloat)value description:(NSString *)description;

@property (nonatomic, assign) CGFloat value;

@property (nonatomic, strong) NSString *textDescription;

@end
