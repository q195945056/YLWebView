//
//  Person.m
//  YLWebView
//
//  Created by yanmingjun on 16/1/28.
//  Copyright © 2016年 youloft. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)printWithOption:(PersonPropertyType)options {
    if (options & PersonPropertyTypeName) {
        printf("%s\n", self.name.UTF8String);
    }
    
    if (options & PersonPropertyTypeBirthday) {
        printf("%s\n", self.date.description.UTF8String);
    }
    
    if (options & PersonPropertyTypeAddress) {
        printf("%s\n", self.address.UTF8String);
    }
}

@end
