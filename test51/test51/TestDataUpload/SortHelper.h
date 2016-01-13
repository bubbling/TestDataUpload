//
//  SortHelper.h
//  TestDataUpload
//
//  Created by bubble on 12/25/15.
//  Copyright (c) 2015 bubble. All rights reserved.
//

#ifndef SortgHelper_h
#define SortgHelper_h


#import <Foundation/Foundation.h>

@interface SortHelper : NSObject

//选择排序
-(NSArray *)selectSortWithArray:(NSArray *)aData;
-(void)selectSortWithArray1:(NSArray**)aData;

//插入排序
-(NSArray *)insertSortWithArray:(NSArray *)aData;
-(void)insertSortWithArray1:(NSArray**)aData;

//快速排序
-(NSArray *)quickSortWithArray:(NSArray *)aData;
-(void)quickSortWithArray1:(NSArray**)aData;
-(void)swapWithData:(NSMutableArray*)aData index1:(NSInteger)index1 index2:(NSInteger)index2;

@end


#endif