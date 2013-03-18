//
//  CreateGridSequence.m
//  quince
//
//  Created by max on 3/25/10.
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

#import "CreateGridSequence.h"


@implementation CreateGridSequence


-(CreateGridSequence *)init{

	if((self = [super init])){
		[NSBundle loadNibNamed:@"CreateGridSequenceWindow" owner:self];
	}
	return self;
}
-(void)perform{
	
	if(!gridView)
			NSLog(@"CreateGridSeuquence: PERFORM:NO GRIDVIEW");

	[window makeKeyAndOrderFront:nil];
}


-(IBAction)toggleMeasure:(id)sender{
	int divider = [[sender title]integerValue];
	if ([sender state] == NSOnState)
		[gridView addMeasure:divider];
	else
		[gridView removeMeasure:divider];
}

-(IBAction)doneTime:(id)sender{

	QuinceObjectController * mc = [[self outputObjectOfType:@"QuinceObject"]controller];
	
	/* if([self valueForKey:@"result"])
			mc = [[self valueForKey:@"result"]controller];
		else
			mc	= [document controllerForNewQuinceObjectOfClassNamed:@"Sequence" inPool:NO]; // don't add it to pool YET */
	
	float maxDur = [[document durationOfLongestObjectInPool]floatValue];
	double start;
	int sec, max = maxDur + 1;
	
	if([repeatBox state] == NSOffState)
		max = 1;
	
	//NSLog(@"max: %d", max);
	NSMutableArray * measures = [gridView measures];
	QuinceObjectController * lockController;
	
	for(sec = 0;sec<max;sec++){
		for(NSNumber * m in measures){
			for(int i =0;i<[m intValue];i++){
				start = sec + 1.0/[m intValue]*i;
				//NSLog(@"start: %f", start);

				if([self newLock:[NSNumber numberWithDouble:start] inGrid:[mc selection]]){// check if the number already is in the grid 
					lockController = [document controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO];
					[lockController setValue:[NSNumber numberWithDouble:start] forKeyPath:@"selection.start"];
					[lockController setValue:[NSNumber numberWithDouble:1.0/[m intValue]] forKeyPath:@"selection.duration"];
					[lockController setValue:[NSNumber numberWithDouble:0 - [m intValue]*10] forKeyPath:@"selection.volume"];
					[lockController setValue:@"gridPoint" forKeyPath:@"selection.name"];
					[lockController setValue:[NSString stringWithFormat:@"#%d/%d",i+1, [m intValue]] forKeyPath:@"selection.description"];
					[mc addSubObjectWithController:lockController withUpdate:NO];
				}
			}
		}
	}
	
	[mc update];
	[mc setValue:[self descriptionStringwithMeasures:measures] forKeyPath:@"selection.description"];
	[mc setValue:@"timeGrid" forKeyPath:@"selection.name"];
	//[document addObjectToObjectPool:[mc content]];
	//b[[mc content]release]; // the pool is now the only owner
	[window orderOut:nil];
	[self done];
}

-(IBAction)cancelTime:(id)sender{
	[self cancel];
}

-(void)cancel{

    [window orderOut:nil];
	[self done];
}

-(BOOL)hasInterface{return YES;}

-(IBAction)changeMeasure:(id)sender{
	
	int measure = [newMeasureTextField intValue];
	int index = [newMeasureIndexPopUp indexOfSelectedItem];
//	NSLog(@"index: %d measure: %d", index, measure);
	NSButton* cb;
	BOOL flag = NO;
	
	switch (index) {
		case 0:
			cb = checkBox1;
			break;

		case 1:
			cb = checkBox2;
			break;
			
		case 2:
			cb = checkBox3;
			break;
			
		case 3:
			cb = checkBox4;
			break;
			
		case 4:
			cb = checkBox5;
			break;
			
		case 5:
			cb = checkBox6;
			break;
			
		case 6:
			cb = checkBox7;
			break;
			
		case 7:
			cb = checkBox8;
			break;
			
			
		default:
			cb = checkBox1;
	}

	if ([cb state] == NSOnState) {
		[cb performClick:nil];// setState:NSOffState];
		flag = YES;
	}

	
	[cb setTitle:[NSString stringWithFormat:@"%d", measure]];
	if(flag)
		[cb performClick:nil];

}

-(BOOL)newLock:(NSNumber *)lock inGrid:(QuinceObject *)quince{
	for(QuinceObject * m in [quince valueForKey:@"subObjects"]){
		if([lock isEqualToNumber:[m valueForKey:@"start"]])
			return NO;
	}
	return YES;
	
}
-(NSString *)descriptionStringwithMeasures:(NSArray *)measures{

	NSString * d = [NSString stringWithFormat:@"dividers: "];
	for(NSNumber * n in measures)
		d = [d stringByAppendingFormat:@"%d ", [n intValue]];
	return d;
}

-(BOOL)needsInput{return NO;}

-(NSMutableArray *)inputDescriptors{
	
	NSMutableDictionary * dictA = [[NSMutableDictionary alloc]init];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"purpose"];
	[dictA setValue:[NSString stringWithString:@"empty"] forKey:@"type"];
	NSMutableArray * ipd = [[NSMutableArray alloc]initWithObjects:dictA, nil];
	[dictA release];
	return [ipd autorelease];
}

-(IBAction)donePitchTempered:(id)sender{
    [window orderOut:nil];

    
    QuinceObjectController * mc = [[self outputObjectOfType:@"QuinceObject"]controller];
    
    int cent = [temperedCentField intValue];
    double a = [temperedAField doubleValue];
    
    double oneCent = pow(2, 1.0/1200);
    double factor = pow(oneCent, cent);
    double invFactor = 1.0/factor;
    double time=0;
    double candidate=a;
    
   
    [document setIndeterminateProgressTask:@"Creating Pitch Grid..."];
    [document displayProgress:YES];

    
    QuinceObject* q;
    candidate = a;
    
    while(candidate < 20000){   //start at 440 and go up
        q = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
        [q setValue:[NSNumber numberWithDouble:candidate] forKey:@"frequency"];
        [q setValue:[NSNumber numberWithDouble:time] forKey:@"start"];
        [q setValue:[NSNumber numberWithDouble:.1] forKey:@"duration"];
        //[q setValue:[NSNumber numberWithInt:-1 * (rand()%30)]forKey:@"volume"];
        [mc addSubObjectWithController:[q controller] withUpdate:NO];

        time +=0.1;
        
        candidate *= factor;
    }
    candidate = a;
    
    while(candidate > 20){ // start below 440 and go down
    
        candidate *=invFactor;
        q = [document newObjectOfClassNamed:@"QuinceObject" inPool:NO];
        [q setValue:[NSNumber numberWithDouble:candidate] forKey:@"frequency"];
        [q setValue:[NSNumber numberWithDouble:time] forKey:@"start"];
        [q setValue:[NSNumber numberWithDouble:.1] forKey:@"duration"];
       // [q setValue:[NSNumber numberWithInt:-1 * (rand()%30)]forKey:@"volume"];
        [mc addSubObjectWithController:[q controller] withUpdate:NO];
        time +=0.1;
    }
    
    [mc setValue:@"pitchGrid" forKeyPath:@"selection.name"];
    
    [[mc content]sortByKey:@"frequency" ascending:YES];
    [mc update];
    [document displayProgress:NO];
    [self done];
}


























@end
