//
//  LocationPoint.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/19/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationPoint : NSObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double accuracy;
@property (nonatomic) NSDate *timestamp;

@end
