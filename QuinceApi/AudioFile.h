//
//  MintFile.h
//  MINT
//
//  Created by max on 3/5/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataFile.h"

//@class QuinceObject;
@interface AudioFile : DataFile { // maybe this should be "media file"
	
}
//-(void)openFile;
//-(NSString *)getPath;
-(void)registerLinkedObject:(QuinceObject *)quince rename:(BOOL)b;
-(int)getNewLinkedObjectNamePostfixNumber;
-(void)unregisterLinkedObject:(QuinceObject *)quince;

@end

