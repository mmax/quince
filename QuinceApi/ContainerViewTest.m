//
//  ContainerViewTest.m
//  quince
//
//  Created by max on 3/14/10.
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


#import "ContainerViewTest.h"
#import <QuinceApi/ContainerView.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/ChildView.h>
#import <QuinceApi/ContainerView.h>
#import <QuinceApi/QuinceObjectController.h>

@implementation ContainerViewTest


-(void)setUp{


	view = [[ContainerView alloc]initWithFrame:NSMakeRect(0, 0, 100, 100)];	
	[view setContentController:[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]];
	[view setValue: [NSNumber numberWithInt:10] forKey:@"yAxisHeadRoom" ];
	[view setValue: [NSNumber numberWithInt:1] forKey:@"pixelsPerUnitY" ]; 
	[view setValue: [NSNumber numberWithInt:1] forKey:@"pixelsPerUnitX" ]; 
	//[view setStripController:(StripController *)self];
	[view setLayerController:(LayerController *)self];
	quince = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	[quince setValue:[NSNumber numberWithInt: 1] forKey:@"start"];
	[quince setValue:[NSNumber numberWithInt: 2] forKey:@"duration"];
	[quince setValue:[NSNumber numberWithInt: -6] forKey:@"volume"];

}

 -(void)testItemCreation{

	 QuinceObject * m = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	 [m setValue:@"testName" forKey:@"name"];
	 NSString * name = [[m controller]valueForKeyPath:@"selection.name"];
	 STAssertEqualObjects(name, [m valueForKey:@"name"], @"setting value directly and getting it via controller selection keypath failed!");

	ChildView * item = 	[view createChildViewForQuinceObjectController:[quince controller]];
	BOOL b = item ? YES : NO;
	STAssertTrue(b, @"testItemCreation: no valid item created");
	NSNumber * soll = [NSNumber numberWithFloat:1];
	NSNumber * ist = [NSNumber numberWithFloat:[item location].x];
	STAssertEqualObjects(ist, soll, @"wrong location");

	 // setting location via conversion method
	 soll = [NSNumber numberWithFloat:3];

	
	 [item setValue: soll forKey:@"start"];
	// [item didChangeValueForKey:@"start"];
	 
	 ist = [NSNumber numberWithInt:[item location].x];
	 STAssertEqualObjects(ist, soll, @"setting item's x-location via parameter key ('start') failed!");
	 
	[view clear];
	
	/* item = [view createSubObjectAtPoint:NSMakePoint(1, 7)];
		ist = [NSNumber numberWithFloat:[item location].x];
		soll = [NSNumber numberWithFloat:1];
		STAssertEqualObjects(ist, soll, @"created item at wrong x coordinate");
		 ist = [NSNumber numberWithFloat:[item location].y];
		 soll = [NSNumber numberWithFloat:7];
		 STAssertEqualObjects(ist, soll, @"created item at wrong y coordinate");
		
	 	//item = [[view items]lastObject];
	QuinceObject * quinceB = [[item controller]content];
	soll = [NSNumber numberWithInt:-83];
	ist = [quinceB valueForKey:@"volume"];
	 if(ist == NSNoSelectionMarker)
		 NSLog(@"MintViewTest:testItemCreation: no selection in controller, no value returned");
	 
	 STAssertEqualObjects(ist, soll, @"item creation at point did result in wrong volume value in quince");*/
	 QuinceObject * quinceB = [[item controller]content];

	 soll = [NSNumber numberWithInt:1];
	 ist = [quinceB valueForKey:@"start"];
	 STAssertEqualObjects(ist, soll, @"item creation at point did result in wrong start value in quince");
	 
	 
	b = item!=nil ? YES : NO;
	STAssertTrue(b, @"no valid item created");
	 b = quinceB!=nil ? YES : NO;
	STAssertTrue(b, @"quinceB is nil!"); 
	 
	 
	 soll = [NSNumber numberWithInt:0];
	 [quinceB setValue:soll forKey:@"volume"];
	 
	 // quinceB's Volume is now set to 0
	 // the item's location.y value should be 90
	 [quinceB updateOffsetForKey:@"volume"];
	 ist = [quinceB valueForKey:@"volumeOffset"];
	 
	 STAssertEqualObjects(ist, soll, @"after setting volume - volumeOffset wrong");
	 
	 soll = [NSNumber numberWithInt:90];
	 ist = [NSNumber numberWithInt:[item location].y];
	 STAssertEqualObjects(ist, soll, @"setting volume in quince did not set location of item correctly");
	 ist = [item valueForKey:@"volume"];
 	 /* soll = [NSNumber numberWithInt:0];
		  STAssertEqualObjects(ist, soll, @"setting volume in quince did not set volume of item correctly");
		   */
	 // trying set start in quince:
	 soll = [NSNumber numberWithFloat:1];
	 [quinceB setValue:soll forKey:@"start"];
	 ist = [NSNumber numberWithFloat:[item location].x];
	 STAssertEqualObjects(ist, soll, @"setting start in quince did not set location of item correctly ");

	 [view clear];
	 /* item = [view createSubObjectAtPoint:NSMakePoint(366, 89)];
	   [item setWidth:4];
	   [item setHeight:4];
	   STAssertEqualObjects([NSNumber numberWithInt:4], [NSNumber numberWithFloat:[item width]], @"setting width did not work!");
	   STAssertEqualObjects([NSNumber numberWithFloat:[item center].x], [NSNumber numberWithFloat:366 + [item width]*.5], @"in item creation test - item center.x wrong value" );
		
		
		[view clear];
		item = [view createSubObjectAtPoint:NSMakePoint(123, 69)];
		quinceB = [[item controller]content];
		soll = [NSNumber numberWithFloat:0];
		ist = [quinceB valueForKey:@"duration"];
		STAssertEqualObjects(ist, soll, @"creating item did result in wrong duration in quince");
		soll = [NSNumber numberWithFloat:[item minimumWidth]];
		ist= [NSNumber numberWithFloat:[item width]];
		STAssertEqualObjects(ist, soll, @"creating item did result in wrong item with"); */
	 
}
-(void)testResize{
	
	
	[view clear];
	[view createChildViewForQuinceObjectController:[quince controller]];
	
	ChildView * item = [[view childViews ]lastObject];
	
	
	[item setWidth:6 withUpdate:NO];
	[item setHeight:6 withUpdate:YES];
	
	float x = [item location].x;		
	float w = [item width];
	float y = [item location].y;
	float h = [item height];
	
	[item resize:[NSValue valueWithSize:NSMakeSize(1, 1)]];
	
	STAssertEqualObjects([NSNumber numberWithInt:x], [NSNumber numberWithInt:[item location].x], @"resize changes location on X Axis");
	STAssertEqualObjects([NSNumber numberWithInt:y], [NSNumber numberWithInt:[item location].y], @"resize changes location on Y Axis");
	
	if([view allowsHorizontalResize] && [item allowsHorizontalResize])
		STAssertEqualObjects([NSNumber numberWithInt:w+1], [NSNumber numberWithInt:[item width]], @"resize doesn't work on X Axis");
	if([view allowsVerticalResize])
		STAssertEqualObjects([NSNumber numberWithInt:h+1], [NSNumber numberWithInt:[item height]], @"resize (with vertical resize) doesn't work on Y Axis");	
	else
		STAssertEqualObjects([NSNumber numberWithInt:h], [NSNumber numberWithInt:[item height]], @"resize (without vertical resize) doesn't  work on Y Axis");
	
}



 -(void)testMovement{
	
	[view clear];
	[view createChildViewForQuinceObjectController:[quince controller]];
	ChildView * item = [[view childViews]lastObject];
	BOOL b = item ? YES : NO;
	STAssertTrue(b, @"testMovement: no valid item created");
	[view selectAll:nil];
	float y = [item location].y;
	float x = [item location].x;
	[view moveSelectionByX:3 andY:0];
	STAssertEqualObjects([NSNumber numberWithFloat:y], [NSNumber numberWithFloat: [item location].y], @"moving X did move in Y");
	
	STAssertEqualObjects([NSNumber numberWithFloat:x+3], [NSNumber numberWithFloat: [item location].x], @"moving X ->  wrong location");
	
	y = [item location].y;
	x = [item location].x;
	
	[view moveSelectionByX:0 andY:3];
	
	STAssertEqualObjects([NSNumber numberWithFloat:[item location].x], [NSNumber numberWithFloat:x], @"moving Y did move X!");
	STAssertEqualObjects([NSNumber numberWithFloat:[item location].y],[NSNumber numberWithFloat:y+3],  @"moving Y -  wrong location");
	
} 

-(ChildView *)newChildViewOfClassNamed:(NSString *)s{
	
	return [[ChildView alloc]init];
}

-(QuinceObject *)newQuinceObjectOfClassNamed:(NSString *)s{
	return [[QuinceObject alloc]init];
}

-(void)redrawAllViewsOfStripWithView:(ContainerView *)aView inRect:(NSRect)r{
	
}

-(BOOL)loadObject:(QuinceObject *) model intoView:(ContainerView *)view{
	
	
	return YES;
}
-(void)addObjectToObjectPool:(QuinceObject *)quince{}

-(id)valueForKey:(NSString *)key{
	//NSLog(@"MintViewTest:valueForKey:%@", key);
	if([key isEqualToString: @"content"])
		return quince;
	if([key isEqualToString:@"isFolded"])
		return [NSNumber numberWithBool:NO];
	
	else return nil;
}

-(id)valueForKeyPath:(NSString *)keyPath{
	NSLog(@"MintViewTest:valueForKeyPath:%@", keyPath);
	return [self valueForKey:keyPath];
}

-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool{
	QuinceObject * m = [self newQuinceObjectOfClassNamed:name];
	QuinceObjectController * mc = [[QuinceObjectController alloc]initWithContent:m];
	[m setController:mc];
	
	
	//if(addToPool)[self addObjectToObjectPool:quince];
	return mc;
}



@end
