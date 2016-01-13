//
//  AnalyzeData.m
//  TestDataUpload
//
//  Created by bubble on 1/8/20.
//  Copyright (c) 2020 bubble. All rights reserved.
//

#import "AnalyzeData.h"

@implementation AnalyzeData

-(id)init:(AppDelegate*)parent
{
    self = [super init];
    if (self) {
        // Initialization code here.
        myApp=parent;
        arrBarcode=[[NSMutableArray alloc]init];
        arrResult=[[NSMutableArray alloc]init];
        arrTime=[[NSMutableArray alloc]init];
    }
    return self;
}

-(void)saveStartLine:(NSString*)strID Line:(double)line
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"startline.setting" LINETYPE:SETTING_START_LINE];
        [fl saveStartLine:strID Line:line];
    }
}

-(double)getStartLine:(NSString*)strID
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"startline.setting" LINETYPE:SETTING_START_LINE];
        return [fl getStartLine:strID];
    }
}

-(double)getMaxLine:(NSString*)strID
{
    @autoreleasepool {
        FileLine* fl=[[FileLine alloc]init:@"maxline.setting" LINETYPE:SETTING_MAX_LINE];
        return [fl getMaxLine:strID];
    }
}

-(void)getMicData:(NSString*)path
{
    @autoreleasepool {
        if (!path) {
            if (myApp->_lock) {
                [myApp->_lock unlock];
            }
            return;
        }
        else
        {
            if (![self getPathByDeletePrefix:&path]) {
                if (myApp->_lock) {
                    [myApp->_lock unlock];
                }
                return;
            }
        }
        
        //
        [myApp writeLog:@"call function: getTabData()"];
        [myApp writeLog:[NSString stringWithFormat:@"-->file type:%@",myApp->strFileType]];
        [myApp writeLog:[NSString stringWithFormat:@"-->file path:%@",path]];
        [myApp writeLog:[NSString stringWithFormat:@"-->ok,file is exist,we will read it!"]];
        
        //
        double fileRows=0;
        NSString* strLine=nil;
        double maxLine=[self getMaxLine:myApp->strPartNo];
        NSInputStream* stream=[[NSInputStream alloc]initWithFileAtPath:[path stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
        [stream open];
        MDBufferedInputStream* mb=[[MDBufferedInputStream alloc]initWithInputStream:stream
                                                                         bufferSize:1024
                                                                           encoding:NSASCIIStringEncoding];
        [mb open];
        myApp->readRow=[self getStartLine:myApp->strPartNo];

        //
        @try {
            do {
                strLine=[mb readLine];
                //check dict variable is very impordent
                if (strLine==nil) {
                    break;
                }
                if (myApp->bStartRunUpload) {
                    break;
                }
                
                NSArray* strArr=[strLine componentsSeparatedByString:@"\t"];
                fileRows++;
                if (fileRows>myApp->readRow) {
                    if ([myApp getDataFileType]==Mic_X35) {
                        int tag1=0;
                        NSString* result=@"FAIL";
                        //思路：
                        //1）遍历行，当发现两行的条码不相同时，则认为下一行是新的条码的开始行,
                        //2）连续出现相同的条码，统计出现的次数，直到发现两行条码不同，
                        //3）两行条码不相同，需要判断设定的实际条码行数和记录的条码行数差别，
                        if ([myApp->strLastBarcode compare:@"" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                            myApp->strLastBarcode=strArr[0];
                            [arrBarcode addObject:strArr[0]];
                            [arrResult addObject:strArr[5]];
                            [arrTime addObject:strArr[1]];
                        }
                        else
                        {
                            if ([myApp->strLastBarcode compare:strArr[0] options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                                myApp->strLastBarcode=strArr[0];
                                [arrBarcode addObject:strArr[0]];
                                [arrResult addObject:strArr[5]];
                                [arrTime addObject:strArr[1]];
                            }
                            else{
                                if ([arrBarcode count]!=maxLine) {
                                    [arrBarcode removeAllObjects];
                                    [arrResult removeAllObjects];
                                    [arrTime removeAllObjects];
                                }
                                if ([arrBarcode count]==maxLine) {
                                    tag1=1;
                                    result=@"PASS";
                                    for (int i=0; i<[arrResult count]; i++) {
                                        if ([arrResult[i] compare:@"FAIL" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                                            result=@"FAIL";
                                            break;
                                        }
                                    }
                                    [arrBarcode removeAllObjects];
                                    [arrResult removeAllObjects];
                                    [arrTime removeAllObjects];
                                }
                                myApp->strLastBarcode=strArr[0];
                                [arrBarcode addObject:strArr[0]];
                                [arrResult addObject:strArr[5]];
                                [arrTime addObject:strArr[1]];
                            }
                        }
                        
                        //
                        if (tag1==1) {
                            [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                                                   strArr[0],
                                                                   result,
                                                                   strArr[1]]];
                            if (strArr[0]!=nil &&
                                strArr[1]!=nil ) {
                                if([myApp uploadData:strArr[0]
                                          TestResult:result
                                            TestDate:strArr[1]
                                           DataTable:MYSQL_Prox_FLUKE_DATA])
                                {
                                    [myApp showRate:result];
                                }
                            }
                            
                            //barcode check error.
                            if (!myApp->bCheckBar) {
                                break;
                            }
                        }
                    }
                }
            }while (strLine);
            
            if (strLine==nil) {
                if ([arrBarcode count]==[self getMaxLine:myApp->strPartNo]) {
                    NSString* result=@"PASS";
                    if ([arrBarcode count]==maxLine) {
                        for (int i=0; i<[arrResult count]; i++) {
                            if ([arrResult[i] compare:@"FAIL" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                                result=@"FAIL";
                                break;
                            }
                        }

                        //
                        [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                        arrBarcode[0],
                                        result,
                                        arrTime[1]]];
                        if (arrBarcode[0]!=nil &&
                            arrTime[0]!=nil ) {
                            if([myApp uploadData:arrBarcode[0]
                                      TestResult:result
                                        TestDate:arrTime[0]
                                       DataTable:MYSQL_Prox_FLUKE_DATA])
                            {
                                [myApp showRate:result];
                            }
                        }
                        
                        //
                        [arrBarcode removeAllObjects];
                        [arrResult removeAllObjects];
                        [arrTime removeAllObjects];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        //
        if (fileRows>myApp->readRow) {
            [self saveStartLine:myApp->strPartNo Line:fileRows];
        }
        [mb close];
        [stream close];
        if (myApp->_lock) {
            [myApp->_lock unlock];
        }
        myApp->countHourProducts++;
        [myApp showHourProduct];
    }
}

//only for ALS test,TAB format
-(void)getTabData:(NSString*)path
{
    @autoreleasepool {
        if (!path) {
            if (myApp->_lock) {
                [myApp->_lock unlock];
            }
            return;
        }
        else
        {
            if (![myApp getPathByDeletePrefix:&path]) {
                if (myApp->_lock) {
                    [myApp->_lock unlock];
                }
                return;
            }
        }
        
        //
        [myApp writeLog:@"call function: getTabData()"];
        [myApp writeLog:[NSString stringWithFormat:@"-->file type:%@",myApp->strFileType]];
        [myApp writeLog:[NSString stringWithFormat:@"-->file path:%@",path]];
        [myApp writeLog:[NSString stringWithFormat:@"-->ok,file is exist,we will read it!"]];
        
        //
        double fileRows=0;
        NSInputStream* stream=[[NSInputStream alloc]initWithFileAtPath:[path stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
        [stream open];
        MDBufferedInputStream* mb=[[MDBufferedInputStream alloc]initWithInputStream:stream
                                                                         bufferSize:1024
                                                                           encoding:NSASCIIStringEncoding];
        [mb open];
        NSString* strLine=[mb readLine];
        myApp->readRow=[self getStartLine:myApp->strPartNo];
        
        @try {
            while (strLine) {
                strLine=[mb readLine];
                
                //check dict variable is very impordent
                if (strLine==nil) {
                    break;
                }
                if (myApp->bStartRunUpload) {
                    break;
                }
                
                NSArray* strArr=[strLine componentsSeparatedByString:@"\t"];
                fileRows++;
                if (fileRows>myApp->readRow) {
                    //1.ALS format
                    if ([myApp getDataFileType]==ALS_N69) {
                        [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                       strArr[0],
                                       strArr[29],
                                       strArr[31]]];
                        
                        if (strArr[0]!=nil &&
                            strArr[31]!=nil &&
                            [self isTestResult:strArr[29]]==true) {
                            if([myApp uploadData:strArr[0]
                                     TestResult:strArr[29]
                                       TestDate:strArr[31]
                                      DataTable:MYSQL_ALS_ICT_DATA])
                            {
                                [myApp showRate:strArr[29]];
                            }
                        }
                    }
                    
                    //2.
                    if ([myApp getDataFileType]==ALS_X109) {
                        NSString* strItem1=[NSString stringWithFormat:@"%@",strArr[0]];
                        if ([strItem1 compare:@"ALS-Flex" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [strItem1 compare:@"SerialNumber" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [strItem1 compare:@"Upper Limit ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [strItem1 compare:@"Lower Limit ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                            continue;
                        }
                        else
                        {
                            [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                           strArr[0],
                                           strArr[32],
                                           strArr[34]]];
                            
                            //
                            if (strArr[0]!=nil &&
                                strArr[34]!=nil &&
                                [self isTestResult:strArr[32]]==true) {
                                if([myApp uploadData:strArr[0]
                                         TestResult:strArr[32]
                                           TestDate:strArr[34]
                                          DataTable:MYSQL_ALS_ICT_DATA])
                                {
                                    [myApp showRate:strArr[32]];
                                }
                            }
                        }
                    }
                    
                    //barcode check error.
                    if (!myApp->bCheckBar) {
                        break;
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        //
        if (fileRows>myApp->readRow) {
            [self saveStartLine:myApp->strPartNo Line:fileRows];
        }
        [mb close];
        [stream close];
        if (myApp->_lock) {
            [myApp->_lock unlock];
        }
        myApp->countHourProducts++;
        [myApp showHourProduct];
    }
}

-(void)getCommaData:(NSString*)path
{
    @autoreleasepool {
        if (!path) {
            if (myApp->_lock) {
                [myApp->_lock unlock];
            }
            return;
        }
        else
        {
            if (![myApp getPathByDeletePrefix:&path]) {
                if (myApp->_lock) {
                    [myApp->_lock unlock];
                }
                return;
            }
        }
        
        //
        [myApp writeLog:@"call function: getCommaData()"];
        [myApp writeLog:[NSString stringWithFormat:@"-->file type:%@",myApp->strFileType]];
        [myApp writeLog:[NSString stringWithFormat:@"-->file path:%@",path]];
        [myApp writeLog:[NSString stringWithFormat:@"-->ok,file is exist,we will read it!"]];
        
        //
        double fileRows=0;
        NSInputStream* stream=[[NSInputStream alloc]initWithFileAtPath:[path stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
        [stream open];
        MDBufferedInputStream* mb=[[MDBufferedInputStream alloc]initWithInputStream:stream
                                                                         bufferSize:1024
                                                                           encoding:NSASCIIStringEncoding];
        [mb open];
        NSDictionary* dict=[mb csvReadData];
        if ([myApp getDataFileType]==Prox_N56 ||
            [myApp getDataFileType]==Prox_N66 ||
            [myApp getDataFileType]==Prox_N71) {
            myApp->readRow=[self getStartLine:[path lastPathComponent]];
        }
        else
        {
            myApp->readRow=[self getStartLine:myApp->strPartNo];
        }
        
        @try {
            while (dict) {
                //only useed to comma format data
                dict=[mb csvReadData];
                
                //check dict variable is very impordent
                if (dict==nil) {
                    break;
                }
                if (myApp->bStartRunUpload) {
                    break;
                }
                
                fileRows++;
                if (fileRows>myApp->readRow) {
                    
                    //1.Prox comma format
                    if ([myApp getDataFileType]==Prox_N56 ||
                        [myApp getDataFileType]==Prox_N66 ||
                        [myApp getDataFileType]==Prox_N71) {
                        [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                       [dict objectForKey:@"field0"],
                                       [dict objectForKey:@"field1"],
                                       [dict objectForKey:@"field5"]]];
                        
                        if ([dict objectForKey:@"field5"] &&
                            [dict objectForKey:@"field0"] &&
                            [self isTestResult:[dict objectForKey:@"field1"]]) {
                            if([myApp uploadData:[dict objectForKey:@"field0"]
                                     TestResult:[dict objectForKey:@"field1"]
                                        TestDate:[self modifyProxTestDate:[dict objectForKey:@"field5"]]
                                      DataTable:MYSQL_Prox_FLUKE_DATA])
                            {
                                [myApp showRate:[dict objectForKey:@"field1"]];
                            }
                            //barcode check error.
                            if (!myApp->bCheckBar) {
                                break;
                            }
                        }
                    }
                    
                    //2.
                    if ([myApp getDataFileType]==ALS_X137) {
                        if ([[dict objectForKey:@"field0"] compare:@"Stage Number =>" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Stage Name =>" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Upper Limit =>" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Lower Limit =>" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                            continue;
                        }
                        else{
                            //
                            [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                           [dict objectForKey:@"field1"],
                                           [dict objectForKey:@"field59"],
                                           [dict objectForKey:@"field61"]]];
                            
                            if ([dict objectForKey:@"field1"] &&
                                [dict objectForKey:@"field61"] &&
                                [self isTestResult:[dict objectForKey:@"field59"]]) {
                                if([myApp uploadData:[dict objectForKey:@"field1"]
                                         TestResult:[dict objectForKey:@"field59"]
                                           TestDate:[dict objectForKey:@"field61"]
                                          DataTable:MYSQL_ALS_ICT_DATA])
                                {
                                    [myApp showRate:[dict objectForKey:@"field59"]];
                                }
                                //barcode check error.
                                if (!myApp->bCheckBar) {
                                    break;
                                }
                            }
                        }
                    }
                    
                    //3.
                    if ([myApp getDataFileType]==ALS_J127) {
                        if ([[dict objectForKey:@"field0"] compare:@"Banshee" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                            //
                            [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                            [dict objectForKey:@"field1"],
                                            [dict objectForKey:@"field19"],
                                            [dict objectForKey:@"field3"]]];
                            
                            if ([dict objectForKey:@"field1"] &&
                                [dict objectForKey:@"field3"] &&
                                [self isTestResult:[dict objectForKey:@"field19"]]) {
                                if([myApp uploadData:[dict objectForKey:@"field1"]
                                          TestResult:[dict objectForKey:@"field19"]
                                            TestDate:[self modifyBansheeTestTime:[dict objectForKey:@"field3"]]
                                           DataTable:MYSQL_ALS_ICT_DATA])
                                {
                                    [myApp showRate:[dict objectForKey:@"field19"]];
                                }
                                //barcode check error.
                                if (!myApp->bCheckBar) {
                                    break;
                                }
                            }
                        }
                    }
                    
                    //4.
                    if ([myApp getDataFileType]==Mic_D10) {
                        if ([[dict objectForKey:@"field0"] compare:@"Test" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Product" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Display Name ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"PDCA Priority ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Upper Limit ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Lower Limit ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
                            [[dict objectForKey:@"field0"] compare:@"Measurement Unit ----->" options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                            continue;
                        }
                        else{
                            //
                            [myApp showRun:[NSString stringWithFormat:@"%@\t%@\t%@",
                                            [dict objectForKey:@"field1"],
                                            [dict objectForKey:@"field10"],
                                            [dict objectForKey:@"field11"]]];
                            
                            if ([dict objectForKey:@"field1"]!=nil &&
                                [dict objectForKey:@"field11"]!=nil &&
                                [self isTestResult:[dict objectForKey:@"field10"]]) {
                                if([myApp uploadData:[[dict objectForKey:@"field1"] stringByReplacingOccurrencesOfString:@"'" withString:@""]
                                          TestResult:[dict objectForKey:@"field10"]
                                            TestDate:[dict objectForKey:@"field11"]
                                           DataTable:MYSQL_Prox_FLUKE_DATA])
                                {
                                    [myApp showRate:[dict objectForKey:@"field10"]];
                                }
                                //barcode check error.
                                if (!myApp->bCheckBar) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
        //
        if (fileRows>myApp->readRow) {
            if ([myApp getDataFileType]==Prox_N56 ||
                [myApp getDataFileType]==Prox_N66 ||
                [myApp getDataFileType]==Prox_N71) {
                [self saveStartLine:[path lastPathComponent] Line:fileRows];
            }
            else
            {
                [self saveStartLine:myApp->strPartNo Line:fileRows];
            }
        }
        
        [mb close];
        [stream close];
        if (myApp->_lock) {
            [myApp->_lock unlock];
        }
        myApp->countHourProducts++;
        [myApp showHourProduct];
    }
}

-(NSArray*)getAllFileNameUnderDir:(NSString*)strDir FileExt:(NSString*)strExt
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList =  [[NSArray alloc] init];
    fileList=[fm contentsOfDirectoryAtPath:strDir error:nil];
    for(int i=0;i<[fileList count];i++) {
        NSString* strName=[fileList[i] lastPathComponent];
        if ([[strName pathExtension] compare:strExt options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            [arr addObject:strName];
        }
    }
    return arr;
}


-(NSArray*)getAllFileNameUnderDir:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList =  [[NSArray alloc] init];
    fileList=[fm contentsOfDirectoryAtPath:strDir error:nil];
    for(int i=0;i<[fileList count];i++) {
        NSString* strName=[fileList[i] lastPathComponent];
        NSDictionary *attr= [fm attributesOfItemAtPath:[strDir stringByAppendingPathComponent:fileList[i]] error:nil];
        NSRange rang=[strName rangeOfString:strKey];
        if (rang.length>0 &&[[strName pathExtension] compare:strExt options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            //数组的元素是自定义的类FileAttr的对象
            FileAttr *myAttr = [[FileAttr alloc]init];
            myAttr.fileName=[fileList[i] lastPathComponent];
            myAttr.fileCreateTime=[attr objectForKey:@"NSFileModificationDate"];
            [arr addObject:myAttr];
        }
    }
    return arr;
}

-(NSArray*)getAllFileNameUnderDir1:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList =  [[NSArray alloc] init];
    fileList=[fm contentsOfDirectoryAtPath:strDir error:nil];
    for(int i=0;i<[fileList count];i++) {
        NSString* strName=[fileList[i] lastPathComponent];
        NSDictionary *attr= [fm attributesOfItemAtPath:[strDir stringByAppendingPathComponent:fileList[i]] error:nil];
        NSRange rang=[strName rangeOfString:strKey];
        if (rang.length>0 &&[[strName pathExtension] compare:strExt options:NSCaseInsensitiveSearch]==NSOrderedSame) {
            
            //数组的元素是NSDictionary对象
            NSDictionary *dict =[NSMutableDictionary new];
            [dict setValue:[fileList[i] lastPathComponent] forKey:@"FileName"];
            [dict setValue:[attr objectForKey:@"NSFileModificationDate"] forKey:@"FileCreateTime"];
            [arr addObject:dict];
        }
    }
    return arr;
}

-(NSString*)getFileNameByLastModifyDate:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt;
{
    @autoreleasepool {
        @try {
            NSArray* arr1=[self getAllFileNameUnderDir:strDir NameKey:strKey FileExt:strExt];
            if ([arr1 count]>0) {
                NSMutableArray* arr2 = [[NSMutableArray alloc]init];
                for (int i=0;i<[arr1 count];i++) {
                    FileAttr *myAttr = arr1[i];
                    [arr2 addObject:myAttr.fileCreateTime];
                }
                
                //使用排序类SortHelper对NSArray进行排序
                SortHelper* sort=[[SortHelper alloc]init];
                NSArray* arr3=[sort quickSortWithArray:arr2];
                NSDate* max=arr3[[arr3 count]-1];
                
                //遍历数组元素
                for (FileAttr* a in arr1) {
                    if (a.fileCreateTime==max) {
                        return a.fileName;
                    }
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return nil;
}

-(NSString*)getFileNameByLastModifyDate1:(NSString*)strDir NameKey:(NSString*)strKey FileExt:(NSString*)strExt
{
    @autoreleasepool {
        @try {
            //使用NSSortDescriptor对NSArray进行排序
            NSArray* arr1=[self getAllFileNameUnderDir1:strDir NameKey:strKey FileExt:strExt];
            if ([arr1 count]>0) {
                NSSortDescriptor* sort1=[[NSSortDescriptor alloc]initWithKey:@"FileCreateTime" ascending:false];
                NSArray* arr2=[NSArray arrayWithObjects:sort1, nil];
                NSArray* arr3=[arr1 sortedArrayUsingDescriptors:arr2];
                
                //返回数组中值最大的元素
                NSDictionary* dict=arr3[0];
                return [dict valueForKey:@"FileName"];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return nil;
}

-(NSString*)modifyProxTestDate:(NSString*)strDate
{
    //格式：2015-12-24 08:10:58
    @try {
        NSArray* arrNow=[[self getTestDateTime:LOCAL_DATE_TIME] componentsSeparatedByString:@"-"];
        NSArray* arrLocal=[strDate componentsSeparatedByString:@"-"];
        
        //测试时间在12月28日到12月31日之间，年份会多增加1年
        if ([arrLocal[1] intValue]==12) {
            if ([arrNow[1] intValue]==12) {
                return [NSString stringWithFormat:@"%@-%@-%@",arrNow[0],arrLocal[1],arrLocal[2]];
            }
            else if (([arrNow[1] intValue]<[arrLocal[1] intValue])) {
                return [NSString stringWithFormat:@"%d-%@-%@",[arrNow[0]intValue]-1,arrLocal[1],arrLocal[2]];
            }
        }
        return strDate;
    }
    @catch (NSException *exception) {
        return [self getTestDateTime:LOCAL_DATE_TIME];
    }
    @finally {
        
    }
}

-(NSString*)modifyBansheeTestTime:(NSString*)strTime
{
    NSRange rang1=[strTime rangeOfString:@":"];
    NSRange rang2=[strTime rangeOfString:@"."];
    if (rang1.length>0 && rang2.length>0) {
        NSString* str1=[self getTestDateTime:LOCAL_DATE_TIME];
        NSString* str2=[[str1 substringToIndex:14] stringByAppendingString:[strTime substringToIndex:5]];
        return str2;
    }
    else
    {
        return [self getTestDateTime:LOCAL_TIME];
    }
}

-(NSString*)getTestDateTime:(_LOCALDATETIME)datetime
{
    NSDateFormatter* fm=[[NSDateFormatter alloc] init];
    switch (datetime) {
        case 0:     [fm setDateFormat:@"yyyyMMdd"];                 break;
        case 1:     [fm setDateFormat:@"HHmmss"];                   break;
        case 2:     [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];      break;
        default:
            break;
    }
    return [fm stringFromDate:[NSDate date]];
}

-(NSString*)getBansheeFilePathByCreateTime:(NSString*)strPath
{
    [self writeLog:@"call function getBansheeFilePathByCreateTime()"];
    @try {
        if ([self getPathByDeletePrefix:&strPath]) {
            NSString* strDir=[strPath stringByDeletingLastPathComponent];
            NSString* strFileNameKey=@"Banshee";
            return [strDir stringByAppendingPathComponent:[self getFileNameByLastModifyDate1:strDir
                                                                                     NameKey:strFileNameKey
                                                                                     FileExt:[strPath pathExtension]]];
        }
    }
    @catch (NSException *exception) {
        [self getTestDateTime:LOCAL_DATE_TIME];
    }
    @finally {
        
    }
    return nil;
}

-(NSString*)getFilePathByCreateTimeAndPart:(NSString*)strPath
{
    [self writeLog:@"call function getFilePathByCreateTimeAndPart()"];
    @try {
        if ([self getPathByDeletePrefix:&strPath]) {
            NSString* strDir=[strPath stringByDeletingLastPathComponent];
            NSString* strFileNameKey=myApp->strPartNo;
            return [strDir stringByAppendingPathComponent:[self getFileNameByLastModifyDate1:strDir
                                                                                     NameKey:strFileNameKey
                                                                                     FileExt:[strPath pathExtension]]];
        }
    }
    @catch (NSException *exception) {
        [self getTestDateTime:LOCAL_DATE_TIME];
    }
    @finally {
        
    }
    return nil;
}

//适用于N56/N66/N71的距感测试数据
//N56prox,N66prox,N71prox类型的测试数据文件，只能通过文件创建日期和关键字来识别，
//不能通过设置中选择的文件路径来处理，因为文件名中含有设备ID号码
-(NSString*)getFilePathByCreateTimeAndProx:(NSString*)strPath
{
    [self writeLog:@"call function getFilePathByCreateTimeAndProx()"];
    @try {
        if ([self getPathByDeletePrefix:&strPath]) {
            NSString* strDir=[strPath stringByDeletingLastPathComponent];
            NSString* strFileName=[strPath lastPathComponent];
            NSArray* arr1=[strFileName componentsSeparatedByString:@"_"];
            NSString* strFileNameKey=arr1[0];
            return [strDir stringByAppendingPathComponent:[self getFileNameByLastModifyDate1:strDir
                                                                                     NameKey:strFileNameKey
                                                                                     FileExt:[strPath pathExtension]]];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return nil;
}

-(bool)getPathByDeletePrefix:(NSString**)strPath
{
    //传引用
    NSRange rang=[*strPath rangeOfString:@"file:"];
    if (rang.location==0) {
        *strPath=[*strPath substringFromIndex:rang.location+5];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[*strPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "] isDirectory:false]==NO){
        return false;
    }
    return true;
}

-(void)writeLog:(NSString*)strMsg
{
    @autoreleasepool {
        UserLog* log=[[UserLog alloc]init:myApp];
        [log writeLog:strMsg];
    }
}

-(bool)isTestResult:(NSString*)strResult
{
    if ([strResult compare:@"PASS" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
        [strResult compare:@"FAIL" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
        [strResult compare:@"P" options:NSCaseInsensitiveSearch]==NSOrderedSame ||
        [strResult compare:@"F" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        return true;
    }
    return false;
}

@end
