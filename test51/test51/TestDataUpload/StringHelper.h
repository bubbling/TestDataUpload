//
//  StringHelper.h
//  TestDataUpload
//
//  Created by bubble on 12/4/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#ifndef StringHelper_h
#define StringHelper_h

#pragma mark Trimming Methods
@interface NSString (StringHelper)
//
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingBothSideWhitespace;
- (NSArray *)convertToArray;

@end


#endif
