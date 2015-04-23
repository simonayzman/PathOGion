//
//  POGCoreDataLocationPoint.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/2/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGCoreDataLocationPoint.h"


@implementation POGCoreDataLocationPoint

@dynamic latitude;
@dynamic longitude;
@dynamic accuracy;
@dynamic timestamp;

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f) within %+.2f meters. Timestamp: %@.", self.latitude, self.longitude, self.accuracy, self.timestamp];
}

@end
