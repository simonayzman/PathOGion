//
//  POGCoreDataLocationPoint.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/2/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface POGCoreDataLocationPoint : NSManagedObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double accuracy;
@property (nonatomic) NSDate *timestamp;

@end
