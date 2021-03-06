//
//  RawDataPoint.m
//  Theseus
//
//  Created by Mike Lazer-Walker on 5/25/14.
//  Copyright (c) 2014 Mike Lazer-Walker
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

#import "RawDataPoint.h"
#import "CDRawDataPoint.h"

#import <Asterism.h>

@interface RawDataPoint ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *dataPointType; // Just for Mantle
@end

@implementation RawDataPoint

+ (Class)modelClass {
    @throw @"Not implemented";
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"model": NSNull.null,
             @"context": NSNull.null};
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)dict {
    return NSClassFromString(dict[@"dataPointType"]) ?: self.class;
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSValueTransformer *)timestampJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (id)init {
    if (!(self = [super init])) return nil;

    self.model = [self.class.modelClass MR_createEntity];

    return self;
}

- (id)initWithContext:(NSManagedObjectContext *)context {
    if (!(self = [super init])) return nil;
    self.context = context;
    self.model = [self.class.modelClass MR_createInContext:context];
    return self;
}

- (id)initWithCDModel:(NSManagedObject<CDRawDataPoint> *)model {
    if (!model) return nil;
    if (!(self = [super init])) return nil;
    self.model = model;
    return self;
}

- (id)initWithCDModel:(NSManagedObject<CDRawDataPoint> *)model
            context:(NSManagedObjectContext *)context {
    if (!model) return nil;
    if (!(self = [super init])) return nil;
    self.model = model;
    self.context = context;
    return self;
}

#pragma mark -
- (NSString *)dataPointType {
    return NSStringFromClass(self.class);
}

#pragma mark - Accessors
- (NSDate *)timestamp {
    return self.model.timestamp;
}

- (void)setTimestamp:(NSDate *)timestamp {
    self.model.timestamp = timestamp;
}

#pragma mark - MagicalRecord
+ (NSArray *)MR_findAll {
    NSArray *array = [self.modelClass MR_findAll];
    return ASTMap(array, ^id(id<CDRawDataPoint> obj) {
        return [[self alloc] initWithCDModel:obj];
    });
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSArray *array = [self.modelClass MR_findAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:context];
    return ASTMap(array, ^id(id<CDRawDataPoint> obj) {
        return [[self alloc] initWithCDModel:obj context:context];
    });
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending inContext:(NSManagedObjectContext *)context {
    NSArray *array = [self.modelClass MR_findAllSortedBy:sortTerm ascending:ascending inContext:context];
    return ASTMap(array, ^id(id<CDRawDataPoint> obj) {
        return [[self alloc] initWithCDModel:obj context:context];
    });
}

+ (NSArray *) MR_findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending; {
    NSArray *array = [self.modelClass MR_findAllSortedBy:sortTerm ascending:ascending];
    return ASTMap(array, ^id(id<CDRawDataPoint> obj) {
        return [[self alloc] initWithCDModel:obj];
    });
}
- (BOOL)destroy {
    return [self.model MR_deleteEntity];
}

@end
