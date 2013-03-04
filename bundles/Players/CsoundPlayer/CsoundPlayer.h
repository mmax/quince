//
//  CsoundPlayer.h
//  quince
//
//  Created by max on 8/26/10.
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
#import <QuinceApi/Player.h>
#import <QuinceApi/QuinceDocument.h>
#import <QuinceApi/QuinceObjectController.h>
#import <CsoundLib/csound.h>


typedef struct _userData { 
	int result; 
	CSOUND* csound; 
	bool PERF_STATUS; 
	void * player;
} CSUserData;


@interface CsoundPlayer : Player {

	CSOUND *csound;
	NSTimer * timer;
	IBOutlet NSPanel * window;
	IBOutlet NSTextView * orcView;
	IBOutlet NSTextView * scoreView;
    IBOutlet NSPopUpButton * modeMenu;
	NSAutoreleasePool * pool;    
}

-(void)fetchCommonParametersForArrayOfQuinces:(NSArray *)a;
-(BOOL)doAllObjectsInArray:(NSArray *)a haveAValueForKey:(NSString *)key;
-(void)prepare;
-(NSArray *)excludedParameters;
-(BOOL)excludedParametersInclude:(NSString *)pam;
-(void)removeExcludedKeysFromArray:(NSMutableArray*)pams;
-(void)setCursor;
-(void)writeCSD;
-(void)writeOrc:(NSMutableString *)csd;
-(void)writeSco:(NSMutableString *)csd;

-(void) csoundThreadRoutine:(CsoundPlayer *)sp;

static void * csoundCallback(CSOUND * csound,int attr, const char *format, va_list valist);
uintptr_t csThreadMD(void *data);
uintptr_t csThread(void *data);
-(CSOUND *)csound;
-(void)setOrcs;
-(void)setClickOrc:(NSMutableString*)s;
-(void)setWinOrc:(NSMutableString*)s;
-(void)setPitchOrc:(NSMutableString*)s;
-(void)setGlissOrc:(NSMutableString*)s;
-(void)writeHeader:(NSMutableString *)s;
-(int)instrumentNumberForMode:(NSString *)mode;
-(int)modeForQuince:(QuinceObject *)q;
-(IBAction)setDefaultMode:(id)sender;
-(void)initModes;
@end
