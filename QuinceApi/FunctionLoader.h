//
//  FunctionLoader.h
//  quince
//
//  Created by max on 4/24/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//
//
//	If you have any questions contact quince@maximilianmarcoll.de
//
//	This file is part of quince.
//
//	quince is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	quince is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with quince.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>


@class QuinceDocument, Function;

@interface FunctionLoader : NSObject {

	IBOutlet NSArrayController * functionLoaderArrayController;
	IBOutlet NSPanel * panel;
	IBOutlet QuinceDocument * document;
	IBOutlet NSButton * actionButton;
	NSMutableDictionary * dictionary;
}

-(FunctionLoader *)init;
-(IBAction) clear:(id)sender;
-(IBAction) load:(id)sender;
-(IBAction) cancel:(id)sender;
-(IBAction) action:(id)sender;
-(id)valueForKey:(NSString *)key;
-(void)setValue:(id)value forKey:(NSString *)key;
-(void)awake;
-(void)awakeWithFunction:(Function *)function;
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(BOOL)readyForAction;
-(void)statusCheck;
@end
