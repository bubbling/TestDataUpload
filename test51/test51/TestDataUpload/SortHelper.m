//
//  SortHelper.m
//  TestDataUpload
//
//  Created by bubble on 12/25/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#import "SortHelper.h"

@interface SortHelper()
-(void)quickSortWithArray:(NSArray *)aData left:(NSInteger)left right:(NSInteger)right;
@end

@implementation SortHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSArray*)selectSortWithArray:(NSArray *)aData
{
    NSMutableArray* data = [[NSMutableArray alloc]initWithArray:aData];
    [self selectSortWithArray1:&data];
//    for (int i=0; i<[data count]-1; i++) {
//        int m =i;
//        for (int j =i+1; j<[data count]; j++) {
//            if ([data objectAtIndex:j] < [data objectAtIndex:m]) {
//                m = j;
//            }
//        }
//        if (m != i) {
//            [self swapWithData:data index1:m index2:i];
//        }
//    }
    return data;
}

-(void)selectSortWithArray1:(NSArray **)aData
{
    NSMutableArray* data = [[NSMutableArray alloc]initWithArray:*aData];
    for (int i=0; i<[data count]-1; i++) {
        int m =i;
        for (int j =i+1; j<[data count]; j++) {
            if ([data objectAtIndex:j] < [data objectAtIndex:m]) {
                m = j;
            }
        }
        if (m != i) {
            [self swapWithData:data index1:m index2:i];
        }
    }
    *aData=data;
}

-(NSArray*)insertSortWithArray:(NSArray *)aData
{
    NSMutableArray *data = [[NSMutableArray alloc]initWithArray:aData];
    [self insertSortWithArray1:&data];
//    for (int i = 1; i < [data count]; i++) {
//        id tmp = [data objectAtIndex:i];
//        int j = i-1;
//        while (j != -1 && [data objectAtIndex:j] > tmp) {
//            [data replaceObjectAtIndex:j+1 withObject:[data objectAtIndex:j]];
//            j--;
//        }
//        [data replaceObjectAtIndex:j+1 withObject:tmp];
//    }
    return data;
}

-(void)insertSortWithArray1:(NSArray **)aData
{
    NSMutableArray *data = [[NSMutableArray alloc]initWithArray:*aData];
    for (int i = 1; i < [data count]; i++) {
        id tmp = [data objectAtIndex:i];
        int j = i-1;
        while (j != -1 && [data objectAtIndex:j] > tmp) {
            [data replaceObjectAtIndex:j+1 withObject:[data objectAtIndex:j]];
            j--;
        }
        [data replaceObjectAtIndex:j+1 withObject:tmp];
    }
    *aData=data;
}

-(NSArray*)quickSortWithArray:(NSArray *)aData
{
    NSMutableArray *data = [[NSMutableArray alloc] initWithArray:aData];
    [self quickSortWithArray1:&data];
//    [self quickSortWithArray:data left:0 right:[aData count]-1];
    return data;
}

-(void)quickSortWithArray1:(NSArray **)aData
{
    NSMutableArray *data = [[NSMutableArray alloc] initWithArray:*aData];
    [self quickSortWithArray:data left:0 right:[*aData count]-1];
    *aData=data;
}

-(void)quickSortWithArray:(NSMutableArray *)aData left:(NSInteger)left right:(NSInteger)right
{
    if (right > left) {
        NSInteger i = left;
        NSInteger j = right + 1;
        while (true) {
            while (i+1 < [aData count] && [aData objectAtIndex:++i] < [aData objectAtIndex:left]) ;
            while (j-1 > -1 && [aData objectAtIndex:--j] > [aData objectAtIndex:left]) ;
            if (i >= j) {
                break;
            }
            [self swapWithData:aData index1:i index2:j];
        }
        [self swapWithData:aData index1:left index2:j];
        [self quickSortWithArray:aData left:left right:j-1];
        [self quickSortWithArray:aData left:j+1 right:right];
    }
}

-(void)swapWithData:(NSMutableArray *)aData index1:(NSInteger)index1 index2:(NSInteger)index2{
    NSNumber *tmp = [aData objectAtIndex:index1];
    [aData replaceObjectAtIndex:index1 withObject:[aData objectAtIndex:index2]];
    [aData replaceObjectAtIndex:index2 withObject:tmp];
}


@end
