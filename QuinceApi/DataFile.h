//
//  DataFile.h
//  MINT
//
//  Created by max on 6/16/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QuinceObject.h"

@interface DataFile : QuinceObject {

}
-(NSString *)getPath;
-(BOOL)openFile;
-(NSArray *)fileTypes;
-(NSString *)filePath;
@end
