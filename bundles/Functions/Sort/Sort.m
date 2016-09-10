//
//  Sort.m
//  quince
//
//  Created by Maximilian Marcoll on 5/22/13.
//  Copyright (c) 2013 Maximilian Marcoll. All rights reserved.
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


#import "Sort.h"

@implementation Sort

-(Sort *)init{
	
	if((self = [super init])){
		//[NSBundle loadNibNamed:@"SortWindow" owner:self];
        [[[NSBundle alloc]init]loadNibNamed:@"SortWindow" owner:self topLevelObjects:nil];
	}
	return self;
}

-(void)perform{

    [self fetchCommonParametersForArrayOfQuinces:[[self objectForPurpose:@"source"]valueForKey:@"subObjects"]];
    [window makeKeyAndOrderFront:nil];
}

-(IBAction)Sort:(id)sender{

    QuinceObject * mother = [self objectForPurpose:@"source"], * result = [self outputObjectOfType:@"QuinceObject"];
    NSArray * subs = [mother valueForKey:@"subObjects"];
    [self copyParamsOf:mother into:result];
    NSMutableArray * times = [NSMutableArray array];
    NSString * directionString = @"-Asc";

    for(QuinceObject * sub in subs){
        [[result controller] addSubObjectWithController:[[sub copyWithZone:nil] controller] withUpdate:NO];
        NSMutableDictionary * d = [NSMutableDictionary dictionary];
        [d setValue:[sub valueForKey:@"start"] forKey:@"start"];
        [times addObject:d];
    }
    
    NSSortDescriptor * sd = [[NSSortDescriptor alloc]initWithKey:@"start" ascending:YES];
	NSArray * descriptors = [NSArray arrayWithObject:sd];
	[times sortUsingDescriptors:descriptors];

    BOOL asc = [[directionMenu titleOfSelectedItem]isEqualToString:@"Ascending"];	
    if(!asc) directionString = @"-Desc";
        
    //NSLog(@"Sorting by: %@", [parameterMenu titleOfSelectedItem]);
    
//    for(QuinceObject * q in subs){
//        NSLog(@"frequency type: %@", [[q valueForKey:@"frequency"]className]);
//        
//    }
    
    [result sortByKey:[parameterMenu titleOfSelectedItem] ascending:asc];

    
    for(int i=0;i<[subs count];i++)
        [[[result valueForKey:@"subObjects"]objectAtIndex:i]setValue:[[[times objectAtIndex:i]valueForKey:@"start"]copy] forKey:@"start"];


    [[result controller] setValue:[NSString stringWithFormat:@"%@_Sort-%@%@", [mother valueForKey:@"name"], [parameterMenu titleOfSelectedItem],directionString] forKeyPath:@"selection.name"];  
    [[result controller] update];
    [window orderOut:nil];
	[self done];

}


-(void)fetchCommonParametersForArrayOfQuinces:(NSArray *)a{
    
    [parameterMenu removeAllItems];
    [document setProgressTask:@"fetching common parameters..."];
    QuinceObject * quince = [a lastObject]; // need ANY quince to use it's methods
    NSMutableArray * common = [[[NSMutableArray alloc]init] autorelease];
    int i=0;
    float f = 100.0/[a count];
    NSArray * ek = [self excludedParameters];

    for(QuinceObject * q in a){
        
        [document setProgress:f*i++];
        
        for(NSString * s in [q allKeys]){
            if(![quince isString:s inArrayOfStrings:ek] && 
               ![quince isString:s inArrayOfStrings:common] &&
               [self doAllObjectsInArray:a haveAValueForKey:s]){
                
                [common addObject:s];
                
                
            }
        }
    }
    [common sortUsingSelector:@selector(compare:)];
    for(NSString * s in common)
        [parameterMenu addItemWithTitle:s];

}


-(NSArray *)excludedParameters{
    
	return [NSArray arrayWithObjects:@"type", @"nonStandardReadIn", @"resampled", @"windowDuration", @"offsetKeys", @"id", @"subObjects", @"startOffset", @"volumeOffset", @"compatible", @"superObject", nil];
}

-(BOOL)excludedParametersInclude:(NSString *)pam{
    
	for(NSString * s in [self excludedParameters]){
        
		if ([s isEqualToString:pam])
			return YES;
	}
	return NO;
}

-(void)removeExcludedKeysFromArray:(NSMutableArray*)pams{
    
    [document setIndeterminateProgressTask:@"removing excluded keys..."];
	
    BOOL flag = NO;
	for(NSString *s in pams){
		if ([s isEqualToString:@"mediaFileName"]){
			[pams removeObject:s];
			flag  =YES;
			break;
		}
	}
	if(flag) [pams addObject:@"mediaFileName"];
	
	for(NSString * s in pams){
		if([self excludedParametersInclude: s]){
			[pams removeObject:s];
			[self removeExcludedKeysFromArray:pams];
			return;
		}
	}
}

-(BOOL)doAllObjectsInArray:(NSArray *)a haveAValueForKey:(NSString *)key{
    
    for(QuinceObject * q in a){
        
        if(![q valueForKey:key])
            return NO;
    }
    return YES;
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
