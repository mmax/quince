//
//  LilyPondExportTest.m
//  quince
//
//  Created by max on 3/29/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//
//
//	If you have any questions contact quince@maximilianmarcoll.de
//
//	This file is part of quince.
//
//	quince is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	quince is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with quince.  If not, see <http://www.gnu.org/licenses/>.
//

#import "LilyPondExportTest.h"


@implementation LilyPondExportTest

-(void)setUp{


	lily = [[LilyPondExport alloc]init];
	quince = [[QuinceObject alloc]init];
	[quince setValue:[NSNumber numberWithDouble:4.23]forKey:@"start"];
}



-(void)testGetMeasureforTime{

	
	double timeA = 5.75, timeB = 3.60000001, timeC = 1.333, timeD = 4.142, timeE = 0.875, timeF = 1.8333 , timeG = 7.0, timeH = 25.5;
	
	int measureA, measureB, measureC, measureD, measureE, measureF, measureG, measureH;
	
	measureA = [lily getMeasureForTime:timeA];
	measureB = [lily getMeasureForTime:timeB];
	measureC = [lily getMeasureForTime:timeC];
	measureD = [lily getMeasureForTime:timeD];
	measureE = [lily getMeasureForTime:timeE];
	measureF = [lily getMeasureForTime:timeF];
	measureG = [lily getMeasureForTime:timeG];
	measureH = [lily getMeasureForTime:timeH];
	STAssertEqualObjects([NSNumber numberWithInt:measureA], [NSNumber numberWithInt:8], @"measureA wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureB], [NSNumber numberWithInt:5], @"measureB wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureC], [NSNumber numberWithInt:6], @"measureC wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureD], [NSNumber numberWithInt:7], @"measureD wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureE], [NSNumber numberWithInt:8], @"measureE wrong");	
	STAssertEqualObjects([NSNumber numberWithInt:measureF], [NSNumber numberWithInt:6], @"measureF wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureG], [NSNumber numberWithInt:8], @"measureG wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureH], [NSNumber numberWithInt:8], @"measureH wrong");	
	
}

-(void)testGetMeasureforTime2{// extreme deviations...
	
	
	double timeA = 5.7501, timeB = 3.601, timeC = 1.334, timeD = 4.1425, timeE = 0.8751, timeF = 1.8334 , timeG = 7.1251, timeH = 25.5001;
	
	int measureA, measureB, measureC, measureD, measureE, measureF, measureG, measureH;
	
	measureA = [lily getMeasureForTime:timeA];
	measureB = [lily getMeasureForTime:timeB];
	measureC = [lily getMeasureForTime:timeC];
	measureD = [lily getMeasureForTime:timeD];
	measureE = [lily getMeasureForTime:timeE];
	measureF = [lily getMeasureForTime:timeF];
	measureG = [lily getMeasureForTime:timeG];
	measureH = [lily getMeasureForTime:timeH];
	STAssertEqualObjects([NSNumber numberWithInt:measureA], [NSNumber numberWithInt:8], @"measureA wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureB], [NSNumber numberWithInt:5], @"measureB wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureC], [NSNumber numberWithInt:6], @"measureC wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureD], [NSNumber numberWithInt:7], @"measureD wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureE], [NSNumber numberWithInt:8], @"measureE wrong");	
	STAssertEqualObjects([NSNumber numberWithInt:measureF], [NSNumber numberWithInt:6], @"measureF wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureG], [NSNumber numberWithInt:8], @"measureG wrong");
	STAssertEqualObjects([NSNumber numberWithInt:measureH], [NSNumber numberWithInt:8], @"measureH wrong");	
	
}

-(void)testLockIndexOftimeInMeasure{


	double timeA = 5.7501, timeB = 3.601, timeC = 1.334, timeD = 4.1425, timeE = 0.8751, timeF = 1.8334 , timeG = 7.1251, timeH = 25.5001;
	int measureA=8, measureB=5, measureC=6, measureD=7, measureE=8, measureF=6, measureG=8, measureH=8;
	
	int lockindexA, lockindexB, lockindexC, lockindexD, lockindexE, lockindexF, lockindexG, lockindexH;
	
	lockindexA = [lily getLockIndexOfTime:timeA inMeasure:measureA];
	lockindexB = [lily getLockIndexOfTime:timeB inMeasure:measureB];
	lockindexC = [lily getLockIndexOfTime:timeC inMeasure:measureC];
	lockindexD = [lily getLockIndexOfTime:timeD inMeasure:measureD];
	lockindexE = [lily getLockIndexOfTime:timeE inMeasure:measureE];
	lockindexF = [lily getLockIndexOfTime:timeF inMeasure:measureF];
	lockindexG = [lily getLockIndexOfTime:timeG inMeasure:measureG];
	lockindexH = [lily getLockIndexOfTime:timeH inMeasure:measureH];
	
	STAssertEqualObjects([NSNumber numberWithInt:lockindexA], [NSNumber numberWithInt:6], @"lockA wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexB], [NSNumber numberWithInt:3], @"lockB wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexC], [NSNumber numberWithInt:2], @"lockC wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexD], [NSNumber numberWithInt:1], @"lockD wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexE], [NSNumber numberWithInt:7], @"lockE wrong");	
	STAssertEqualObjects([NSNumber numberWithInt:lockindexF], [NSNumber numberWithInt:5], @"lockF wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexG], [NSNumber numberWithInt:1], @"lockG wrong");
	STAssertEqualObjects([NSNumber numberWithInt:lockindexH], [NSNumber numberWithInt:4], @"lockH wrong");	
}

-(void)testquantizeQuince{

	//double start = [[quince valueForKey:@"start"]doubleValue];
	[lily fillGrid];
	double duration = 0.125;
	
	[lily quantizeQuince:quince];
	
	STAssertEqualObjects([NSNumber numberWithDouble:[[quince valueForKey:@"duration"]doubleValue]], [NSNumber numberWithDouble:duration], @"quantization of duration failed");	
	STAssertEqualObjects([NSNumber numberWithDouble:[[quince valueForKey:@"start"]doubleValue]], [NSNumber numberWithDouble:4.25], @"quantization of start failed");	
	
	[quince setValue:[NSNumber numberWithDouble:6.12] forKey:@"start"];
	[quince setValue:[NSNumber numberWithDouble:1.12] forKey:@"duration"];
	[lily quantizeQuince:quince];
	STAssertEqualObjects([NSNumber numberWithDouble:[[quince valueForKey:@"duration"]doubleValue]], [NSNumber numberWithDouble:1.125], @"second quantization of duration failed");	
	STAssertEqualObjects([NSNumber numberWithDouble:[[quince valueForKey:@"start"]doubleValue]], [NSNumber numberWithDouble:6.125], @"quantization of start failed");	

}

@end
