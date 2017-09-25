//
//  InteractiveChartView.m
//  InteractiveChart
//
//  Created by Csaba Vidó on 2017. 09. 25..
//  Copyright © 2017. Csaba Vidó. All rights reserved.
//

#define eplsion 0.00001

#import "InteractiveChartView.h"
#import "TransactionItem.h"

@interface InteractiveChartView()

@property (nonatomic, assign) BOOL shouldShowStroke;
@property (nonatomic, assign) CGFloat savingBalance;

@end

@implementation InteractiveChartView

#pragma mark - Call this to draw chart
- (void)drawChart
{
    [self layoutIfNeeded];

    [self clearAll];
    [self drawLines];
    [self drawSteps];
    [self drawLegends];
}

#pragma mark - Clear out all view/layer
- (void)clearAll
{
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    UITapGestureRecognizer *mainGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(chartTapped:)];
    [self addGestureRecognizer:mainGesture];
}

- (void)chartTapped:(UIGestureRecognizer *)recognizer
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tapped on chart"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"ok"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action)
    {

    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController
                                                                                 animated:YES
                                                                               completion:nil];
}

#pragma mark - Set main color of the chart
- (void)setMainColorTo:(UIColor *)color;
{
    _mainColor = color;
    [self drawChart];
}

- (CGFloat)requiredDepoistAmount
{
    NSInteger numberOfTotalDays = [self numberOfDaysBetweenDate:self.startDate toDate:_targetDate];
    return ceil((_targetAmount - _initialAmount) / (numberOfTotalDays / _daysBetweenDeposit));
}

#pragma mark - Draw lines
- (void)drawLines
{
    NSInteger numberOfTotalDays = [self numberOfDaysBetweenDate:self.startDate toDate:_targetDate];
    NSInteger numberOfDaysBetweenEstimation = [self numberOfDaysBetweenDate:[NSDate date] toDate:_targetDate];
    self.estimatedAmount = ((numberOfDaysBetweenEstimation / _daysBetweenDeposit) * _depoistAmount) + _initialAmount;

    CGFloat maxValue = self.estimatedAmount >= _targetAmount ? self.estimatedAmount : _targetAmount;
    CGFloat yRatio = CGRectGetMaxY(self.bounds) / maxValue;
    CGFloat xRatio = [self numberOfDaysBetweenDate:self.startDate toDate:[NSDate date]] / (numberOfTotalDays / 100.f);
    CGFloat xPos = CGRectGetMaxX(self.bounds) * (xRatio / 100.0f);

    CAShapeLayer *baseLine = [self drawLineFromPont:CGPointMake(0, CGRectGetMaxY(self.bounds))
                                            toPoint:CGPointMake(CGRectGetMaxX(self.bounds),
                                                                CGRectGetMaxY(self.bounds))
                                              color:_mainColor
                                              width:1.0f
                                              alpha:1.0f];

    CGFloat yPosForInitial = CGRectGetMaxY(self.bounds) - ((_initialAmount) * yRatio);

    CGFloat yPosForVerticalTarget = CGRectGetMaxY(self.bounds) - ((_targetAmount) * yRatio);
    CALayer *targetVerticalLine = [self drawLineFromPont:CGPointMake(CGRectGetMaxX(self.bounds),
                                                                     CGRectGetMaxY(self.bounds))
                                                 toPoint:CGPointMake(CGRectGetMaxX(self.bounds), 0)
                                                   color:_mainColor
                                                   width:1.0f
                                                   alpha:1.0f];

    CAShapeLayer *dottedLine = [self drawLineFromPont:CGPointMake(xPos, yPosForInitial)
                                              toPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPosForVerticalTarget)
                                                color:_mainColor
                                                width:1.0f
                                                alpha:0.6f];
    dottedLine.lineDashPattern = @[@2,@2];
    dottedLine.opacity = _targetAmount == _initialAmount ? 0.0f : 1.0f;


    CALayer *targetLine = [self drawLineFromPont:CGPointMake(0, yPosForVerticalTarget)
                                         toPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPosForVerticalTarget)
                                           color:_mainColor
                                           width:0.8f
                                           alpha:0.3f];

    CGFloat yPosForEstimated = CGRectGetMaxY(self.bounds) - ((self.estimatedAmount) * yRatio);
    CALayer *estimatedLine = [self drawLineFromPont:CGPointMake(0, yPosForEstimated)
                                            toPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPosForEstimated)
                                              color:_mainColor
                                              width:0.8f
                                              alpha:0.3f];

    NSString *estimatedText = @"Estimated";
    UILabel *estimatedLabel = [self drawText:[NSString stringWithFormat:@"%.02f$ %@",self.estimatedAmount, estimatedText]
                                       point:CGPointMake(0, yPosForEstimated)
                                        font:[UIFont systemFontOfSize:10.0f]
                                       color:_mainColor];

    NSString *targetText = @"Target";
    UILabel *targetLabel = [self drawText:[NSString stringWithFormat:@"%.02f$ %@",_targetAmount, targetText]
                                    point:CGPointMake(0, yPosForVerticalTarget)
                                     font:[UIFont systemFontOfSize:10.0f]
                                    color:_mainColor];


    // Check if the labes are to close for eachother)
    if (fabs(yPosForVerticalTarget - yPosForEstimated) <= 10.f)
    {
        if (yPosForEstimated < yPosForVerticalTarget + eplsion)
        {
            targetLabel.layer.anchorPoint = CGPointMake(0, 0);
        }
        else
        {
            estimatedLabel.layer.anchorPoint = CGPointMake(0, 0);
        }
    }

    UILabel *montlyDepositLabel = [self drawText:[NSString stringWithFormat:@"%.02f$",self.requiredDepoistAmount]
                                           point:CGPointMake(CGRectGetMaxX(self.bounds) / 2.0f,
                                                             (yPosForVerticalTarget + yPosForInitial)/2.0f)
                                            font:[UIFont systemFontOfSize:10.0f]
                                           color:_mainColor];

    montlyDepositLabel.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    CGFloat a = yPosForInitial - yPosForVerticalTarget;
    CGFloat b = CGRectGetWidth(self.bounds);
    CGFloat angle = atanf(a / b);
    montlyDepositLabel.transform = CGAffineTransformMakeRotation(-angle);

    estimatedLabel.attributedText =
    [self getAttruibutedStringWithString:estimatedLabel.text
                            withBoldPart:[NSString stringWithFormat:@"%.02f$",self.estimatedAmount]];
    targetLabel.attributedText =
    [self getAttruibutedStringWithString:targetLabel.text
                            withBoldPart:[NSString stringWithFormat:@"%.02f$",_targetAmount]];
    [estimatedLabel sizeToFit];
    [targetLabel sizeToFit];

    // add layers / views
    [self.layer addSublayer:baseLine];
    [self.layer addSublayer:targetVerticalLine];
    [self.layer addSublayer:dottedLine];
    [self.layer addSublayer:targetLine];
    [self.layer addSublayer:estimatedLine];
    [self addSubview:estimatedLabel];
    [self addSubview:targetLabel];
    [self drawEstimatedLabelForStartY:yPosForInitial endY:yPosForVerticalTarget xPos:xPos];


    [self addDotToPoint:CGPointMake(xPos, yPosForInitial) radius:2.5f color:_mainColor alpha:1.0f];
    [self drawMainDotAtPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPosForVerticalTarget)];
}

- (void)drawEstimatedLabelForStartY:(CGFloat)startY endY:(CGFloat)endY xPos:(CGFloat)xPos
{
    UILabel *montlyDepositLabel = [self drawText:[NSString stringWithFormat:@"%.02f$",self.requiredDepoistAmount]
                                           point:CGPointMake((CGRectGetMaxX(self.bounds) + xPos) / 2.0f,
                                                             (endY + startY) / 2.0f)
                                            font:[UIFont systemFontOfSize:10.f]
                                           color:_mainColor];

    montlyDepositLabel.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    CGFloat a = startY - endY;
    CGFloat b = CGRectGetWidth(self.bounds) - xPos;
    CGFloat angle = atanf(a / b);
    montlyDepositLabel.transform = CGAffineTransformMakeRotation(-angle);
    [self addSubview:montlyDepositLabel];
}

#pragma mark - Draw main dot
- (void)drawMainDotAtPoint:(CGPoint)point;
{
    [self addDotToPoint:point radius:7.f color:_mainColor alpha:0.45f];
    [self addDotToPoint:point radius:3.5f color:_mainColor alpha:1.0f];
    [self addDotToPoint:point radius:2.5f color:[UIColor whiteColor] alpha:1.0f];
}

#pragma mark - Draw steps
- (void)drawSteps
{
    NSInteger numberOfTotalDays = [self numberOfDaysBetweenDate:self.startDate toDate:_targetDate];

    CGFloat xRatio = CGRectGetMaxX(self.bounds) / numberOfTotalDays;
    CGFloat maxValue = self.estimatedAmount >= _targetAmount ? self.estimatedAmount : _targetAmount;
    CGFloat yRatio = CGRectGetMaxY(self.bounds) / maxValue;
    CGFloat yPos = CGRectGetMaxY(self.bounds) - ((_initialAmount) * yRatio);

    CGFloat numberOfDays = [self numberOfDaysBetweenDate:self.startDate toDate:[NSDate date]];
    CGFloat scale = [self numberOfDaysBetweenDate:self.startDate toDate:[NSDate date]] / (numberOfTotalDays / 100.f);
    CGFloat xPos = CGRectGetMaxX(self.bounds) * (scale / 100.0f);

    UIBezierPath *graphPath = [UIBezierPath bezierPath];
    [graphPath moveToPoint:CGPointMake(xPos, CGRectGetMaxY(self.bounds))];
    [graphPath addLineToPoint:CGPointMake(xPos, yPos)];

    NSInteger numberOfSteps = (numberOfTotalDays - numberOfDays) / _daysBetweenDeposit;
    for (int i = 0; i < numberOfSteps ; i++)
    {
        xPos += _daysBetweenDeposit * xRatio;

        if (xPos >= CGRectGetMaxX(self.bounds))
        {
            xPos = CGRectGetMaxX(self.bounds);
        }

        [graphPath addLineToPoint:CGPointMake(xPos, yPos)];

        yPos -= _depoistAmount * yRatio;
        [graphPath addLineToPoint:CGPointMake(xPos, yPos)];
    }

    [graphPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), yPos)];
    [graphPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds))];
    [graphPath closePath];

    // Shape fill color
    CAShapeLayer *graphLayer = [CAShapeLayer layer];

    graphLayer.path = [graphPath CGPath];
    graphLayer.fillColor = _mainColor.CGColor;
    graphLayer.shouldRasterize = YES;
    if (_shouldShowStroke)
    {
        graphLayer.strokeColor = [UIColor whiteColor].CGColor;
        graphLayer.lineWidth = 3.0f;
    }
    graphLayer.rasterizationScale = UIScreen.mainScreen.scale;
    graphLayer.opacity = 0.3f;

    [self.layer addSublayer:graphLayer];
    [self drawValues];
}

- (void)drawValues
{
    CGFloat height =  CGRectGetMaxY(self.bounds);
    CGFloat maxValue = self.estimatedAmount >= _targetAmount ? self.estimatedAmount : _targetAmount;
    CGFloat diff = height / maxValue;
    NSInteger numberOfTotalDays = [self numberOfDaysBetweenDate:self.startDate toDate:self.targetDate];
    CGFloat ratio = CGRectGetMaxX(self.bounds) / (float)numberOfTotalDays;

    UIBezierPath *graphPath = [UIBezierPath bezierPath];
    [graphPath moveToPoint:CGPointMake(0, CGRectGetMaxY(self.bounds))];

    self.savingBalance = 0;
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    for (int i = 0; i < _values.count; i++)
    {
        TransactionItem *transaction = _values[i];
        NSInteger daysBetweenItem = [self numberOfDaysBetweenDate:self.startDate toDate:transaction.date];
        xPos = daysBetweenItem * ratio;
        CGFloat balance = (_savingBalance + transaction.amount.floatValue) * diff;
        self.savingBalance +=  transaction.amount.floatValue;

        yPos = CGRectGetHeight(self.bounds) - balance;
        [graphPath addLineToPoint:CGPointMake(xPos, yPos)];
        if (i == 0)
        {
            [self addDotToPoint:CGPointMake(xPos, yPos) radius:2.5f color:_mainColor alpha:1.0f];
        }

        if ( i <  _values.count - 1)
        {
            TransactionItem *nextTransaction = _values[i + 1];
            NSInteger daysBetweenItem = [self numberOfDaysBetweenDate:self.startDate toDate:nextTransaction.date];
            CGFloat dxPos = daysBetweenItem * ratio;
            [graphPath addLineToPoint:CGPointMake(dxPos, yPos)];
        }
    }

    CAShapeLayer *graphLayer = [CAShapeLayer layer];
    graphLayer.path = [graphPath CGPath];
    graphLayer.fillColor = [UIColor clearColor].CGColor;
    graphLayer.strokeColor = _mainColor.CGColor;
    graphLayer.shouldRasterize = YES;
    graphPath.lineWidth = 3.0f;
    graphLayer.rasterizationScale = UIScreen.mainScreen.scale;
    graphLayer.opacity = 1.0f;

    [self.layer addSublayer:graphLayer];

    [graphPath addLineToPoint:CGPointMake(xPos, CGRectGetHeight(self.bounds))];
    [graphPath addLineToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];
    [graphPath closePath];

    CAShapeLayer *graphFillLayer = [CAShapeLayer layer];
    graphFillLayer.path = [graphPath CGPath];
    graphFillLayer.fillColor = _mainColor.CGColor;
    graphFillLayer.shouldRasterize = YES;
    graphFillLayer.rasterizationScale = UIScreen.mainScreen.scale;
    graphFillLayer.opacity = 0.5f;
    [self.layer addSublayer:graphFillLayer];
}

#pragma mark - Draw the legend and the gradients
- (void)drawLegends
{
    CGFloat percentage = [self getRemainingDaysInPercentageFromDate:self.startDate];
    NSInteger months = [self numberOfMonthsBetweenDate:self.startDate toDate:_targetDate];
    NSArray *legends;
    if (months <=1)
    {
        legends = [self getFirstDaysOfWeeksMinusWeeks:4];
    }
    else if (months <= 12)
    {
        legends = [self getMonthLegendsMinusMonths:months];
    }
    else if (months <= 24)
    {
        legends = [self getLegendsForQuartersForMonths:months];
    }
    else
    {
        legends = [self getLegendsForYear:months / 12];
    }

    [self drawGradientWithLegends:legends withOffsetPercentage:percentage];
}

- (void)drawGradientWithLegends:(NSArray *)legends withOffsetPercentage:(CGFloat )offsetPercentage
{
    UIView *gradientView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:gradientView];
    [self sendSubviewToBack:gradientView];
    gradientView.clipsToBounds = YES;

    CGFloat heightOfBar = CGRectGetHeight(self.bounds);

    NSInteger numberOfTotalDays = [self numberOfDaysBetweenDate:self.startDate toDate:_targetDate];

    if (numberOfTotalDays > 12*30)
    {
        numberOfTotalDays /= 30;
    }

    CGFloat percentage = 30 / (numberOfTotalDays / 100.f);
    CGFloat barWidth = CGRectGetMaxX(self.bounds) * (percentage / 100.0f);

    CGFloat xPos = 0;
    xPos -= barWidth * (offsetPercentage / 100);

    for (int i = 0; i < legends.count; i++)
    {
        UILabel *label = [self drawText:legends[i] point:CGPointMake(xPos ,CGRectGetMaxY(self.bounds))
                                   font:[UIFont boldSystemFontOfSize:10.f]
                                  color:_mainColor];
        label.layer.anchorPoint = CGPointMake(0, 1);

        [gradientView addSubview:label];

        if (i % 2 == 0)
        {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            CGRect frame = CGRectMake(xPos,
                                      0,
                                      barWidth,
                                      heightOfBar);
            gradient.frame = frame;
            gradient.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.0f].CGColor,
                                (id)_mainColor.CGColor];
            gradient.locations = @[@0, @1];
            gradient.opacity = 0.25f;
            [gradientView.layer addSublayer:gradient];
        }
        xPos += barWidth;
    }
}

#pragma mark - Legends
- (NSArray *)getMonthLegendsMinusMonths:(NSInteger)months
{
    NSMutableArray *monthsInStrings = [NSMutableArray new];

    NSDateFormatter *formatter = [NSDateFormatter new];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *lastDate = self.startDate;
    [formatter setDateFormat:@"MMM"];
    NSString *stringFromDate = [formatter stringFromDate:lastDate];
    [monthsInStrings addObject:stringFromDate];

    for (int i = 0; i < months; i++)
    {
        NSDateComponents *comps = [NSDateComponents new];
        comps.month = 1;
        NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:lastDate options:0];
        NSString *stringFromDate = [formatter stringFromDate:prevDate];
        [monthsInStrings addObject:stringFromDate];
        lastDate = prevDate;
    }
    return monthsInStrings.copy;
}

- (NSArray *)getLegendsForQuartersForMonths:(NSInteger)months
{
    NSMutableArray *monthsInStrings = [NSMutableArray new];

    NSDate *lastDate = self.startDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"MMM"];

    NSString *stringFromDate = [formatter stringFromDate:lastDate];
    [monthsInStrings addObject:stringFromDate];

    for (int i = 0; i < months / 3; i ++)
    {
        NSDate *prevDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:4 toDate:lastDate options:0];

        NSString *stringFromDate = [formatter stringFromDate:prevDate];
        [monthsInStrings addObject:stringFromDate];
        lastDate = prevDate;
    }
    return monthsInStrings.copy;
}

- (NSArray *)getLegendsForYear:(NSInteger)years
{
    NSMutableArray *yearsInString = [NSMutableArray new];

    NSDateFormatter *formatter = [NSDateFormatter new];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *lastDate = self.startDate;
    [formatter setDateFormat:@"YYYY"];
    NSString *stringFromDate = [formatter stringFromDate:lastDate];
    [yearsInString addObject:stringFromDate];

    for (int i = 0; i < years; i++)
    {
        NSDateComponents *comps = [NSDateComponents new];
        comps.year = 1;
        NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:lastDate options:0];
        [formatter setDateFormat:@"YYYY"];
        NSString *stringFromDate = [formatter stringFromDate:prevDate];
        [yearsInString addObject:stringFromDate];
        lastDate = prevDate;
    }
    return [yearsInString copy];
}

#pragma mark - Drawing helpers
- (UIView *)addDotToPoint:(CGPoint)point radius:(CGFloat)radius color:(UIColor *)color alpha:(CGFloat)alpha
{
    UIView *cirleshape = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    cirleshape.backgroundColor = [color colorWithAlphaComponent:alpha];
    cirleshape.layer.cornerRadius = cirleshape.bounds.size.width / 2.0f;
    cirleshape.center = point;
    cirleshape.userInteractionEnabled = YES;
    [self addSubview:cirleshape];
    return cirleshape;
}

- (CAShapeLayer *)drawLineFromPont:(CGPoint)fromPoint
                           toPoint:(CGPoint)toPoint
                             color:(UIColor *)color
                             width:(CGFloat)width
                             alpha:(CGFloat)alpha
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:fromPoint];
    [path addLineToPoint:toPoint];

    CAShapeLayer *lineShapeLayer = [CAShapeLayer layer];
    lineShapeLayer.path = [path CGPath];
    lineShapeLayer.strokeColor = color.CGColor;
    lineShapeLayer.lineWidth = width;

    lineShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    lineShapeLayer.shouldRasterize = YES;
    lineShapeLayer.rasterizationScale = UIScreen.mainScreen.scale;
    lineShapeLayer.opacity = alpha;
    return lineShapeLayer;
}

- (UILabel *)drawText:(NSString *)text
                point:(CGPoint)point
                 font:(UIFont *)font
                color:(UIColor *)color
{
    UILabel *label = [UILabel new];
    label.font = font;
    label.text = text;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.center = point;
    label.layer.anchorPoint = CGPointMake(0, 1);
    label.layer.shouldRasterize = YES;
    label.layer.rasterizationScale = UIScreen.mainScreen.scale;
    return label;
}

#pragma mark - Helper methods
- (NSAttributedString *)getAttruibutedStringWithString:(NSString *)string withBoldPart:(NSString *)boldPart
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange boldRange = [string rangeOfString:boldPart];

    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:10.f]
                             range:boldRange];
    return attributedString;
}

- (CGFloat)getRemainingDaysInPercentageFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay
                                  inUnit:NSCalendarUnitMonth
                                 forDate:date];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date];
    return components.day / (days.length / 100.0f);
}

- (NSInteger)numberOfDaysBetweenDate:(NSDate *)date toDate:(NSDate *)toDate
{
    NSUInteger unitFlags = NSCalendarUnitDay;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date toDate:toDate options:0];
    return components.day;
}

- (NSInteger)numberOfMonthsBetweenDate:(NSDate *)date toDate:(NSDate *)toDate
{
    NSUInteger unitFlags = NSCalendarUnitMonth;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date toDate:toDate options:0];
    return components.month;
}

- (NSDate *)getFirstDayOfTheWeekFromDate:(NSDate *)givenDate
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setFirstWeekday:2];
    NSUInteger adjustedWeekdayOrdinal = [calendar ordinalityOfUnit:NSCalendarUnitWeekday
                                                            inUnit:NSCalendarUnitWeekOfMonth
                                                           forDate:givenDate];

    NSDateComponents *comps = [NSDateComponents new];
    comps.day = -(adjustedWeekdayOrdinal-1);
    NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:givenDate options:0];
    return prevDate;
}

- (NSArray *)getFirstDaysOfWeeksMinusWeeks:(NSInteger)weeks
{
    NSMutableArray *weeksInString = [NSMutableArray new];

    NSDateFormatter *formatter = [NSDateFormatter new];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *lastDate = self.startDate;
    lastDate = [self getFirstDayOfTheWeekFromDate:lastDate];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:lastDate];
    [weeksInString addObject:stringFromDate];

    for (int i = 0; i < weeks; i++)
    {
        NSDateComponents *comps = [NSDateComponents new];
        comps.day = 7;
        NSDate *prevDate = [calendar dateByAddingComponents:comps toDate:lastDate options:0];

        NSString *stringFromDate = [formatter stringFromDate:prevDate];
        [weeksInString addObject:stringFromDate];
        lastDate = prevDate;
    }
    return weeksInString.copy;
}

@end

