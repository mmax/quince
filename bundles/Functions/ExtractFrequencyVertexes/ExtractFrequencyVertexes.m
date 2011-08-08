//
//  ExtractFrequencyVertexes.m
//  quince
//
//  Created by max on 8/1/11.
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

#import "ExtractFrequencyVertexes.h"


@implementation ExtractFrequencyVertexes

-(void)perform{

	QuinceObject * source = [self objectForPurpose:@"source"];
	QuinceObject * result = [self outputObjectOfType:@"QuinceObject"];
	QuinceObject * qa, * qb;
    NSString * s = [NSString stringWithFormat:@"%@_FVrtx%", [source valueForKey:@"name"]];
    [result setValue:s forKey:@"name"];
    //double a, b;
    int dir=-1, prevDir=-666;
    NSArray * subs = [source valueForKey:@"subObjects"];
    
    [source sortChronologically];

    if(![self checkObjects]){
        [document presentAlertWithText:[NSString stringWithFormat:@"%@: Error: Unable to perform on input object. Make sure no objects overlap in time and that all objects have frequency values! ", [self className]]];
        return;
    }

    [self addVertex:[subs objectAtIndex:0] toResult:result]; // init;
    dir = [self getDirectionForQuince:[subs objectAtIndex:0] and:[subs objectAtIndex:1]];
    [document setProgressTask:@"extracting..."];
    [document displayProgress:YES];
    float progress = 0;
    for(int i=1;i<[subs count]-1;i++){
        progress = (100.0 / [subs count]) * i;
        [document setProgress:progress];
        qa = [subs objectAtIndex:i];
        qb = [subs objectAtIndex:i+1];
        prevDir = dir;
        dir = [self getDirectionForQuince:qa and:qb];
        if(prevDir!=dir){ // vertex!
            [self addVertex:qa toResult:result];
        }
    }
    
    [result update];
    [document displayProgress:NO];
    [self done];
}




-(int)getDirectionForQuince:(QuinceObject *)a and:(QuinceObject *)b{
    if([self glissandoInQuince:a])
        return [[a valueForKey:@"glissandoDirection"]intValue];
    
    double fa, fb;
    fa = [[a valueForKey:@"frequency"]doubleValue];
    fb = [[b valueForKey:@"frequency"]doubleValue];
    
    if (fb>fa)
        return 1;
    else return 0;
}

-(void)addVertex:(QuinceObject *)q toResult:(QuinceObject *)r{
    [[r controller]addSubObjectWithController:[document controllerForCopyOfQuinceObjectController:[q controller] inPool:NO] withUpdate:NO];
    
}

-(BOOL)glissandoInQuince:(QuinceObject *)q{

    if([q valueForKey:@"glissandoDirection"]) return YES;
    return NO;
}


-(BOOL)checkObjects{
    
    QuinceObject * quinceA, *quinceB, * mother = [self objectForPurpose:@"source"];
	//[mother sortChronologically];
    NSArray * subs = [mother valueForKey:@"subObjects"];
	double startB, endA;	
	
    
    for(int i=0;i<[subs count]-1;i++){
        quinceA = [subs objectAtIndex:i];
        quinceB = [subs objectAtIndex:i+1];
		endA = [[quinceA end]doubleValue];
		startB = [[quinceB valueForKey:@"start"]doubleValue];
        if(endA > startB+.001){
            NSLog(@"overlap!");
            return NO;       
        }
        if(![quinceA valueForKey:@"frequency"]){
            NSLog(@"no freq!");
            return NO;
        }
    }
    return YES;
    
}


@end
