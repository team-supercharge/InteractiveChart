//
//  InteractiveChartView.h
//  InteractiveChart
//
//  Created by Csaba Vidó on 2017. 09. 25..
//  Copyright © 2017. Csaba Vidó. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionItem;

IB_DESIGNABLE
@interface InteractiveChartView : UIView

@property (nonatomic, assign) CGFloat targetAmount;
@property (nonatomic, assign) CGFloat initialAmount;
@property (nonatomic, assign) CGFloat estimatedAmount;
@property (nonatomic, assign) CGFloat depoistAmount;
@property (nonatomic, assign) NSUInteger daysBetweenDeposit;
@property (nonatomic, assign) CGFloat requiredDepoistAmount;

@property (nonatomic, strong) NSDate *targetDate;
@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSArray<TransactionItem *> *values;
@property (nonatomic, strong) IBInspectable UIColor *mainColor;

- (void)setMainColorTo:(UIColor *)color;
- (void)drawChart;

@end
