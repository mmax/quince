//
//  Rectify.h
//  quince
//
//  Created by Maximilian Marcoll on 5/27/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//

#import "Function.h"
#import <QuinceApi/QuinceDocument.h>
#import "QuinceObject.h"

@interface Rectify : Function
-(double)rectifyQuince:(QuinceObject *)q betweenA:(QuinceObject *)A andB:(QuinceObject *)B;
-(int)findGridIndexForQuince:(QuinceObject *)q;
-(void)copyParamsOf:(QuinceObject*)source into:(QuinceObject*)target;
    
    @end
