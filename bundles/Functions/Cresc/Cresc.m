//
//  Cresc.m
//  quince
//
//  Created by Maximilian Marcoll on 1/10/16.
//  Copyright (c) 2016 Maximilian Marcoll. All rights reserved.
//

#import "Cresc.h"

@implementation Cresc

-(void)perform{
    
    QuinceObject * quince, * mum = [self objectForPurpose:@"source"];
    NSArray * subs = [mum subObjects];
    double top=-999.9, bot=999.9, c, delta;
    long i;
    for(QuinceObject * q in subs){
        c = [[q valueForKey:@"volume"]doubleValue];
        if(c>top)top=c;
        if(c<bot)bot=c;
    }
    [mum sortChronologically];
    
    delta = fabs(top-bot)/([subs count]-1);
    
    for(i=0;i<[subs count];i++){
        quince = [subs objectAtIndex:i];
        c = bot+delta*i;
        [quince setValue:[NSNumber numberWithDouble:c]forKey:@"volume"];
    }
    
    [self setOutputObjectToObjectWithPurpose:@"source"];
    [self done];
}

@end
