//
//  ViewController.m
//  InteractiveChart
//
//  Created by Csaba Vidó on 2017. 09. 25..
//  Copyright © 2017. Csaba Vidó. All rights reserved.
//

#import "ViewController.h"
#import "InteractiveChartView.h"
#import "TransactionItem.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *greenView;
@property (weak, nonatomic) IBOutlet UIView *magentaView;
@property (weak, nonatomic) IBOutlet UIView *orangeView;

@property (weak, nonatomic) IBOutlet UISlider *amountSlider;
@property (weak, nonatomic) IBOutlet UISlider *monthSlider;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *depositAmuntLabel;

@property (weak, nonatomic) IBOutlet InteractiveChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChartDefaultValues];
    [_chartView drawChart];
}

- (void)setupChartDefaultValues
{
    _chartView.values = [self getItems];
    _monthSlider.value = 2;
    [_amountSlider setTintColor:_chartView.mainColor];
    [_monthSlider setTintColor:_chartView.mainColor];

    _chartView.targetDate = [self getDatePlusMonths:4 forDate:[NSDate date]];
    _chartView.startDate = _chartView.values.firstObject.date;
    _chartView.daysBetweenDeposit = 7;
    _chartView.targetAmount = 5000.f;
    _chartView.depoistAmount = 100.f;
    _amountSlider.value = 100.f;
}

- (IBAction)amounSliderValueChanged:(UISlider *)sender
{
    _chartView.depoistAmount = sender.value;
    [_chartView drawChart];
}
- (IBAction)monthsSliderValueChanged:(UISlider *)sender
{
    _chartView.targetDate = [self getDatePlusMonths:(int)sender.value
                                            forDate:[NSDate date]];
    [_chartView drawChart];
}

- (IBAction)greenColorClicked:(id)sender
{
    [_chartView setMainColorTo:_greenView.backgroundColor];
    [_amountSlider setTintColor:_greenView.backgroundColor];
    [_monthSlider setTintColor:_greenView.backgroundColor];
}

- (IBAction)magentaColorClicked:(id)sender
{
    [_chartView setMainColorTo:_magentaView.backgroundColor];
    [_amountSlider setTintColor:_magentaView.backgroundColor];
    [_monthSlider setTintColor:_magentaView.backgroundColor];
}

- (IBAction)orangeColorClicked:(id)sender
{
    [_chartView setMainColorTo:_orangeView.backgroundColor];
    [_amountSlider setTintColor:_orangeView.backgroundColor];
    [_monthSlider setTintColor:_orangeView.backgroundColor];
}

#pragma mark - Helpers
- (NSDate *)getDateFromString:(NSString *)string
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    return [formatter dateFromString:string];
}

- (NSDate *)getDatePlusMonths:(NSUInteger)months forDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingUnit:NSCalendarUnitMonth value:+months toDate:date options:0];
    return newDate;
}

- (NSArray<TransactionItem *> *)getItems
{
    TransactionItem *item1 = [TransactionItem new];
    item1.date = [self getDatePlusMonths:-3 forDate:[NSDate date]];
    item1.amount = @(1000);
    TransactionItem *item2 = [TransactionItem new];
    item2.date = [self getDatePlusMonths:-2 forDate:[NSDate date]];
    item2.amount = @(200);
    TransactionItem *item3 = [TransactionItem new];
    item3.date = [self getDatePlusMonths:-1 forDate:[NSDate date]];
    item3.amount = @(-600);
    TransactionItem *item4 = [TransactionItem new];
    item4.date = [NSDate date];
    item4.amount = @(500);
    _chartView.initialAmount = item1.amount.floatValue + item2.amount.floatValue + item3.amount.floatValue + item4.amount.floatValue;
    return @[item1, item2, item3, item4];
}

@end
