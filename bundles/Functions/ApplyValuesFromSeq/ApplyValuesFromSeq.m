//
//  ApplyValuesFromSeq.m
//  quince
//
//  Created by max on 4/13/11.
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
#import "ApplyValuesFromSeq.h"


@implementation ApplyValuesFromSeq

-(ApplyValuesFromSeq *)init{
	
	if(self = [super init]){
		//[NSBundle loadNibNamed:@"AVFS_win" owner:self];
        [[[NSBundle alloc]init] loadNibNamed:@"AVFS_win" owner:self topLevelObjects:nil];
	}
	return self;
}

-(BOOL)hasInterface{return YES;}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"target" forKey:@"purpose"];
	[dictA setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"source" forKey:@"purpose"];
	[dictB setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}

-(IBAction)OK:(id)sender{
    [[pop window]orderOut:nil];
    
    NSString * param = [pop titleOfSelectedItem];
	QuinceObject * source = [self objectForPurpose:@"source"];
	QuinceObject * target = [self objectForPurpose:@"target"];
	NSNumber * start;
	int i=0, mode = [modePop indexOfSelectedItem], n = [[target valueForKey:@"subObjects"]count];
    float prog = 0;
    [document setProgressTask:@"processing..."];
    [document displayProgress:YES];
    
	for(QuinceObject * q in [target valueForKey:@"subObjects"]){
	
        prog = 100.0 / n * i++;
        [document setProgress:prog];
        
		start = [q valueForKey:@"start"];
		NSMutableArray * sourceValues = [[NSMutableArray alloc]init];
		[sourceValues addObjectsFromArray:[source valuesForKey:param forTime:start]];
		[sourceValues sortUsingSelector:@selector(compare:)];
		
		if([sourceValues count]){
			
			switch (mode) {
				case 0://max]
					[q setValue:[sourceValues lastObject] forKey:param];
					break;
				case 1://min
					[q setValue:[sourceValues objectAtIndex:0] forKey:param];
					break;
			}
		}
	}
    [document displayProgress:NO];
	[self done];
    
}


-(IBAction)cancel:(id)sender{
	[[pop window] orderOut:nil];
	[self done];
}


-(void)perform{
	[pop removeAllItems];
	[pop addItemsWithTitles:[self keys]];
	[[pop window] makeKeyAndOrderFront:nil];

}


-(NSMutableArray *)keys{

	QuinceObject * source = [self objectForPurpose:@"source"];
	QuinceObject * target = [self objectForPurpose:@"target"];
	
	NSMutableArray * keys = [[NSMutableArray alloc]init];
	NSArray * keysA = [source allKeysRecursively];
	NSArray * keysB = [target allKeysRecursively];	
	//[keys addObjectsFromArray:keysB];
    
	for(NSString *s in keysA){
	
		if(![source isString:s inArrayOfStrings:keys] && ![source isString:s inArrayOfStrings:[document objectInspectorExcludedKeys]]){
			[keys addObject:s];
		}
	}
    
	for(NSString *s in keysB){
        
		if(![source isString:s inArrayOfStrings:keys] && ![source isString:s inArrayOfStrings:[document objectInspectorExcludedKeys]]){
			[keys addObject:s];
		}
	}
    NSLog(@"%@", keys);
    return [keys autorelease];
}

@end
