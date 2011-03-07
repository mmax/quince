//
//  FunctionGraph.m
//  quince
//
//  Created by max on 6/1/10.
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

#import "FunctionGraph.h"


@implementation FunctionGraph

/*
- source
 
- target 
 
- targetPurpose
 
 */

-(BOOL)isReady{

	if(![self valueForKey:@"source"])return NO;
	if(![self valueForKey:@"target"])return NO;
	if(![self valueForKey:@"targetPurpose"])return NO;
	if(![self valueForKey:@"targetType"])return NO;
	return YES;
}

-(void)reset{
	[super reset];	
}

/* -(NSString *)sourceName{

	MintFunction * fun = [self valueForKey:@"source"];
	
	if(!fun)
		return nil;
	
	if([fun isKindOfClass:NSClassFromString(@"FunctionGraph")]){
		return [(FunctionGraph *)fun sourceName];
	}
	return [fun valueForKey:@"name"];
} */

-(NSMutableArray *)inputDescriptors{

	
	Function * source = [self valueForKey:@"source"];
	Function * target = [self valueForKey:@"target"];

	NSMutableArray * inputDescriptors = [[NSMutableArray alloc]init];

	NSMutableArray * sourceDescriptors = [NSMutableArray arrayWithArray:[source inputDescriptors]];
	NSMutableArray * targetDescriptors = [NSMutableArray arrayWithArray:[target inputDescriptors]];

	//NSLog(@"%@: %@: ‘inputDescriptors:’ sourceDescriptors: %@", [self className], [self valueForKey:@"name"], sourceDescriptors);
	[self setValue:sourceDescriptors forKey:@"sourceDescriptors"];


	for(NSDictionary * dict in targetDescriptors){
	
		if([[dict valueForKey:@"purpose"]isEqualToString:[self valueForKey:@"targetPurpose"]]){
			[self setValue:[dict valueForKey:@"type"]forKey:@"targetType"];
			[targetDescriptors removeObject:dict];
			break;
		}
	}
	
	[self setValue:targetDescriptors forKey:@"targetDescriptors"];
	
	for(NSDictionary * dict in sourceDescriptors){
		if([source isKindOfClass:NSClassFromString(@"FunctionGraph")])
			[dict setValue:[NSString stringWithFormat:@"%@.%@", [source valueForKey:@"name"], [dict valueForKey:@"functionPath"]] forKey:@"functionPath"];
		else
			 [dict setValue:[source valueForKey:@"name"]forKey:@"functionPath"];
	}
	
	for(NSDictionary * dict in targetDescriptors){
		if([target isKindOfClass:NSClassFromString(@"FunctionGraph")])
			[dict setValue:[NSString stringWithFormat:@"%@.%@", [target valueForKey:@"name"], [dict valueForKey:@"functionPath"]] forKey:@"functionPath"];
		else
			[dict setValue:[target valueForKey:@"name"] forKey:@"functionPath"];
		/* if(![dict valueForKey:@"graphName"])
			[dict setValue:[self valueForKey:@"name"]forKey:@"graphName"];
		 */
	}
	//NSLog(@"inputDescriptors: targetDescriptors: %@", targetDescriptors);
	
	[inputDescriptors addObjectsFromArray:sourceDescriptors];
	[inputDescriptors addObjectsFromArray:targetDescriptors];
	
	//NSLog(@"%@: %@: complete inputDescriptors: %@", [self className], [self valueForKey:@"name"], inputDescriptors);
	return [inputDescriptors autorelease];
}

-(void)performActionWithInputDescriptors:(NSArray *)inputDescriptors{
	
	
	if(![self isReady]){
		NSLog(@"%@: performActionWithInputDescriptors: not ready!");
		return;
	}
	
	//NSLog(@"%@: %@: performActionWithInputDescriptors: %@", [self className], [self valueForKey:@"name"],  inputDescriptors);
	
	
	Function * source = [self valueForKey:@"source"];
	[source reset];
	
	NSMutableArray * sourceDescriptors = [[NSMutableArray alloc]init];
	for(NSDictionary * dict in inputDescriptors){
		NSArray * pathComponents = [[dict valueForKey:@"functionPath"]componentsSeparatedByString:@"."];
		if([[pathComponents objectAtIndex:0]isEqualToString:[source valueForKey:@"name"]]){
//		if([[dict valueForKey:@"functionName"]isEqualToString:[source valueForKey:@"name"]])
			[dict setValue:[self stripFirstComponentFromFunctionPath:[dict valueForKey:@"functionPath"]] forKey:@"functionPath"];
			[sourceDescriptors addObject:dict];
		}
	}
	
	//NSLog(@"%@: sourceDescriptors: %@", [self className], sourceDescriptors);

	Function * target = [self valueForKey:@"target"];
	NSMutableArray * targetDescriptors = [[NSMutableArray alloc]init];
	for(NSDictionary * dict in inputDescriptors){
		NSArray * pathComponents = [[dict valueForKey:@"functionPath"]componentsSeparatedByString:@"."];
		if([[pathComponents objectAtIndex:0]isEqualToString:[target valueForKey:@"name"]]){
			[dict setValue:[self stripFirstComponentFromFunctionPath:[dict valueForKey:@"functionPath"]] forKey:@"functionPath"];
			[targetDescriptors addObject:dict];
		}
		/* if([[dict valueForKey:@"functionName"]isEqualToString:[target valueForKey:@"name"]] ||
		   [[dict valueForKey:@"graphName"]isEqualToString:[source valueForKey:@"name"]])
			[targetDescriptors addObject:dict];
		 */
	}
	//NSLog(@"%@: performActionWithInputDescriptors: targetDescriptors: %@", [self valueForKey:@"name"], targetDescriptors);
	
	[self setValue:targetDescriptors forKey:@"targetDescriptors"];
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
	 selector:@selector(performTarget:)
		name:@"functionDone"
		object:source];

	[source performActionWithInputDescriptors:sourceDescriptors];
	[sourceDescriptors release];
}

-(void)performTarget:(NSNotification *)notification{

	NSMutableArray * targetDescriptors = [self valueForKey:@"targetDescriptors"];
	Function * source =[self valueForKey:@"source"];
	Function * target = [self valueForKey:@"target"];
	
	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	[dict setValue:[self valueForKey:@"targetPurpose"] forKey:@"purpose"];
	[dict setValue:[self valueForKey:@"targetType"] forKey:@"type"];
	[dict setValue:[target valueForKey:@"targetPath"] forKey:@"functionPath"]; // HAS TO BE A COMPLETE FUNCTIONPATH!!!
	[dict setValue:[source valueForKey:@"output"]  forKey:@"object"];
	[targetDescriptors addObject:dict];	
	//NSLog(@"%@: performTarget: FINAL TARGET DESCRIPTOR: %@ - targetDescriptors: %@", [self valueForKey:@"name"], dict, targetDescriptors);

	[dict release];
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(finish:)
												name:@"functionDone"
											  object:target];
	
	[target performActionWithInputDescriptors:targetDescriptors];
	[targetDescriptors release];
}

-(void)finish:(NSNotification *)notification{
	Function * source =[self valueForKey:@"source"];
	Function * target = [self valueForKey:@"target"];

	[self setValue:[target valueForKey:@"output"] forKey:@"output"];
	//NSLog(@"%@: finish: just set output value: %@", [self valueForKey:@"name"], [self valueForKey:@"output"]);
	
	

	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"functionDone" object:source];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"functionDone" object:target];

	[[NSNotificationCenter defaultCenter]postNotificationName:@"functionDone" object:self];
	
}

-(NSString *)stripFirstComponentFromFunctionPath:(NSString *)path{
	NSArray * pathComponents = [path componentsSeparatedByString:@"."];
	NSMutableString * outPath = [[NSMutableString alloc]initWithString:path];
	if([pathComponents count]==1){
		//NSLog(@"%@: stripFirstComponentFromFunctionPath: one component-> %@", [self className], path);
		return path;
	}
	
	int length = [[pathComponents objectAtIndex:0]length];
	NSRange range = NSMakeRange(0, length+1);
	[outPath deleteCharactersInRange:range];
	//NSLog(@"%@: stripFirstComponentFromFunctionPath: %@ -> %@", [self className], path, outPath);
	return [outPath autorelease];
}

-(NSDictionary *)xmlDictionary{

	NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
	[dict setValue:[self valueForKey:@"targetPurpose"] forKey:@"targetPurpose"];
	[dict setValue:[self valueForKey:@"targetType"] forKey:@"targetType"];
	[dict setValue:[[self valueForKey:@"source"]valueForKey:@"name"] forKey:@"sourceName"];
	[dict setValue:[[self valueForKey:@"target"]valueForKey:@"name"] forKey:@"targetName"];
	[dict setValue:[self valueForKey:@"targetPath"] forKey:@"targetPath"];
	return [dict autorelease];
}

@end
