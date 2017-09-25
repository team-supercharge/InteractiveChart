//
//  TransactionItem.h
//  InteractiveChart
//
//  Created by Csaba Vidó on 2017. 09. 26..
//  Copyright © 2017. Csaba Vidó. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionItem : NSObject

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSDate *date;

@end
