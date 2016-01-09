//
//  SplitWithSeq.h
//  quince
//
//  Created by Maximilian Marcoll on 1/6/16.
//  Copyright (c) 2016 Maximilian Marcoll. All rights reserved.
//

#import "Function.h"

@interface SplitWithSeq : Function

-(void)copyParamsOf:(QuinceObject*)source into:(QuinceObject*)target;
-(void) updateDurationsForQuince:(QuinceObject*)q beginningAtTime:(double)t;
@end
