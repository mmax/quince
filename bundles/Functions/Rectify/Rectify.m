//
//  Rectify.m
//  quince
//
//  Created by Maximilian Marcoll on 5/27/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//

/*
 
 Rectify takes a sequence to operate on and a sequence as a grid.
 However it does not perform normal quantisation. 
 
 The output of Rectify is a version of the input sequence RELATIVE to events in the grid.

 Use it to prepare sequences for quatization, if they are to be represented in traditional notation 
 but the timing of the sequence is not steady.
 
 
 
 */

#import "Rectify.h"

@implementation Rectify



-(void)perform{

    QuinceObject * seq = [self objectForPurpose:@"victim"];
    [seq sortChronologically];
    QuinceObjectController * resultController = [[self outputObjectOfType:@"QuinceObject"]controller];
 
    [self copyParamsOf:seq into:[resultController content]]; 

    [document setProgressTask:@"Rectifying..."];
	[document setProgress:0];
	[document displayProgress:YES];
    
    [[self objectForPurpose:@"grid"]sortChronologically];

    
    NSArray * subs = [seq valueForKey:@"subObjects"];
    NSArray * gridSubs = [[self objectForPurpose:@"grid"]valueForKey:@"subObjects"];

    
    for(QuinceObject * q in subs){
        QuinceObject * c = [q copyWithZone:nil];
        int i = [self findGridIndexForQuince:c];
        if(i == -1){
            NSLog(@"Rectify: EOF");//EOF
        }
        else{
            double frac = [self rectifyQuince:c betweenA:[gridSubs objectAtIndex:i] andB:[gridSubs objectAtIndex:i+1]];   
            [c setValue:[NSNumber numberWithDouble:frac+i] forKey:@"start"];
            [resultController addSubObjectWithController:[c controller] withUpdate:NO];
            
        }
    }
    
    [resultController update];
	[resultController setValue:[NSString stringWithFormat:@"%@_RECT", [seq valueForKey:@"name"]] forKeyPath:@"selection.name"];
	//[resultController setValue:[[[seq valueForKey:@"start"]copy]autorelease] forKeyPath:@"selection.start"];
	//[document addObjectToObjectPool:[resultController content]];
	[document displayProgress:NO];
	[self done];

    
}

-(int)findGridIndexForQuince:(QuinceObject *)q{
    
    QuinceObject * g = [self objectForPurpose:@"grid"];
    NSArray * subs = [g valueForKey:@"subObjects"];
    int i;
    double time = [[q valueForKey:@"start"]doubleValue];
    
    for(i=0;i<[subs count]-1;i++){
        QuinceObject * a = [subs objectAtIndex:i];
        QuinceObject * b = [subs objectAtIndex:i+1];
        
        if([[a valueForKey:@"start"]doubleValue] <= time && time < [[b valueForKey:@"start"]doubleValue])
            return [subs indexOfObject:a];
    
    }
    return -1;
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



-(double)rectifyQuince:(QuinceObject *)q betweenA:(QuinceObject *)A andB:(QuinceObject *)B {
    
    
    if([[A valueForKey:@"start"]doubleValue] >= [[B valueForKey:@"start"]doubleValue]){
    
        [document presentAlertWithText:@"Rectify: ERROR! A >=B"];
        return 0;
    }
        
    double o = [[q valueForKey:@"start"]doubleValue], a = [[A valueForKey:@"start"]doubleValue], b = [[B valueForKey:@"start"]doubleValue];
    
    double dur = [[q valueForKey:@"duration"]doubleValue] /(b-a);
    
    [q setValue:[NSNumber numberWithDouble:dur] forKey:@"duration"];
    
    return (o-a)/(b-a);
    
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
