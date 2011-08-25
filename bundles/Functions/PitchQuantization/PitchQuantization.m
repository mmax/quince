//
//  PitchQuantization.m
//  quince
//
//  Created by max on 7/9/11.
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

#import "PitchQuantization.h"


@implementation PitchQuantization

-(void)perform{

    QuinceObjectController * resultController = [[self outputObjectOfType:@"QuinceObject"]controller];
    QuinceObject * seq = [self objectForPurpose:@"victim"], * result = [resultController content];
	
    [self copyParamsOf:seq into:result];
    NSArray * subs = [seq valueForKey:@"subObjects"];
    
    
    [document setIndeterminateProgressTask:@"PitchQuantization: copying source..."];
    [document displayProgress:YES];
    for(QuinceObject * q in subs){
        
        
        [resultController addSubObjectWithController:[[q copy]controller] withUpdate:NO];
    }
    
    [self createGrid];
    [self doQuantize:result];
    
    [resultController update];
	[resultController setValue:[NSString stringWithFormat:@"%@_pq", [seq valueForKey:@"name"]] forKeyPath:@"selection.name"];
	
	[document displayProgress:NO];
	[self done];
}

-(void)doQuantize:(QuinceObject *)q{
    float count = [q subObjectsCount];
    float progress = 0, f = 100.0/count;
    [document setProgressTask:@"PitchQuantization: quantizing objects..."];
    [document displayProgress:YES];
    
    for(int i = 0; i<count;i++){
        [self quantizeQuince:[[q valueForKey:@"subObjects"]objectAtIndex:i]];    
        progress = f * i;
        [document setProgress:progress];
    }
    
    //[document displayProgress:NO];
}

-(void)quantizeQuince:(QuinceObject *)q{

    NSNumber * freq = [q valueForKey:@"frequency"];
    
    if(!freq)
        return;
    double deltaA, deltaB;
    
    NSArray * pair = [self enclosingFrequenciesForCandidate:freq];

    if([pair count] == 1)
        freq = [pair lastObject];
    else if([pair count] ==2){
        deltaA = [q centDifferenceBetweenFrequency:[freq doubleValue] and:[[pair objectAtIndex:0]doubleValue]];
        deltaB = [q centDifferenceBetweenFrequency:[freq doubleValue] and:[[pair lastObject]doubleValue]];
        
        if(deltaA < deltaB)
            freq = [pair objectAtIndex:0];
        else
            freq = [pair lastObject];
    }
    else{
        NSLog(@"QuinceObject %@ produced an error in PitchQuantization with frequency: %@", [q valueForKey:@"name"], freq);
        return;
        //ERROR!!!!
    }
    
    [q setValue:freq forKey:@"frequency"];
}

-(void)createGrid{
    [document setIndeterminateProgressTask:@"PitchQuantization: processing grid..."];
    [document displayProgress:YES];
    
    NSMutableArray * grid = [[[NSMutableArray alloc]init]autorelease];
    
    NSArray * gridSubs = [[self objectForPurpose:@"grid"]valueForKey:@"subObjects"];
    
    for(QuinceObject * q in gridSubs){
    
        if (![self isFrequency:[q valueForKey:@"frequency"] inGrid:grid])
            [grid addObject:[q valueForKey:@"frequency"]];
    }
    
    NSSortDescriptor *mySorter = [[NSSortDescriptor alloc] initWithKey:@"doubleValue" ascending:YES];
    [grid   sortUsingDescriptors:[NSArray arrayWithObject:mySorter]];
    
    [self setValue:grid forKey:@"grid"];
}


-(BOOL)isFrequency:(NSNumber *)f inGrid:(NSArray *)grid{

    for(NSNumber * n in grid){
    
        if ([n doubleValue] == [f doubleValue]) 
            return YES;
    }
    return NO;
}



-(NSArray *)enclosingFrequenciesForCandidate:(NSNumber *)nf{

    NSArray * grid = [self valueForKey:@"grid"];
    NSNumber * a, *b, *min, *max;
    min = [grid objectAtIndex:0];
    max = [grid lastObject];
    double f = [nf doubleValue];
    
    NSMutableArray * pair = [[[NSMutableArray alloc]init] autorelease];
    
    for(int i=0;i<[grid count]-1;i++){
        a = [grid objectAtIndex:i];
        b = [grid objectAtIndex:i+1];
        
        if([a doubleValue] <= f && [b doubleValue] > f){
            [pair addObject:a];
            [pair addObject:b];
        }
        else if([a doubleValue] == f && [b doubleValue] == f)
            [pair addObject:a];
    }
    
    if(![pair count]){
        if(f >= [max doubleValue])
            [pair addObject:max];
        else if(f<= [min doubleValue])
            [pair addObject:min];
    }
    
    return pair;
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


@end
