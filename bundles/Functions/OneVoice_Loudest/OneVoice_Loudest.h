//
//  OneVoice_Loudest.h
//  quince
//
//  Created by max on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/DataFile.h>
#import <QuinceApi/QuinceDocument.h>


@interface OneVoice_Loudest : Function {

	QuinceObject * mom;
}

-(QuinceObject*)loudestQuinceInArray:(NSArray *)fruit;
-(NSArray *)subObjectsStartingAtTime:(double)t;
-(double)nextSubTimeAfter:(double)t;

@end
