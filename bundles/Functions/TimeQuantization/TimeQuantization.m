//
//  TimeQuantization.m
//  quince
//
//  Created by max on 3/26/10.
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

#import "TimeQuantization.h"

@implementation TimeQuantization


-(void)perform{
	
	QuinceObject * seq = [self objectForPurpose:@"victim"], * grid = [self objectForPurpose:@"grid"];
	QuinceObjectController * resultController = [[self outputObjectOfType:@"QuinceObject"]controller];//[document controllerForNewQuinceObjectOfClassNamed:[seq className] inPool:NO];//[document newQuinceObjectOfClassNamed:[seq className]];
	long index=0, i=0;
	
	[self copyParamsOf:seq into:[resultController content]];
	
	if([[grid end]doubleValue] <= [[seq end]doubleValue])
		grid = [self createGridRepetitions];
	
	[document setProgressTask:@"Quantizing..."];
	[document setProgress:0];
	[document displayProgress:YES];
	
	[grid sortChronologically];
	[seq sortChronologically];
	
	startOffset = [[seq valueForKey:@"start"]doubleValue]+ [[seq offsetForKey:@"start"]doubleValue];
	//  NSLog(@"quantizing object: %@\n startOffset: %f", [seq dictionary], startOffset);
	
	for(QuinceObject * sub in [seq valueForKey:@"subObjects"]){
		QuinceObject * candidate = [sub copyWithZone:nil];
		index = [self quantizeMint:candidate withGrid:grid startSearchAt:index];
		[resultController addSubObjectWithController:[candidate controller] withUpdate:NO];
		[document setProgress:100.0/[seq subObjectsCount]*i++];
	}
	
	[resultController update];
	[resultController setValue:[NSString stringWithFormat:@"%@_TQ", [seq valueForKey:@"name"]] forKeyPath:@"selection.name"];
	//[resultController setValue:[[[seq valueForKey:@"start"]copy]autorelease] forKeyPath:@"selection.start"];
	//[document addObjectToObjectPool:[resultController content]];
	[document displayProgress:NO];
	[self done];
	
}

-(long)quantizeMint:(QuinceObject *)candidate withGrid:(QuinceObject *)grid startSearchAt:(long)index{


//	double , startOffset = [[candidate offsetForKey:@"start"]doubleValue];
//	NSLog(@"TimeQuantization: quantizeMint: startOffset %f", startOffset);
	double a, deltaA, b, deltaB, aFrac, bFrac, start = [[candidate valueForKey:@"start"]doubleValue]+ startOffset;
	double deltaDur, duration = [[candidate valueForKey:@"duration"]doubleValue], end = [[candidate end]doubleValue]+startOffset;
	long i, nextIndex, aInt, bInt;
	NSArray * subObjects = [grid valueForKey:@"subObjects"];
	
	// quantizing start
	for(i=index>0?index:0;i<[subObjects count];i++){
		b = [[[subObjects objectAtIndex:i]valueForKey:@"start"]doubleValue];
		if(b>start && i>0){
			a = [[[subObjects objectAtIndex:i-1]valueForKey:@"start"]doubleValue];
			deltaA = start-a;
			deltaB = b-start;
			if (deltaA > deltaB){
				deltaDur = deltaB;
				start = b;
			}
			else {
				deltaDur = deltaA * -1;
				start = a; // -> end should not be changed! -> need to adjust duration...
			}
			[candidate setValue:[NSNumber numberWithDouble:start] forKey:@"start"];
			[candidate setValue:[NSNumber numberWithDouble:duration + deltaDur] forKey:@"duration"];
			nextIndex = i-1;
			break;
		}
		else if(b>start && i==0){
			NSLog(@"TimeQuantization: something went awfully wrong! ->->");
			NSLog(@"start: %f b: %f i: %ld", start, b, i);
		}
	}
	
	//int endIntegerPart = end;
	//double endFractionalPart = end-endIntegerPart;
	
	// quantizing duration
	for(i=0;i<[subObjects count];i++){
		b = [[[subObjects objectAtIndex:i]valueForKey:@"start"]doubleValue];
		
		//if(b>endFractionalPart && i>0){
		if(b>end && i>0){
			start = [[candidate valueForKey:@"start"]doubleValue];
			a = [[[subObjects objectAtIndex:i-1]valueForKey:@"start"]doubleValue];
			aInt = a;
			aFrac = a - aInt;
			bInt = b;
			bFrac = b-bInt;
			deltaA = end -a;//endFractionalPart-a;
			deltaB = b-end;//endFractionalPart;

			if (deltaA > deltaB) duration = b-start;//(b+endIntegerPart)-start;
			else duration = a-start;//(a+endIntegerPart)-start;
			//NSLog(@"end: %f, endFrac: %f, a: %f, b: %f, deltaA: %f, deltaB: %f, start: %f, duration: %f", end, endFractionalPart, a, b, deltaA, deltaB, start, duration);
			[candidate setValue:[NSNumber numberWithDouble:duration] forKey:@"duration"];
			if(duration > 0)//??
				break;
		}
	}
			
	return nextIndex;
}


-(QuinceObject *)createGridRepetitions{
	
	[document setIndeterminateProgressTask:@"creating extended grid..."];
	[document displayProgress:YES];


	QuinceObject * seq = [self objectForPurpose:@"victim"];
	QuinceObject * grid = [self objectForPurpose:@"grid"];
	QuinceObject * longGrid = [document newObjectOfClassNamed:[grid className]];
	double start, gridDur = [[grid valueForKey:@"duration"]doubleValue];
	int repetitions = 0;
	
	while ([[longGrid end]doubleValue] < [[seq end]doubleValue]) {
		QuinceObject * gridCopy = [grid copyWithZone:nil];
		start = repetitions*gridDur;
		[gridCopy delayStartBy:start];
		[longGrid addSubObject:gridCopy withUpdate:YES];
		repetitions++;
	}
	[longGrid flatten];
	[longGrid sortChronologically];
	[longGrid setValue:@"extended grid" forKey:@"name"];
	[document addObjectToObjectPool:longGrid];
	return longGrid;	
}

-(BOOL)wantsFunctionLoader{return NO;}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"grid" forKey:@"purpose"];
	[dictA setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"victim" forKey:@"purpose"];
	[dictB setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}


-(void)copyParamsOf:(QuinceObject*)source into:(QuinceObject*)target{

	NSMutableArray * keys = [NSMutableArray arrayWithArray:[source allKeys]];
	
	for(NSString * key in keys){
	
		if(![key isEqualToString:@"subObjects"] && 
		   ![key isEqualToString:@"id"] &&
		   ![key isEqualToString:@"type"] &&
		   ![key isEqualToString:@"name"] &&
		   ![key isEqualToString:@"date"]){
			[target setValue:[[source valueForKey:key]copy] forKey:key];
		}
	}
}

@end
