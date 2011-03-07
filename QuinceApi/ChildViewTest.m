//
//  MintItemTest.m
//  QuinceApi
//
//  Created by max on 3/14/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import "ChildViewTest.h"
#import "ChildView.h"
#import "ContainerView.h"
#import "QuinceObject.h"

@implementation ChildViewTest

-(void)setUp{


	item = [[ChildView alloc]init];
	

}
	

-(void)testCenter{

	[item setLocation:NSMakePoint(1, 1)];
	[item setWidth:6 withUpdate:NO];
	[item setHeight:6 withUpdate:YES];
	

	STAssertEqualObjects([NSNumber numberWithFloat:[item center].x], [NSNumber numberWithFloat:4],@"center X wrong!" );
	STAssertEqualObjects([NSNumber numberWithFloat:[item center].y], [NSNumber numberWithFloat:4],@"center Y wrong!" );
}

-(void)testWidth{


}


@end
