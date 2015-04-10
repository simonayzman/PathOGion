//
//  POGLocationPath.h
//  PathOGion
//
//  Created by Simon Ayzman on 4/2/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POGLocationPoint;

@interface POGLocationPath : NSObject

- (instancetype) initWithLocationPoints: (NSArray *) locationPoints;

- (void) addLocationPoint: (POGLocationPoint *) locationPoint;
- (void) addLocationPoints: (NSArray *) locationPoints;

- (POGLocationPoint *) mostRecentLocationPoint;

- (NSArray *) getLocationPath;

@end
