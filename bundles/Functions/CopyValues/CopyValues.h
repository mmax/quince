//
//  CopyValues.h
//  quince
//
//  Created by Maximilian Marcoll on 2/10/14.
//  Copyright (c) 2014 Maximilian Marcoll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuinceApi/Function.h>
#import <QuinceApi/QuinceObject.h>

@interface CopyValues : Function{

    IBOutlet NSPanel * window;
    IBOutlet NSPopUpButton * sourcePopUp;
    IBOutlet NSPopUpButton * targetPopUp;
}

-(IBAction)go:(id)sender;
-(IBAction)cancel:(id)sender;

@end
