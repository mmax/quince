//
//  JoinByFrequency.m
//  quince
//
//  Created by max on 11/18/10.
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

#import "JoinByFrequency.h"


@implementation JoinByFrequency

-(JoinByFrequency *)init{
	
	if((self = [super init])){
		[NSBundle loadNibNamed:@"JoinByFrequencyWindow" owner:self];
		maxCent = 0;
	}
	return self;
}


-(void)perform{
	
	[window makeKeyAndOrderFront:nil];	
}


-(IBAction)cancel:(id)sender{

	[window orderOut:nil];
}

-(IBAction)go:(id)sender{
   	[window orderOut:nil];

	
	maxCent = [percentageField floatValue];
	mom = [self outputObjectOfType:@"QuinceObject"];
	source = [self objectForPurpose:@"source"];
    [source retain];
	[source sortChronologically];
	subs = [source valueForKey:@"subObjects"];
    
    if(![self _check]){
    
        [document presentAlertWithText:@"JBF: ERROR: found subObjects without frequencyValue. exiting."];
        NSString * s = [NSString stringWithFormat:@"%@_JBF%d_failed", [source valueForKey:@"name"], (int)maxCent];
        [mom setValue:s forKey:@"name"];
        [mom update];
        [self done];
        [document displayProgress:NO];
        return;
    }
    [document setProgressTask:@"JoinByFrequency: processing..."];
    //[self joinNextFrom:0 into:nil];
    [self join];
	NSString * s = [NSString stringWithFormat:@"%@_JBF%d", [source valueForKey:@"name"], (int)maxCent];
	[mom setValue:s forKey:@"name"];
	[mom update];
	[document displayProgress:NO];

	[self done];
    [source release];
}

-(void)join{

    int count = [subs count];
    inIndex = outIndex = 0;
    QuinceObject * a, *b;
    double freqA, freqB, cent;
    NSArray * out = [mom valueForKey:@"subObjects"];
    float cf = count, progress;
    
    a = [subs objectAtIndex:inIndex];
    [[mom controller]addSubObjectWithController:[[a copy] controller] withUpdate:YES];
    
    for(inIndex=1;inIndex<count;inIndex++){
        progress = inIndex/cf*100.0;
        [document setProgress:progress];
        
        a = [out objectAtIndex:outIndex];
        b = [subs objectAtIndex:inIndex];
        freqA = [[a valueForKey:@"frequency"]doubleValue];
        freqB = [[b valueForKey:@"frequency"]doubleValue];	
        cent = fabs(1200.0 * log2(freqA/freqB)); 
        if(cent<=maxCent){
            [self joinQuinceAtInIndexIntoQuinceAtOutIndex];
        }
        else{
            [[mom controller]addSubObjectWithController:[[b copy] controller] withUpdate:NO];
            outIndex++;
        }
    }
}

-(void)joinQuinceAtInIndexIntoQuinceAtOutIndex{
    QuinceObject * in = [[source valueForKey:@"subObjects"]objectAtIndex:inIndex];
    QuinceObject * out = [[mom valueForKey:@"subObjects"]objectAtIndex:outIndex];
    
    double endA = [[in end]doubleValue], endB = [[out end]doubleValue], start = [[out valueForKey:@"start"]doubleValue];
    double dur = endA > endB ? endA-start : endB-start;
    [out setValue:[NSNumber numberWithDouble:dur] forKey:@"duration"];
}

-(BOOL)_check{
    [document setIndeterminateProgressTask:@"JoinByFrequency: checking..."];
    [document displayProgress:YES];
    
    for(QuinceObject * q in [[self objectForPurpose:@"source"]valueForKey:@"subObjects"]){
        if(![q valueForKey:@"frequency"]){
            NSLog(@"JBF:_check: NOT OK!");
            return NO;
        }
    }
    return YES;
}

//-(void)joinNextFrom:(int)index into:(QuinceObject *)j{ // index is the index of the object being joined into
//    int count = [subs count];
//	//NSLog(@"JBF: joinNextFrom: %d/%d", index, count);
//    if(index<0){
//        [document presentAlertWithText:@"JoinByFrequency: FATAL ERROR: no index given in joining method. exiting."];
//        NSLog(@"JoinByFrequency: FATAL ERROR: no index given in joining method. exiting.");
//        return;
//    }
//    
//    float nx = index, cnt = [subs count];
//    
//    if(!cnt){
//        [document presentAlertWithText:@"JoinByFrequency: FATAL ERROR: no count in joining method. exiting."];
//        NSLog(@"JoinByFrequency: FATAL ERROR: no count in joining method. exiting.");
//        return;
//    }
//    //float prog = nx / cnt * 100.0;
////    [document setProgress:prog];
//       
//    
//	if(index >= [subs count]-1)
//        return;
//	
//	QuinceObject * a;
//	
//	if(j) a=j;
//	else a = [subs objectAtIndex:index];
//	
//	QuinceObject * b = [subs objectAtIndex:index+1];
//    if(!b){
//        NSLog(@"JoinByFrequency: FATAL ERROR: no object b. exiting.");
//        return;
//    }
//	double freqA = [[a valueForKey:@"frequency"]doubleValue];
//	double freqB = [[b valueForKey:@"frequency"]doubleValue];		
//	
//    
//	float cent = fabs(1200.0 * log2(freqA/freqB)); 
//	
//	if(cent>maxCent){//no joining
//		if(!j) // if we have a j we already copied it onto the new output object
//			[[mom controller]addSubObjectWithController:[[a copy]controller] withUpdate:NO];//copy the event as it was
//		
//		if(index == [subs count]-2){ // if b was the last event in the source
//			[[mom controller]addSubObjectWithController:[[b copy]controller] withUpdate:NO];//copy the event as it was
//	        return;																			// and finish
//		}
//		[self joinNextFrom:index+1 into:nil];//continue with the next subObject
//
//	}
//	else{
//		double duration = [[b end]doubleValue] - [[a valueForKey:@"start"]doubleValue];
//		QuinceObject * a2;
//		if(j) a2 = a;
//		else a2 = [a copy];
//		[a2 setValue:[NSNumber numberWithDouble: duration] forKey:@"duration"];
//		if(!j)
//			[[mom controller]addSubObjectWithController:[a2 controller] withUpdate:NO];
//		
//		[self joinNextFrom:index+1 into:a2];
//	}
//	NSLog(@"return");
//}



@end
