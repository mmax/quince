//
//  CsoundPlayer.m
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

#import "CsoundPlayer.h"


@implementation CsoundPlayer

-(CsoundPlayer *)init{

	if((self = [super init])){
		[NSBundle loadNibNamed:@"CsoundPlayerWindow" owner:self];
		[scoreView setRichText:NO];
		[[scoreView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
        [self initModes];
        [self setOrcs];
        [self setDefaultMode:nil];
	}
	return self;
}


-(void)dealloc{

	if(csound){
		csoundStop(csound);
		//csoundReset(csound);
		//csoundDestroy(csound);
        //free(csound);
	}
	[super dealloc];
}


-(void)prepare{
    [document setIndeterminateProgressTask:@"preparing objects..."];
	flatQuinceList = [document playbackObjectList];
    [self fetchCommonParametersForArrayOfQuinces:flatQuinceList];
}

-(void)fetchCommonParametersForArrayOfQuinces:(NSArray *)a{
    
    [document setProgressTask:@"fetching common parameters..."];
    [self removeObjectForKey:@"commonParameters"];
    QuinceObject * quince = [a lastObject]; // need ANY quince to use it's methods
    NSMutableArray * common = [[[NSMutableArray alloc]init] autorelease];
    int i=0;
    float f = 100.0/[a count];
    NSArray * ek = [self excludedParameters];
    
    for(QuinceObject * q in a){
        [document setProgress:f*i++];
        
        for(NSString * s in [q allKeys]){
            if(![quince isString:s inArrayOfStrings:ek] && 
               ![quince isString:s inArrayOfStrings:common] &&
               [self doAllObjectsInArray:a haveAValueForKey:s]){
                        
                [common addObject:s];
            }
        }
    }
    [common sortUsingSelector:@selector(compare:)];
    [self setValue:common forKey:@"commonParameters"];
}


-(BOOL)doAllObjectsInArray:(NSArray *)a haveAValueForKey:(NSString *)key{
    
    for(QuinceObject * q in a){
    
        if(![q valueForKey:key])
            return NO;
    }
    return YES;
}

-(void)setup{

	if(![self document] || isPlaying) return;

    [document setIndeterminateProgressTask:@"setup..."];
    [document displayProgress:YES];
    [self prepare];
    [document setIndeterminateProgressTask:@"creating instance of csound..."];
	
	if(!csound) csound = csoundCreate(self);
	[self writeCSD]; 
}


-(void)play{
	[self setup];

    NSLog(@"resetting...");
	csoundReset(csound);
	NSLog(@"CSoundPlayer:reset");

    [document setIndeterminateProgressTask:@"setting up csound..."];
    [document displayProgress:YES];
    
	[self setIsPlaying:YES];
	timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setCursor) userInfo:nil repeats:YES];
	char * command[5];
	command[0] = "./dummy";
	command[1] = "-do";
	command[2] = "dac";
	command[3] = "-+rtaudio=PortAudio";
	command[4] = "/tmp/quince.csd";
	int argc = 5;
	
	CSUserData * ud; 
	ud = (CSUserData *)malloc(sizeof(CSUserData)); 
	ud->csound = csound;
	ud->result = csoundCompile(csound, argc, command);
	ud->player = self;
	
	csoundSetScoreOffsetSeconds(csound, [[document valueForKey:@"playbackStartTime"]doubleValue]);
	csoundCreateThread(csThread,(void*)ud); 
    [document displayProgress:NO];	
}


-(void)mixDown{
	
    NSString* path = [self getMixDownFilePath];
    if(!path)
        return;
    
    
    [document setIndeterminateProgressTask:@"setting up csound..."];
    [document displayProgress:YES];
    
    [self setup];
    
    NSLog(@"resetting...");
	csoundReset(csound);
	NSLog(@"CSoundPlayer:reset");
	
	char * command[4];
	command[0] = "./dummy";
	command[1] = "-Ado";
	command[2] = (char *)[path UTF8String];
	command[3] = "/tmp/quince.csd";
	int argc = 4;
	
    CSOUND *CSound = csoundCreate(NULL);
    int result = csoundCompile(CSound, argc, command);
    
    [document setIndeterminateProgressTask:@"bouncing..."];

    if (result == 0) {
        result = csoundPerform(CSound);
    }
    csoundDestroy(CSound);

    [document displayProgress:NO];

}


-(void) csoundThreadRoutine:(CsoundPlayer *)sp {
}


uintptr_t csThread(void *data)  { 
	CSUserData* udata = (CSUserData*)data; 
	if(!udata->result) { 
		udata->result = csoundPerform(udata->csound);
		//udata->csound = nil;
		if(udata->result!=0){
			CsoundPlayer *cs = (CsoundPlayer *)udata->player;
			[cs stop];
		}
	}       
	return 1; 
}

//static void * csoundCallback(CSOUND * csound,int attr, const char *format, va_list valist) {
//	return 0;
//}

-(void)stop{
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc]init];
    [document setIndeterminateProgressTask:@"stopping csound..."];
    [document displayProgress:YES];
    NSLog(@"CSoundPlayer: STOPPING______________________");
//    csoundDestroy(csound);
	csoundStop(csound);	
   // csoundReset(csound);
    [timer invalidate];	
	
	[document setCursorTime:[document valueForKey:@"playbackStartTime"]];
    NSLog(@"CSoundPlayer:stopped");
	[self setIsPlaying:NO];
    [document displayProgress:NO];
    [p release];
}


-(void)setCursor{
	if(csound)
		[document setCursorTime:[NSNumber numberWithDouble:csoundGetScoreTime(csound)]];
}

-(NSArray *)excludedParameters{

	return [NSArray arrayWithObjects:@"type", @"nonStandardReadIn", @"resampled", @"sampleRate", @"samplesPerWindow", @"windowDuration", @"offsetKeys", @"id", @"date", @"color", @"subObjects", @"startOffset", @"volumeOffset", @"start", @"volume", @"duration", @"compatible", @"superObject", @"pitchOffset", @"centOffset", nil];
}

-(BOOL)excludedParametersInclude:(NSString *)pam{
    
	for(NSString * s in [self excludedParameters]){
	
		if ([s isEqualToString:pam])
			return YES;
	}
	return NO;
}

-(void)removeExcludedKeysFromArray:(NSMutableArray*)pams{

    [document setIndeterminateProgressTask:@"removing excluded keys..."];
	
    BOOL flag = NO;
	for(NSString *s in pams){
		if ([s isEqualToString:@"mediaFileName"]){
			[pams removeObject:s];
			flag  =YES;
			break;
		}
	}
	if(flag) [pams addObject:@"mediaFileName"];
	
	for(NSString * s in pams){
		if([self excludedParametersInclude: s]){
			[pams removeObject:s];
			[self removeExcludedKeysFromArray:pams];
			return;
		}
	}
}

-(void) writeCSD {
  	[document setIndeterminateProgressTask:@"writing csd..."];
    [document displayProgress:YES];
	NSLog(@"writeCSD");
	NSMutableString * csd = [[NSMutableString alloc]init];
	
	[csd appendFormat:@"<CsoundSynthesizer>\n<CsInstruments>\n"];
	[self writeOrc:csd];
	
	[csd appendFormat:@"\n\n</CsInstruments>\n<CsScore>\n"];
    
    NSMutableString * score = [[[NSMutableString alloc]init]autorelease];
	[self writeSco:score];
    [self setValue:score forKey:@"scoreString"];
    
	//[self writeSco:csd];
    [csd appendString:[self valueForKey:@"scoreString"]];
	[csd appendFormat:@"\n\n</CsScore>\n</CsoundSynthesizer>\n"];
	NSError * err;
	if(![csd writeToFile:@"/tmp/quince.csd" atomically:YES encoding:NSUTF8StringEncoding error:&err]){
		NSLog(@"could not write csd!");
		NSLog(@"%@", err);
	}
	[csd release];
}


-(void)writeOrc:(NSMutableString *)csd{
	[document setIndeterminateProgressTask:@"writing orc..."];
    [document displayProgress:YES];
	[csd appendString:[orcView string]];
}

-(void)writeSco:(NSMutableString *)csd{

    [document setIndeterminateProgressTask:@"writing score..."];
    [document displayProgress:YES];
    NSArray * commonParameters = [self valueForKey:@"commonParameters"];
	[csd appendFormat:@"f1 0 4096 10 1\n\n\n;i#     start           dur          vol      "];
	for(NSString * s in commonParameters)
		[csd appendFormat:@"%@     ", s ];
	int mode;
	[csd appendFormat:@"\n\n\n"];
	
	for(QuinceObject * q in flatQuinceList){
		if([q isOfType:@"envelope"] || [[q valueForKey:@"muted"]boolValue]==YES);
		else{
            mode = [self modeForQuince:q];
 			[csd appendFormat:@"i%d     %f     %f     %f     ", mode, [[q valueForKey:@"start"]doubleValue], [[q valueForKey:@"duration"]doubleValue], [[q valueForKey:@"volume"]doubleValue]];
			for(NSString * s in commonParameters){
				id val = [q valueForKey:s];
				if([s isEqualToString:@"audioFileName"] || [s isEqualToString:@"mediaFileName"])
					val = [[document objectWithValue:[q valueForKey:s] forKey:@"name"]valueForKey:@"filePath"];


				if(val){
					if([val isKindOfClass:[NSString class]])//if([[val className]isEqualToString:@"NSCFString"])
						[csd appendFormat:@"\"%@\"   ", val];
					else
						[csd appendFormat:@"%@   ", val];
				}
				else 
					[csd appendFormat:@"0   "];
			}
			[csd appendFormat:@"\n"];
		}
	}

}

-(CSOUND *)csound{return csound;}

-(NSPanel *)window{return window;}

-(void)showWindow{
    [document displayProgress:YES];
	[self prepare];
	NSMutableString * score = [[[NSMutableString alloc]init]autorelease];
	[self writeSco:score];
    [self setValue:score forKey:@"scoreString"];
	[[self window]makeKeyAndOrderFront:nil];

    [document displayProgress:NO];
}

-(NSDictionary *)settings{

	NSMutableDictionary * s = [[NSMutableDictionary alloc]init];
	
	[s setValue:[orcView string] forKey:@"orc"];
    [s setValue: [modeMenu titleOfSelectedItem] forKey:@"defaultModeName"];
	return [s autorelease];
}

-(void)setSettings:(NSDictionary *)settings{
    [self setValue:[settings valueForKey:@"orc"] forKey:@"orcString"];
    [modeMenu selectItemWithTitle:[settings valueForKey:@"defaultModeName"]];
    [self setDefaultMode:self];
}

-(IBAction)ok:(id)sender{
    
    [super ok:sender];

}

-(void)setOrcs{
    NSMutableString * orc = [[[NSMutableString alloc]init] autorelease];
    [self writeHeader:orc];
    [self setWinOrc:orc];  
    [self setClickOrc:orc];
    [self setGlissOrc:orc];
    [self setPitchOrc:orc];
    [self setValue:orc forKey:@"orcString"];
}

-(void)setClickOrc:(NSMutableString *)orc{

	int inum = [self instrumentNumberForMode:@"Clicks"];
	//instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
	[orc appendFormat:@"instr %d			;Clicks\n\n", inum];
	[orc appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
	[orc appendFormat:@"kenv\tlinseg\tiamp, .01, 0\n"];
	[orc appendFormat:@"a1\trand\tkenv\n"];
	[orc appendFormat:@"\touts\ta1, a1\n"];
	[orc appendFormat:@"endin\n\n"];

}

-(void)setWinOrc:(NSMutableString *)orc{
	
    int inum = [self instrumentNumberForMode:@"AudioFiles"];
	//instruments
	[orc appendFormat:@"instr %d			;AudioFiles\n\n", inum];
	[orc appendFormat:@"iamp\t=\tampdb(p4)\n"];
	[orc appendFormat:@"a1\tdiskin\tp8, 1, p2\n"];
	[orc appendFormat:@"kenv\tlinseg\t0, .004, 1, p3-.008, 1, .004, 0\n"];
	[orc appendFormat:@"\t\touts a1*kenv*iamp, a1*kenv*iamp\n"];
	[orc appendFormat:@"endin\n\n"];
}

-(void)setPitchOrc:(NSMutableString *)orc{

    
    int inum = [self instrumentNumberForMode:@"Pitches"];
	//instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
	[orc appendFormat:@"instr %d			;Pitches\n\n", inum];
	[orc appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
	[orc appendFormat:@"kenv\tlinseg\t0, .005, 1, p3-.01, 1, .005, 0\n"];
	[orc appendFormat:@"a1\toscil\tiamp, p7, 1\n"];
	[orc appendFormat:@"\touts\ta1*kenv, a1*kenv\n"];
	[orc appendFormat:@"endin\n\n"];	
}

-(void)setGlissOrc:(NSMutableString *)orc{
	
    int inum = [self instrumentNumberForMode:@"Glissando"];	
    //instruments
	[orc appendFormat:@";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n"];
    [orc appendFormat:@"instr %d			;Glissando\n\n", inum];
	[orc appendFormat:@"iamp\t=\tampdb(p4+90)\n"];
	[orc appendFormat:@"ifl\t=\tp7\n"];
	[orc appendFormat:@"ifh\t=\tp8\n"];
	[orc appendFormat:@"idir\t=\tp9\n"];    
    [orc appendFormat:@"if (idir == 0) then\n"];
    [orc appendFormat:@"kfreq\texpon\tifh, p3, ifl\n"];
    [orc appendFormat:@"elseif (idir > 0) then\n"];
    [orc appendFormat:@"kfreq expon ifl, p3, ifh\nendif\n"];
    [orc appendFormat:@"kenv\tlinseg\t0, .005, 1, p3-.01, 1, .005, 0\n"];
	[orc appendFormat:@"a1\toscil\tiamp, kfreq, 1\n"];
	[orc appendFormat:@"\touts\ta1*kenv, a1*kenv\n"];
	[orc appendFormat:@"endin\n\n"];
}

-(void)writeHeader:(NSMutableString *)s{
	[s appendFormat:@"\nsr = 44100\nkr = 44100\nksmps = 1\nnchnls = 2\n\n\n\n"];
}

-(int)instrumentNumberForMode:(NSString *)mode{
    //NSLog(@"instrumentNumberForMode: '%@' : %@ - number: %@", mode, [[self valueForKey:@"modes"]valueForKey:mode],[[[self valueForKey:@"modes"]valueForKey:mode]valueForKey:@"instrumentNumber"] );
    return [[[[self valueForKey:@"modes"]valueForKey:mode]valueForKey:@"instrumentNumber"]intValue];
}

-(int)modeForQuince:(QuinceObject *)q{

    int mode;
    NSString * v = [q valueForKey:@"csoundMode"];
    QuinceObject * m = q;

    if(v){
        mode = [self instrumentNumberForMode:v];
    }
    
    v = [q valueForKey:@"csoundInstrumentNumber"];

    if(!v){
        while(!v && [m isChild]){
            m = [m superObject];    
            v = [m valueForKey:@"csoundInstrumentNumber"];
        }
    }

    if(!v){
        mode = [[self valueForKey:@"defaultMode"]intValue];
    }
    
    if(v) mode = [v intValue];
    
    if(mode >0)
        return mode;
    
    return [[self valueForKey:@"defaultMode"]intValue];
}

-(IBAction)setDefaultMode:(id)sender{

    [self setValue:[NSNumber numberWithInt:[self instrumentNumberForMode:[modeMenu titleOfSelectedItem]]] forKey:@"defaultMode"];
   
    [document displayProgress:YES];
	[self prepare];
	NSMutableString * score = [[[NSMutableString alloc]init]autorelease];
	[self writeSco:score];
    [self setValue:score forKey:@"scoreString"];
    [document displayProgress:NO];
}

-(void)initModes{

    NSArray * modes = [[NSArray alloc]initWithObjects:@"AudioFiles", @"Clicks", @"Glissando", @"Pitches", nil];
    NSMutableDictionary * modeDicts = [[[NSMutableDictionary alloc ]init]autorelease];
    NSMutableDictionary * singleModeDict;
    NSMenuItem * item;
    int i = 1;
    for(NSString * s in modes){
        item = [[[NSMenuItem alloc]init]autorelease];
        [item setTitle:s];
        [item setTarget:self];
        [item setAction:@selector(setDefaultMode:)];
        [[modeMenu menu] addItem:item];
        
        singleModeDict = [[[NSMutableDictionary alloc]init]autorelease];
        
        [singleModeDict setValue:s forKey:@"name"];
        [singleModeDict setValue:[NSNumber numberWithInt:i] forKey:@"instrumentNumber"];
        
        [modeDicts setValue:singleModeDict forKey:s];
        i++;
    }
    [self setValue:modeDicts forKey:@"modes"];
}

@end
