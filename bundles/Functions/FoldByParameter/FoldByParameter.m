//
//  FoldByParameter.m
//  quince
//
//  Created by max on 3/26/11.
//  Copyright 2011 Maximilian Marcoll. All rights reserved.
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

#import "FoldByParameter.h"


@implementation FoldByParameter

-(FoldByParameter *)init{
	
	if(self = [super init]){
		[NSBundle loadNibNamed:@"FBP_window" owner:self];
	}
	return self;
}


-(void)perform{

	[parameterMenu removeAllItems];
	QuinceObject * source = [self objectForPurpose:@"source"];
	NSArray * keys = [source allKeysRecursively];
	for(NSString * s in keys){
		if(![s isEqualToString:@"date"] && ![s isEqualToString:@"offsetKeys"]&& ![s isEqualToString:@"subObjects"])
			[parameterMenu addItemWithTitle:s];
	}
	
	[[parameterMenu window] makeKeyAndOrderFront:nil];
}

-(IBAction)cancel:(id)sender{
	
	
	[[okButton window]orderOut:nil];
	[self reset];
	
}

-(NSString *)identifierString{

	return [self valueForKey:@"_FBP_identifier"];//[NSString stringWithFormat:@"FoldByParameter_%@", [parameterMenu titleOfSelectedItem]];
}

-(NSString *)stringFromValue:(id)val{

	id r = val;
	if(![[val className]isEqualToString:@"NSCFString"]){
		r = [val stringValue];
	}
	
	return r;
}

-(IBAction)OK:(id)sender{
	QuinceObject * source = [self objectForPurpose:@"source"];
	[self setValue:[source createUUID] forKey:@"_FBP_identifier"];

//	NSLog(@"source type: %@", [source type]);

	NSString * parameter = [parameterMenu titleOfSelectedItem];

	QuinceObjectController * qc;
	while((qc = [self nextSubController]))
		[self foldControllersForObjectsWithValue:[self stringFromValue:[[qc content]valueForKey:parameter]]];
	
	[self cleanUp];
	
	
	[[okButton window] orderOut:nil];
	[self setOutputObjectToObjectWithPurpose:@"source"];
	[self done];
}



-(void)foldControllersForObjectsWithValue:(NSString *)s{
	QuinceObject * source = [self objectForPurpose:@"source"];
	id objectValueString;
	NSMutableArray * controllers = [[[NSMutableArray alloc]init]autorelease];

	for(QuinceObject *q in [source valueForKey:@"subObjects"]){
	
		objectValueString = [self stringFromValue:[q valueForKey:[parameterMenu titleOfSelectedItem]]];

		if([objectValueString isEqualToString:s])
			[controllers addObject:[q controller]];
	}
	//NSLog(@"foldControllers: folding %d controllers", [controllers count]);
	QuinceObjectController * c = [[source controller]foldControllers:controllers];
	[[c content] setValue:[NSString stringWithFormat:[self identifierString], [parameterMenu titleOfSelectedItem]] forKey:@"_FBP"];
	[[c content] setValue:[NSString stringWithFormat:@"%@_%@", [parameterMenu titleOfSelectedItem], s]forKey:@"name"];
	

}

-(QuinceObjectController *)nextSubController{
	QuinceObject * source = [self objectForPurpose:@"source"];
	for(QuinceObject * q in [source valueForKey:@"subObjects"]){
		if(![[q valueForKey:@"_FBP"] isEqualToString:[self identifierString]])
		   return [q controller];
	}
	return nil;
}

-(void)cleanUp{
//	NSLog(@"cleanUp");
	QuinceObject * source = [self objectForPurpose:@"source"];
	for(QuinceObject * q in [source valueForKey:@"subObjects"]){
		if([q isFolded] && [q subObjectsCount] == 1 && [[q valueForKey:@"_FBP"]isEqualToString:[self identifierString]]){
		
			[[source controller]unfoldController:[q controller]];
			[self cleanUp];
			return;
		}
	}

	for(QuinceObject * q in [source valueForKey:@"subObjects"])
		[q removeObjectForKey:@"_FBP"];
	
	[[[source controller] registeredContainerViews]makeObjectsPerformSelector:@selector(reload)];

}


@end

