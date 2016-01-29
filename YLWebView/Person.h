//
//  Person.h
//  YLWebView
//
//  Created by yanmingjun on 16/1/28.
//  Copyright © 2016年 youloft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, PersonPropertyType) {
    PersonPropertyTypeNone      = 0,
    PersonPropertyTypeName      = 1 << 0,
    PersonPropertyTypeBirthday  = 1 << 1,
    PersonPropertyTypeAddress   = 1 << 2,
};


@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *address;

- (void)printWithOption:(PersonPropertyType)options;

@end
