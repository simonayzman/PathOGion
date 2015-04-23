//
//  POGGeoJsonParser.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/18/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class POGLocationPath;

@interface POGGeoJsonParser : NSObject

- (POGLocationPath *) getLocationPathFromGeoJsonFile:(NSString *) file;

@end
