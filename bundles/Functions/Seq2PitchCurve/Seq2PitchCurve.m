//
//  Seq2PitchCurve.m
//  quince
//
//  Created by max on 8/6/11.
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

#import "Seq2PitchCurve.h"


@implementation Seq2PitchCurve

-(void)reset{

    [super reset];
    gliss = NO;
}

-(void)perform{

    if(![self checkInput]){
        [document presentAlertWithText:@"ERROR: unable to operate on input object. At least one subObject does not contain any frequency information!"];
        [self done];
        return;
    }
    
    PitchCurve * output = (PitchCurve *)[self outputObjectOfType:@"PitchCurve"];
    float sr = 100;
    index = 0;
    [self setValue:[NSNumber numberWithFloat:sr] forKey:@"sampleRate"];
    NSArray * pc = [self pc];
    [output setPitchCurve:pc];

    [output setValue:[NSNumber numberWithDouble:sr] forKey:@"sampleRate"];

    [output setValue:[NSNumber numberWithInt:1] forKey:@"samplesPerWindow"];
    [output setValue:[[self objectForPurpose:@"source"] valueForKey:@"duration"] forKey:@"duration"];
    [output setValue:[NSString stringWithFormat:@"%@_PiCu", [[self objectForPurpose:@"source"] valueForKey:@"name"]] forKey:@"name"];
    [document displayProgress:NO];
    [self done];
}

-(NSArray *)pc{


    NSMutableArray * pc = [[NSMutableArray alloc]init];
    QuinceObject * source = [self objectForPurpose:@"source"], * candidate;
    [document setIndeterminateProgressTask:@"Seq2PitchCurve: sorting..."];
    [document displayProgress:YES];
    [source sortChronologically];
    NSArray * subs;

    double pitchF=0, dur = [[source valueForKey:@"duration"]doubleValue], inc = 1/[[self valueForKey:@"sampleRate"]floatValue], time=0;
    float progress=0;
    

    [document setProgressTask:@"Seq2PitchCurve: converting sequence..."];
    [document displayProgress:YES];

    int i=0;
    while (time<dur) {
        [document setProgress:progress];
        progress=  100.0/(dur*100.0)*i++;
        
        //subs = [source subObjectsAtTime:[NSNumber numberWithDouble:time]];
        subs = [self getSubObjectsForTime:[NSNumber numberWithDouble:time]];
        if([subs count]){
            if([subs count]==1) 
                candidate =  [subs lastObject];
            else
                candidate = [self objectWithHighestFrequencyInArray:subs];
            
            pitchF = [[candidate valueForKey:@"pitchF"]doubleValue];
        }
        
        
        [pc addObject:[NSNumber numberWithDouble:pitchF]];
        time+=inc;
        
        //NSLog(@"time: %f, dur:%f", time, dur);
       // NSString * s = [NSString stringWithFormat:@"Seq2PitchCurve: %.3f/%.3f", time, dur];
        //[document setProgressTask:s];
        
    }
    return [pc autorelease];
}

-(NSArray *)getSubObjectsForTime:(NSNumber *)time{
   // NSMutableArray * subs = [[NSMutableArray alloc]init];
    int i = index;
    long max = [[[self objectForPurpose:@"source"]valueForKey:@"subObjects"]count];
    QuinceObject * m;
    BOOL flag = NO;
    NSArray * inSubs = [[self objectForPurpose:@"source"]valueForKey:@"subObjects"];
    NSMutableArray * s = [[NSMutableArray alloc]init];
	double start, end, t = [time doubleValue];
	
	for(;i<max;i++){
        m=[inSubs objectAtIndex:i];
		start = [[m valueForKey:@"start"]doubleValue]+[[m offsetForKey:@"start"]doubleValue];
		end = start + [[m valueForKey:@"duration"]doubleValue];
		if (start<=t && t<end){

            if(!flag){
                flag = YES;
                index = i;
            }
			
            [s addObject:m];
            
        }
        if(start > t)
            break;
	}
    
	return [s autorelease];

    
}

 -(QuinceObject *)objectWithHighestFrequencyInArray:(NSArray *)a{

    
    double f, m=0;
    QuinceObject * c;
    for(QuinceObject * q in a){
        f = [[q valueForKey:@"frequency"]doubleValue];
        if(f>m){
            m = f;
            c = q;
        }
    }
    return c;
}

-(BOOL)checkInput{
    gliss = NO;
    QuinceObject * q = [self objectForPurpose:@"source"];
    for(QuinceObject * s in [q valueForKey:@"subObject"]){
        if(![s valueForKey:@"frequency"])
            return NO;
        else if([s valueForKey:@"glissandoDirection"])
            gliss = YES;
    }
    
    if(gliss){
        [document presentAlertWithText:@"Seq2PitchCurve: analysing glissandi is not yet implemented! continuing without glissandi..."];
    }
    
    return YES;
}

-(NSString *)outputType{
    
	return @"PitchCurve";
}

@end
