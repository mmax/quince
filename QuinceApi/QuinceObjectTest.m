//
//  QuinceObjectTest.h
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


#import "QuinceObjectTest.h"
#import <QuinceApi/QuinceObject.h>
//#import "QuinceObject.h"
#import <QuinceApi/QuinceObjectController.h>

@implementation QuinceObjectTest

 -(void)setUp{

	 quince = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	 [quince setDocument:(QuinceDocument *)self];
	[quince setValue:[NSNumber numberWithInt:1] forKey:@"start"];
	[quince setValue:@"testName" forKey:@"name"];
	[quince setValue:@"motherObject" forKey:@"description"];
	[quince setValue:[NSNumber numberWithDouble:2.5] forKey:@"duration"];
	
	QuinceObject * quinceChild =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	 [quinceChild setDocument:(QuinceDocument *)self];
	[quinceChild setValue:[NSNumber numberWithInt:3] forKey:@"start"];
	[quinceChild setValue:@"quinceChild" forKey:@"name"];
	[quinceChild setValue:@"childObject" forKey:@"description"];
	[quinceChild setValue:[NSNumber numberWithDouble:2.5] forKey:@"duration"];
	
	[[quince controller]addSubObjectWithController:[quinceChild controller] withUpdate:YES];
	
	quinceChild2 = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	[quinceChild2 setValue:[NSNumber numberWithInt:5] forKey:@"start"];
	[quinceChild2 setValue:[NSNumber numberWithInt:1] forKey:@"duration"];
	[quinceChild2 setValue:@"quinceChild2" forKey:@"name"];

}

 
-(void)testCopyWithZone{
	
	QuinceObject * quince2 = [quince copyWithZone:nil];
	QuinceObject * quince2Child = [[quince2 valueForKey:@"subObjects"]lastObject];
	QuinceObject * quinceChild = [[quince valueForKey:@"subObjects"]lastObject];
	
	STAssertNotNil(quince2, @"copied object is nil");
	STAssertNotNil(quince, @"quince s nil!");
	STAssertEqualObjects([quince valueForKey:@"name"], [quince2 valueForKey:@"name"], @"copying names failed");
	STAssertEqualObjects([quince valueForKey:@"start"], [quince2 valueForKey:@"start"], @"copying start failed");
	STAssertEqualObjects([quince valueForKey:@"duration"], [quince2 valueForKey:@"duration"], @"copying duration failed");
	STAssertEqualObjects([quince valueForKey:@"description"], [quince2 valueForKey:@"description"], @"copying description failed");	
	STAssertEqualObjects([quince valueForKey:@"type"], [quince2 valueForKey:@"type"], @"copying failed -> different types!");

	STAssertEqualObjects([quinceChild valueForKey:@"name"], [quince2Child valueForKey:@"name"], @"copying child names failed");
	STAssertEqualObjects([quinceChild valueForKey:@"start"], [quince2Child valueForKey:@"start"], @"copying child start failed");
	STAssertEqualObjects([quinceChild valueForKey:@"duration"], [quince2Child valueForKey:@"duration"], @"copying child duration failed");
	STAssertEqualObjects([quinceChild valueForKey:@"description"], [quince2Child valueForKey:@"description"], @"copying child description failed");
	STAssertEqualObjects([quinceChild valueForKey:@"type"], [quince2Child valueForKey:@"type"], @"copying child failed -> different type");

	[quince2Child addSubObject:[quince copyWithZone:nil] withUpdate:YES];
	QuinceObject * third = [[quince2Child valueForKey:@"subObjects"]lastObject];
	
	STAssertEqualObjects([quince valueForKey:@"name"], [third valueForKey:@"name"], @"third - copying names failed");
	STAssertEqualObjects([quince valueForKey:@"start"], [third valueForKey:@"start"], @"third - copying start failed");
	STAssertEqualObjects([quince valueForKey:@"duration"], [third valueForKey:@"duration"], @"third - copying duration failed");
	STAssertEqualObjects([quince valueForKey:@"description"], [third valueForKey:@"description"], @"third - copying description failed");	
	STAssertEqualObjects([quince valueForKey:@"type"], [third valueForKey:@"type"], @"third - copying failed -> different types!");
	
	QuinceObject * fourth = [[third valueForKey:@"subObjects"]lastObject];
	STAssertEqualObjects([quinceChild valueForKey:@"name"], [fourth valueForKey:@"name"], @"fourth - copying child names failed");
	STAssertEqualObjects([quinceChild valueForKey:@"start"], [fourth valueForKey:@"start"], @"fourth - copying child start failed");
	STAssertEqualObjects([quinceChild valueForKey:@"duration"], [fourth valueForKey:@"duration"], @"fourth - copying child duration failed");
	STAssertEqualObjects([quinceChild valueForKey:@"description"], [fourth valueForKey:@"description"], @"fourth - copying child description failed");
	STAssertEqualObjects([quinceChild valueForKey:@"type"], [fourth valueForKey:@"type"], @"fourth - copying child failed -> different type");
	
}
 

-(void)testSubObjectsCount{

	STAssertEqualObjects([NSNumber numberWithInt:[quince subObjectsCount]], [NSNumber numberWithInt:1], @"error in subObjectsCount");
	QuinceObject * quince2 = [quince copyWithZone:nil];
	STAssertEqualObjects([NSNumber numberWithInt:[quince2 subObjectsCount]], [NSNumber numberWithInt:1], @"error in subObjectsCount after copying");
} 



 -(void)testIsOneOfTypesInArray{

	NSArray * types = [NSArray arrayWithObjects:@"MintFile", @"test", @"QuinceObject", nil];
	NSArray * noTypes = [NSArray arrayWithObjects:@"MintFile", @"test", @"Nothing", nil];
	
	QuinceObject * quince2 = [[QuinceObject alloc]init];
	
	BOOL a = [quince isOneOfTypesInArray:types];	// should be YES
	BOOL c = [quince isOneOfTypesInArray:noTypes];// should be NO		
	BOOL e = [quince2 isOneOfTypesInArray:noTypes];// should be NO	
	BOOL f = [quince2 isOneOfTypesInArray:types];// should be YES

	STAssertEqualObjects([NSNumber numberWithBool:a], [NSNumber numberWithBool:YES], @"typecheck a failed");
	STAssertEqualObjects([NSNumber numberWithBool:c], [NSNumber numberWithBool:NO],	 @"typecheck c failed");
	STAssertEqualObjects([NSNumber numberWithBool:e], [NSNumber numberWithBool:NO],  @"typecheck e failed");
	STAssertEqualObjects([NSNumber numberWithBool:f], [NSNumber numberWithBool:YES], @"typecheck f failed");
	 NSLog(@"%@", [quince2 type]);
	
}
 
 -(void)testGetType{

	NSString * type = [quince getType];
	STAssertEqualObjects(type, @"QuinceObject", @"getType - wrong type!");
} 

 -(void)testGetSuperType{

	NSString * superType = [quince getSuperType];
	STAssertEqualObjects(superType, @"QuinceObject", @"getSuperType - wrong type!");
	QuinceObject * quince2 = [[QuinceObject alloc]init];
	superType = [quince2 getSuperType];
	STAssertEqualObjects(superType, @"QuinceObject", @"getSuperType - QuinceObject - wrong type!");
}
 
 /* -(void)testAddSubObjectWithUpdates{

    //int duration = 6; // should be
    //[quince addSubObject:quinceChild2 withUpdate:YES];
    //STAssertEqualObjects([NSNumber numberWithInt:duration], [quince valueForKey:@"duration"], @"adding sub - duration update didn't work");
 }
  */
 -(void)testRemoveSubObjectWithUpdates{
	
		
	QuinceObject * sub = [[quince valueForKey:@"subObjects"]lastObject];
	[quince addSubObject:quinceChild2 withUpdate:YES];	
	[quince removeSubObject:quinceChild2 withUpdate:YES];
	float duration = 5.5; // should be
	
	
	STAssertEqualObjects([sub end], [NSNumber numberWithFloat:duration], @"subMint has wrong end time");
	STAssertEqualObjects([NSNumber numberWithInt:[quince subObjectsCount]], [NSNumber numberWithInt:1], @"all sub objects disappeared");
	STAssertEqualObjects([quince duration],[NSNumber numberWithFloat:duration], @"removing sub - duration update didn't work");
	

}
 

 -(void)testRemoveSubObjectWithOutUpdates{
	[quince addSubObject:quinceChild2 withUpdate:YES];
	
	[quince removeSubObject:quinceChild2 withUpdate:NO];
	float duration = 6; // should be
	STAssertEqualObjects([NSNumber numberWithFloat:duration], [quince valueForKey:@"duration"], @"removing sub without update - duration update took place anyway");
}

 
 /* -(void)testFoldObjects{

   [quince addSubObject:quinceChild2 withUpdate:YES];
   float dur = [[quince duration] floatValue];
   int start = [[quince valueForKey:@"start"]intValue];
   
   NSMutableArray * subs = [NSArray arrayWithArray:[quince objectForKey:@"subObjects"]];
   QuinceObject * folded = [quince foldObjects:subs];

   STAssertEqualObjects([NSNumber numberWithInt:[quince subObjectsCount]], [NSNumber numberWithInt:1], @"folding  - quince should have 1 sub object");
   STAssertEqualObjects([NSNumber numberWithInt:[folded subObjectsCount]], [NSNumber numberWithInt:2], @"folding  - _folded_ should have 2 sub objects");	
   STAssertEqualObjects([folded valueForKey:@"duration"], [NSNumber numberWithInt:3], @"folding  - duration of _folded_ wrong");
   STAssertEqualObjects([folded valueForKey:@"start"], [NSNumber numberWithInt:3], @"folding  - start of _folded_ wrong");
   STAssertEqualObjects([quince valueForKey:@"start"], [NSNumber numberWithInt:start], @"folding  - start of _quince changed! ");
   STAssertEqualObjects([quince valueForKey:@"duration"], [NSNumber numberWithFloat:dur], @"folding  - duration of quince shouldn't have changed");	
} */

/* -(void)testUnfoldObject{

	[quince addSubObject:quinceChild2 withUpdate:YES];
	float dur = [[quince duration] floatValue];
	
	NSArray * subs = [NSArray arrayWithArray:[quince objectForKey:@"subObjects"]];
	QuinceObject * folded = [quince foldObjects:subs];
	
	[quince unfoldObject:folded];
	STAssertEqualObjects([NSNumber numberWithInt:[quince subObjectsCount]], [NSNumber numberWithInt:2], @"unfolding  - quince should have 2 sub object");
	STAssertEqualObjects([NSNumber numberWithFloat: dur], [quince duration], @"unfolding  - duration changed!");	
} */

-(void)testSubObjectsRangeForKey{
	[quince addSubObject:quinceChild2 withUpdate:YES];
	
	NSSize rangeStart = [[quince subObjectsRangeForKey:@"start"]sizeValue];
	
	NSNumber * minStart = [NSNumber numberWithInt:3];
	NSNumber * maxStart = [NSNumber numberWithInt:5];
	
	NSSize rangeDur = [[quince subObjectsRangeForKey:@"duration"]sizeValue];
	
	NSNumber * minDur = [NSNumber numberWithInt:1];
	NSNumber * maxDur = [NSNumber numberWithFloat:2.5];
	
	STAssertEqualObjects(minStart, [NSNumber numberWithFloat:rangeStart.width], @"error in minimum start range ");
	STAssertEqualObjects(maxStart, [NSNumber numberWithFloat:rangeStart.height], @"error in maximum start range ");	
	STAssertEqualObjects(minDur, [NSNumber numberWithFloat:rangeDur.width], @"error in minimum duration range ");
	STAssertEqualObjects(maxDur, [NSNumber numberWithFloat:rangeDur.height], @"error in maximum duration range ");	
} 

-(void)testSortByKey{

	[quince addSubObject:quinceChild2 withUpdate:YES];
	[quince sortByKey:@"duration" ascending:YES];
	float durAAsc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"duration"]floatValue];
	float durBAsc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:1]valueForKey:@"duration"]floatValue];
	BOOL durAsc = durBAsc>durAAsc?YES:NO;

	[quince sortByKey:@"duration" ascending:NO];
	float durADesc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"duration"]floatValue];
	float durBDesc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:1]valueForKey:@"duration"]floatValue];
	BOOL durDesc = durBDesc<durADesc?YES:NO;

	
	[quince sortByKey:@"start" ascending:YES];
	float startAAsc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"start"]floatValue];
	float startBAsc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:1]valueForKey:@"start"]floatValue];
	BOOL startAsc = startBAsc>startAAsc?YES:NO;

	[quince sortByKey:@"start" ascending:NO];
	float startADesc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:0]valueForKey:@"start"]floatValue];
	float startBDesc = [[[[quince valueForKey:@"subObjects"]objectAtIndex:1]valueForKey:@"start"]floatValue];
	BOOL startDesc = startBDesc<startADesc?YES:NO;
	
	
	STAssertTrue(durAsc, @"sorting by duration ascending failed");
	STAssertTrue(durDesc, @"sorting by duration descending failed");
	STAssertTrue(startAsc, @"sorting by start ascending failed");
	STAssertTrue(startDesc, @"sorting by start descending failed");
}

-(void)testQuinceObjectWithValueForKey{

	[quince addSubObject:quinceChild2 withUpdate:NO];
	STAssertEquals([quince objectWithValue:[quinceChild2 valueForKey:@"id"] forKey:@"id"], quinceChild2, @"not equal!");

}

-(void)testFlatten{
	QuinceObject* testMint = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];//[[QuinceObject alloc]init];
	QuinceObject * child3 = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	[child3 setValue:@"child3" forKey:@"name"];
	
	[testMint setValue:@"testMint" forKey:@"name"];
	QuinceObject * childChild = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	[childChild setValue:@"childChild" forKey:@"name"];
	[[quinceChild2 controller]addSubObjectWithController:[childChild controller] withUpdate:NO];//[quinceChild2 addSubObject:childChild withUpdate:NO];
	[[quinceChild2 controller]addSubObjectWithController:[child3 controller] withUpdate:NO];//[quinceChild2 addSubObject:child3 withUpdate:NO];
//	NSLog(@"quinceChild2: %@",[quinceChild2 description]);
	
//	return;
	STAssertTrue(child3 != nil, @"child3 does not exist!");
	STAssertTrue([[child3 controller]content] != nil, @"child3 controller content does not exist!");
	STAssertEqualObjects([NSNumber numberWithInt:2], [NSNumber numberWithInt:[quinceChild2 subObjectsCount]], @"quinceChild should have a subObject!");
	[[testMint controller] addSubObjectWithController:[quinceChild2 controller] withUpdate:NO];
	STAssertEqualObjects([NSNumber numberWithBool:[testMint containsFoldedSubObjects]], [NSNumber numberWithBool:YES], @"quince should contain a folded subObject!");
	int subCount = [testMint subObjectsCount];
	[testMint flatten];
	STAssertEqualObjects([NSNumber numberWithInt:[testMint subObjectsCount]], [NSNumber numberWithInt:subCount+1], @" - flatten failed");

}

 -(void)testStartOffset{

	NSArray * subs = [quince valueForKey:@"subObjects"];
	QuinceObject * quinceChild = [subs lastObject];
	[quince setValue:[NSNumber numberWithInt:3] forKey:@"start"];
	
	 NSNumber * ist = [[subs lastObject]offsetForKey:@"start"];
	NSNumber * soll = [quince valueForKey:@"start"];
	
	STAssertEqualObjects(ist, soll, @"first order startOffset wrong!");
	
	
	[[quinceChild controller]addSubObjectWithController:[quinceChild2 controller] withUpdate:YES];
	[quinceChild setValue:[NSNumber numberWithInt:3] forKey:@"start"];
	
	ist = [quinceChild2 offsetForKey:@"start"];
	soll = [NSNumber numberWithInt:6];
	
	STAssertEqualObjects(ist, soll, @"second order startOffset wrong!");
	
	[quinceChild2 setValue:[NSNumber numberWithInt:3] forKey:@"start"];
	
	QuinceObject  * quinceChild3 = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	[quinceChild3 setValue:[NSNumber numberWithInt:5] forKey:@"start"];
	[quinceChild3 setValue:[NSNumber numberWithInt:1] forKey:@"duration"];
	[quinceChild3 setValue:@"quinceChild2" forKey:@"name"];
	
	[[quinceChild2 controller]addSubObjectWithController:[quinceChild3 controller] withUpdate:YES];
	ist = [quinceChild3 offsetForKey:@"start"];
	soll = [NSNumber numberWithInt:9];
	
	STAssertEqualObjects(ist, soll, @"third order startOffset wrong!");
	
}

-(void)testAmpltude{


	[quince setValue:[NSNumber numberWithInt:0] forKey:@"volume"];
	NSNumber * ist = [quince amplitude];
	NSNumber * soll = [NSNumber numberWithInt:1];
	STAssertEqualObjects(ist, soll, @"amplitude conversion failed!");
	[quince setValue:[NSNumber numberWithInt:-20] forKey:@"volume"];
	ist = [quince amplitude];
	soll = [NSNumber numberWithFloat:0.1];
	
}
 

-(void)testIsSuperOf{

	BOOL b;
	QuinceObject * child = [[quince valueForKey:@"subObjects"]lastObject];
	b = [quince isSuperOf:child];
	STAssertTrue(b, @"mom is not super of her child!");


	QuinceObject * quinceChild =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[[child controller]addSubObjectWithController:[quinceChild controller] withUpdate:YES];
	
	b = [quince isSuperOf:quinceChild];
	STAssertTrue(b, @"grandma is not super of her child's child!");

	QuinceObject * quinceChildChild =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];

	
	[[quinceChild controller]addSubObjectWithController:[quinceChildChild controller] withUpdate:YES];
	
	b = [quince isSuperOf:quinceChildChild];
	STAssertTrue(b, @"grandgrandma is not super of her child's child's child!");
	
	QuinceObject * quinceChildChildChild =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[[quinceChildChild controller]addSubObjectWithController:[quinceChildChildChild controller] withUpdate:YES];
	
	b = [quince isSuperOf:quinceChildChild];
	STAssertTrue(b, @"grandgrandgrandma is not super of her child's child's child's child!");

}

-(void)testIsEqualTo{

	quince = [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[quince setValue:@"testNamae" forKey:@"name"];
	[quince setValue:@"description" forKey:@"description"];
	[quince setValue:[NSNumber numberWithFloat:0.3] forKey:@"start"];
	[quince setValue:[NSNumber numberWithFloat:3.2] forKey:@"duration"];

	QuinceObject * q2 =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[q2 setValue:[quince valueForKey:@"date"]forKey:@"date"];
	[q2 setValue:@"testNamae" forKey:@"name"];
	[q2 setValue:@"description" forKey:@"description"];
	[q2 setValue:[NSNumber numberWithFloat:0.3] forKey:@"start"];
	[q2 setValue:[NSNumber numberWithFloat:3.2] forKey:@"duration"];
	
	BOOL b = [quince isEqualTo:q2];
	
	STAssertTrue(b, @"first should be equal!");
	
	[q2 setValue:[NSNumber numberWithFloat: 4.5] forKey:@"duration"];
	
	b = [quince isEqualTo:q2];
	STAssertFalse(b, @"second should be false!");
	
	[quince setValue:[NSNumber numberWithFloat:3.2] forKey:@"duration"];
	[q2 setValue:[NSNumber numberWithFloat:3.2] forKey:@"duration"];
	
	b = [quince isEqualTo:q2];
	
	STAssertTrue(b, @"third should be equal!");	
	
	[q2 setValue:@"anyValue" forKey:@"anyKey"];
	
	
	b = [quince isEqualTo:q2];
	STAssertFalse(b, @"fourth additional parameter should be false!");

	QuinceObject * child =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[q2 addSubObject:child withUpdate:YES];
	b = [quince isEqualTo:q2];
	STAssertFalse(b, @"fifth subObject! should be false!");

	QuinceObject * child2 =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	QuinceObject * child3 =  [[self controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];
	
	[quince addSubObject:child2 withUpdate:YES];

	
	b = [quince isEqualTo:q2];
	STAssertFalse(b, @"sixth equal number of subObjects should be false (date should be different)!");
	
	[quince addSubObject:child3 withUpdate:YES];
	
	b = [quince isEqualTo:q2];
	STAssertFalse(b, @"seventh  differet number of subObjects should be false!");


}


-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool{
	QuinceObject * m = [self newObjectOfClassNamed:name];
	//if(addToPool)[self addObjectToObjectPool:quince];
	QuinceObjectController * mc = [[QuinceObjectController alloc]initWithContent:m];
	[mc setDocument:(QuinceDocument *)self];
	[m setController:mc];
	return mc;
}

-(QuinceObject *)newObjectOfClassNamed:(NSString *)className{
	
	QuinceObject * m = [[NSClassFromString(className) alloc]init];
	[m setDocument:(QuinceDocument *)self];
	return m;
	
}



@end
