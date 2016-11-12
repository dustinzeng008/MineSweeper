//
//  UIButton+Property.m
//  MineSweeper
//
//  Created by Yong Zeng on 11/11/16.
//  Copyright © 2016 Yong Zeng. All rights reserved.
//

#import "UIButton+Property.h"
#import <objc/runtime.h>

@implementation UIButton (Property)

- (NSNumber *)status{
    id data = objc_getAssociatedObject(self, "Property");
    return data;
}

- (void)setStatus:(NSNumber *)status{
    objc_setAssociatedObject(self, "Property", status,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
