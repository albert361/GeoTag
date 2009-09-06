//
//  ImageInfo.h
//  GeoTag
//
//  Created by Marco S Hyman on 6/15/09.
//

#import <Cocoa/Cocoa.h>

/*
 * info dictionary keys
 */
#define IIPathName @"path"
#define IIImageName @"fn"
#define IIDateTime @"dt"
#define IICapacity 4

@interface ImageInfo : NSObject {
    NSMutableDictionary *infoDict;
    CGFloat latitude;
    CGFloat longitude;
    CGFloat originalLatitude;
    CGFloat originalLongitude;
    CGFloat rotateBy;
    BOOL validLocation;
    BOOL validOriginalLocation;
    BOOL validImage;
}
@property CGFloat latitude;
@property CGFloat longitude;
@property CGFloat originalLatitude;
@property CGFloat originalLongitude;
@property CGFloat rotateBy;
@property BOOL validLocation;
@property BOOL validOriginalLocation;
@property BOOL validImage;

@property (readonly) NSString *path;
@property (readonly) NSString *name;
@property (readonly) NSString *date;
@property (readonly) NSString *latitudeAsString;
@property (readonly) NSString *longitudeAsString;

+ (id) imageInfoWithPath: (NSString *) path;

- (void) setLocationToLatitude: (NSString *) lat
		     longitude: (NSString *) lng;
- (void) saveLocation;
- (void) revertLocation;
- (NSString *) stringRepresentation;
- (BOOL) convertFromString: (NSString *) representation
		  latitude: (NSString **) lat
		 longitude: (NSString **) lng;

@end