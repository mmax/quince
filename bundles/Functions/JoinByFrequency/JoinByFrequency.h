//
//  JoinByFrequency.h
//  quince
//
//  Created by max on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObject.h>
#import <QuinceApi/QuinceDocument.h>


@interface JoinByFrequency : Function {
	
	IBOutlet NSTextField * percentageField;
	IBOutlet NSPanel * window;
	float maxCent;
	QuinceObject * mom;
	QuinceObject * source;
	
}

-(IBAction)cancel:(id)sender;
-(IBAction)go:(id)sender;
-(void)joinNextFrom:(int)index into:(QuinceObject *)j;
@end
