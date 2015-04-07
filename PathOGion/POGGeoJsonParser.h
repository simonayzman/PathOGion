//
//  POGGeoJsonParser.h
//  PathOGion
//
//  Created by Simon Ayzman on 3/18/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POGGeoJsonParser : NSObject

- (NSArray *) getLocationPathFromGeoJsonFile:(NSString *) file;

@end
