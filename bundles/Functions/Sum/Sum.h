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


@interface Sum : Function{

    double * points;
    long pointCount;
}

-(void) getPoints:(QuinceObject *)q;
-(void) createSeqForTimePointsFromQuinceObject:(QuinceObject *)m intoQuinceObject:(QuinceObject *)q;
-(double) sumForParameter:(NSString *)s inArrayOfObjects:o;
-(double)a2dB:(double)a;
-(double)dB2a:(double)dB;
int compare(const void * a, const void * b);
@end
