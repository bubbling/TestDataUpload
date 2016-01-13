//
//  StringHelper.m
//  TestDataUpload
//
//  Created by bubble on 12/4/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Trimming Methods
@implementation NSString (StringHelper)

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet
{
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];
    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingBothSideWhitespace
{
    return [[self stringByTrimmingLeadingWhitespaceAndNewlineCharacters]
            stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
}

-(NSArray *)convertToArray
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i=0; i < self.length; i++) {
        NSString *tmp_str = [self substringWithRange:NSMakeRange(i, 1)];
        [arr addObject:[tmp_str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return arr;
}

@end
