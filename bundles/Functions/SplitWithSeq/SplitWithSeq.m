//
//  SplitWithSeq.m
//  quince
//
//  Created by Maximilian Marcoll on 1/6/16.
//  Copyright (c) 2016 Maximilian Marcoll. All rights reserved.
//

#import "SplitWithSeq.h"
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceDocument.h>

@implementation SplitWithSeq

-(void)perform{
    
    
    QuinceObject * q, *grid = [self objectForPurpose:@"grid"], * victim = [self objectForPurpose:@"victim"];
    
    // make sure we have a working copy of the victim, registered as the output object
    QuinceObject * quince = [self outputObjectOfType:@"QuinceObject"];
	[self copyParamsOf:victim into:quince];
    
     for(QuinceObject * sub in [victim valueForKey:@"subObjects"])
         [quince addSubObject:[sub copy] withUpdate:NO];
    
    [quince update];
    
    // preparations
    double lastTime = 0, time = 0;
    long i = 0;
    float progress = 0;
    [grid sortChronologically];
    NSArray * affectedQuinces, * subs = [grid valueForKey:@"subObjects"];
    if(![subs count]){
        [document presentAlertWithText:@"no subObjects in the grid!"];
        [self done];
        return;
    }
    // fast forward until we have the first sub with a start > 0
    while([[[subs objectAtIndex:i]valueForKey:@"start"]doubleValue]<=0 && i<[subs count]) i++; 
    //NSLog(@"alright");
    [document setProgressTask:@"splitting..."];
    [document setProgress:progress];
    [document displayProgress:YES];
    
    while(i<[subs count]){
        // get times
        q = [subs objectAtIndex:i++];
        lastTime = time;
        time = [[q valueForKey:@"start"]doubleValue];
        // split
        [quince splitAtTime:[NSNumber numberWithDouble:time]];
        // fold affected subs
        
        affectedQuinces = [quince subObjectsInTimeRangeFrom:[NSNumber numberWithDouble:lastTime] until:[NSNumber numberWithDouble:time]];
          
        [quince foldObjects:affectedQuinces];
        progress = (100.0/[subs count])*i;
        [document setProgress:progress];
    }
    // fold remaining subs
    if([[quince end]doubleValue]> time){
        affectedQuinces = [quince subObjectsAfterTime:[NSNumber numberWithDouble:time]];
        if([affectedQuinces count])
            [quince foldObjects:affectedQuinces];
    }
    
    [quince update];
	[quince setValue:[NSString stringWithFormat:@"%@_Split", [victim valueForKey:@"name"]] forKey:@"name"];
    [document displayProgress:NO];
    [self done];

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
