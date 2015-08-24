//
//  ExportParameterListing.h
//  quince
//
//  Created by Maximilian Marcoll on 6/27/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QuinceApi/Function.h>
#import "QuinceObject.h"
#import "QuinceDocument.h"

@interface ExportParameterListing : Function {

    IBOutlet NSPanel * window;
    IBOutlet NSPopUpButton * pop;
}

-(IBAction)exportParameter:(id)sender;
-(IBAction)cancel:(id)sender;
-(NSString *)generateListing;
-(NSString *)getStringValueOf:(id)value;
@end
