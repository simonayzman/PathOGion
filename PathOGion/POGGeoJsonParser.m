//
//  POGGeoJsonParser.m
//  PathOGion
//
//  Created by Simon Ayzman on 3/18/15.
//  Copyright (c) 2015 CARSI Lab. All rights reserved.
//

#import "POGGeoJsonParser.h"
#import "POGLocationPoint.h"
#import "POGLocationPath.h"

@implementation POGGeoJsonParser

- (POGLocationPath *) getLocationPathFromGeoJsonFile:(NSString *)patientFilePath
{
    NSMutableArray *path = [NSMutableArray array];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPatientFilePath = [[NSBundle mainBundle] pathForResource:patientFilePath ofType:@"geojson"];

    if ([fileManager fileExistsAtPath:fullPatientFilePath])
    {
        NSData *jsonData = [fileManager contentsAtPath:fullPatientFilePath];
        NSDictionary *unparsedPatientPathDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        NSArray *unparsedPatientPathArray =  unparsedPatientPathDictionary[@"features"];
        //NSLog(@"Parsed file %@", unparsedPatientPathArray);
        for (NSDictionary *feature in unparsedPatientPathArray)
        {
            POGLocationPoint *point = [self locationPointFromFeature:feature];
            [path addObject:point];
        }
    }
    else
    {
        NSLog(@"Could not find %@", fullPatientFilePath);
        return nil;
    }
    return [[POGLocationPath alloc] initWithLocationPoints:[path copy]];
}

- (POGLocationPoint *) locationPointFromFeature:(NSDictionary *)feature
{
    POGLocationPoint *point = [[POGLocationPoint alloc] init];
    point.latitude = [self getLatitudeFromFeature:feature];
    point.longitude = [self getLongitudeFromFeature:feature];
    point.timestamp = [self getTimestampFromFeature:feature];
    point.accuracy = 0;
    return point;
}

- (double) getLatitudeFromFeature:(NSDictionary *)feature
{
    return [feature[@"geometry"][@"coordinates"][0] doubleValue];
}

- (double) getLongitudeFromFeature:(NSDictionary *)feature
{
    return [feature[@"geometry"][@"coordinates"][1] doubleValue];
}

- (NSDate *) getTimestampFromFeature:(NSDictionary *)feature
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSString *timestampString = feature[@"properties"][@"timestamp"];
    NSDate *timestamp = [dateFormatter dateFromString:timestampString];
    return timestamp;
}

@end
