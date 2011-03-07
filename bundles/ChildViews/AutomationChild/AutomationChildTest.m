//
//  AutomationItemTest.m
//  quince
//
//  Created by max on 3/15/10.
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


#import "AutomationChildTest.h"

@implementation AutomationChildTest

-(void)setUp{
	
	
	item = [[ChildView alloc]init];
	
	
}


-(void)testCenter{
	
	[item setLocation:NSMakePoint(1, 1)];
	[item setWidth:6 withUpdate:NO];
	[item setHeight:6 withUpdate:YES];
	
	
	STAssertEqualObjects([NSNumber numberWithFloat:[item center].x], [NSNumber numberWithFloat:4],@"center X wrong!" );
	STAssertEqualObjects([NSNumber numberWithFloat:[item center].y], [NSNumber numberWithFloat:4],@"center Y wrong!" );
}




@end
