//
//  ApplyPitchCurve.m
//  quince
//
//  Created by max on 9/5/11.
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


#import "ApplyPitchCurve.h"


@implementation ApplyPitchCurve



-(void)perform{


    QuinceObject * q, * target = [self objectForPurpose:@"target"];
    [target sortChronologically];
    NSArray * subs = [target valueForKey:@"subObjects"];
    PitchCurve * pc = (PitchCurve *)[self objectForPurpose:@"pitchCurve"];
    float progress = 0, count = [subs count];
    sr = [[pc valueForKey:@"sampleRate"]doubleValue];
    curve = [pc pitchCurve];
    [document setProgressTask:@"ApplyPitchCurve: processing..."];
    [document displayProgress:YES];
    
    for(int i = 0;i<count;i++){
        progress = i/count * 100.0;
        [document setProgress:progress];
        q = [subs objectAtIndex:i];
        [self applyPitchCurve:pc toQuince:q];
    }
    
    [self setOutputObjectToObjectWithPurpose:@"target"];
    [document displayProgress:NO];
    [self done];
}

-(void)applyPitchCurve:(PitchCurve *)pc toQuince:(QuinceObject *)q{

    double start = [[q valueForKey:@"start"]doubleValue], end = [[q end]doubleValue], pitchA, pitchB, pitchRange, startPich, endPitch;
    pitchA = [self pitchValueForTime:start];
    pitchB = [self pitchValueForTime:end];
    pitchRange = fabs(pitchA-pitchB);
    int dir;
    if(pitchA > pitchB){
        startPich = pitchA;
        endPitch = pitchB;
        dir = 0;
    }
    else {
        startPich = pitchB;
        endPitch = pitchA;
        dir = 1;
    }
    
    [q setValue:[NSNumber numberWithDouble:[q mToF:startPich]]forKey:@"frequency"];
    [q setValue:[NSNumber numberWithDouble:[q mToF:endPitch]] forKey:@"frequencyB"];
    [q setValue:[NSNumber numberWithInt:dir] forKey:@"glissandoDirection"];
    //[q setValue:[NSNumber numberWithDouble:pitchRange] forKey:@"pitchRange"];
}

-(double)pitchValueForTime:(double)t{
    
    int index = t * sr +.5;
  //  NSLog(@"time: %f, sr = %f, index = %d, pitch: %f", t, sr, index, [[curve objectAtIndex:index]doubleValue]);
    if (index < [curve count])
        return [[curve objectAtIndex:index]doubleValue];
        
    return [[curve lastObject]doubleValue];
}


-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:@"pitchCurve" forKey:@"purpose"];
	[dictA setValue:@"PitchCurve" forKey:@"type"];
	
	NSMutableDictionary * dictB = [[NSMutableDictionary alloc]init];
	[dictB setValue:@"target" forKey:@"purpose"];
	[dictB setValue:@"QuinceObject" forKey:@"type"];
	
	NSMutableArray * ipd = [[NSMutableArray alloc ]initWithObjects:dictA, dictB, nil];
	[dictA release];
	[dictB release];
	return [ipd autorelease];
}

@end
