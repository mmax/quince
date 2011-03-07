//
//  QuinceObjectTest.h
//  QuinceApi
//
//  Created by max on 3/15/10.
//  Copyright 2010 Maximilian Marcoll. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@class QuinceObject, QuinceObjectController;

@interface QuinceObjectTest : SenTestCase {

	QuinceObject * quince;
	QuinceObject * quinceChild2;
}

-(QuinceObject *)newObjectOfClassNamed:(NSString *)className;
-(QuinceObjectController *)controllerForNewObjectOfClassNamed:(NSString *)name inPool:(BOOL)addToPool;

@end
