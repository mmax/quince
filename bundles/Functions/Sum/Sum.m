//
//  Sum.m
//  quince
//
//  Created by Maximilian Marcoll on 12/08/15.
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

#import "Sum.h"

@implementation Sum


// SUM creates a new sequence, containing the sum of all volume values of the source object's subObjects

-(void)perform{
    [document setIndeterminateProgressTask:@"copying..."];
    [document displayProgress:YES];

	QuinceObject * mum =[(QuinceObject *)[self objectForPurpose:@"source"]copy];
    [document setIndeterminateProgressTask:@"flattening copy..."];
    [document displayProgress:YES];

    [mum flatten];
    [mum sortChronologically];
    
    QuinceObjectController * resultController = [[self outputObjectOfType:@"QuinceObject"]controller];

    
	[mum sortChronologically];
	
    [self getPoints:mum];
    
    [self createSeqForTimePointsFromQuinceObject:mum intoQuinceObject:[resultController content]];
    [resultController update];
	[resultController setValue:[NSString stringWithFormat:@"%@_SUM", [mum valueForKey:@"name"]] forKeyPath:@"selection.name"];
    
    [document displayProgress:NO];

	[self done];
}

-(void) getPoints:(QuinceObject *)q{
    
    //NSLog(@"Sum: getPoints");
    [document setProgressTask:@"finding times points..."];


    NSArray * subs = [q valueForKey:@"subObjects"] ;
    long count = [subs count],i=0, index = 0;

    float progress = 0;
    //NSMutableArray * p = [[NSMutableArray alloc]init];
    pointCount = count * 2;
    
    points = malloc(sizeof(double)*pointCount);
    if(!points){
    
        [document presentAlertWithText:@"Could not allocate memory for storing data!"];
        return;
    }
    
    for(QuinceObject * sub in subs){
        
        //[p addObject:[NSNumber numberWithDouble:[(NSNumber *)[sub valueForKey:@"start"]doubleValue]]];
        //[p addObject:[NSNumber numberWithDouble:[(NSNumber *)[sub end]doubleValue]]];
        points[index++] = [[sub valueForKey:@"start"]doubleValue];
        points[index++] = [[sub end]doubleValue];
        
        progress = (100.0/count)*i++;
        
        [document setProgress:progress];
    }

    qsort(points, pointCount, sizeof(double), compare);
    
//    NSSortDescriptor *asc = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
//    [p sortUsingDescriptors:[NSArray arrayWithObject:asc]];
    //return [p autorelease];
}

-(void) createSeqForTimePointsFromQuinceObject:(QuinceObject *)m intoQuinceObject:(QuinceObject *)result{

   // NSLog(@"Sum: createSeq...");

    QuinceObject * q = nil;

    NSNumber * n = nil;
    double previousStart, p;
    int i;
    long index=0;
    float progress=0;
    
    [document setProgressTask:@"creating sum sequence..."];
    [document setProgress:0];
        [document displayProgress:YES];
    
    for(i = 0; i < pointCount-1;i++){ //counting to the n-1 because the last "point" is an end!
        //NSLog(@"count: %d/%ld", i, pointCount);
        
        //n = [points objectAtIndex:i];
        p = points[i];
        if(q){
            previousStart = [[q valueForKey:@"start"]doubleValue];
            [q setValue:[NSNumber numberWithDouble:p-previousStart] forKey:@"duration"];
        }
        
        n = [NSNumber numberWithDouble:p];
        NSArray * subs = [m subObjectsAtTime:n startLookingAtIndex:&index];
        double sum = [self sumForParameter:@"volume" inArrayOfObjects:subs];
        q = [[document controllerForNewObjectOfClassNamed:@"QuinceObject" inPool:NO]content];

        [q setValue:n forKey:@"start"];
        [q setValue:[NSNumber numberWithDouble:sum] forKey:@"volume"];
        [[result controller] addSubObjectWithController:[q controller] withUpdate:NO];//addSubObject:q withUpdate:NO];
        progress = (100.0/pointCount)*i;
        //NSLog(@"progress: %f", progress);
        [document setProgress:progress];
    }
    p = points[i];
    previousStart = [[q valueForKey:@"start"]doubleValue];                                          // we need to 
    [q setValue:[NSNumber numberWithDouble:p-previousStart] forKey:@"duration"];      // adjust the last q's duration
    [result update];
}

-(double) sumForParameter:(NSString *)s inArrayOfObjects:o{
   
    if([s isEqualToString:@"volume"]){
       
        double linSum = 0;
        
        for(QuinceObject * q in o)
            linSum += [self dB2a:[[q valueForKey:@"volume"] doubleValue]];
        
        return [self a2dB:linSum];
    }
    [document presentAlertWithText:@"SUM: NO MATCHING PARAMETER FOUND!"];
    return 0;
}

int compare(const void * a, const void * b){
    double A = *(double *)a;
    double B = *(double *)b;
    
    if(A>B)return 1;
    if(A<B)return -1;
    return 0;
}

-(double)a2dB:(double)a{ return 20*log10(a);}
-(double)dB2a:(double)dB{ return pow(10, dB/20.0);}
-(BOOL)worksOnSelection{return NO;}

@end
