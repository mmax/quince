//
//  Sum.h
//  quince
//
//  Created by Maximilian Marcoll on 12/8/15.
//  Copyright (c) 2015 Maximilian Marcoll. All rights reserved.
//

#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/QuinceObject.h>


@interface Sum : Function

-(NSMutableArray *) getPoints:(QuinceObject *)q;
-(void) createSeqForTimePointsInArray: (NSArray *)points fromQuinceObject:(QuinceObject *)m intoQuinceObject:(QuinceObject *)q;
-(void) cleanUp:(QuinceObject *)q;
-(double) sumForParameter:(NSString *)s inArrayOfObjects:o;
-(double)a2dB:(double)a;
-(double)dB2a:(double)dB;
@end
