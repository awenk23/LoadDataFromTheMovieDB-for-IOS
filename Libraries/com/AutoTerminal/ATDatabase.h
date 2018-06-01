//
//  ATDatabase.h
//  AEMC
//
//  Created by i'Mac on 8/7/14.
//  Copyright (c) 2014 i'Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    kATContextTypeMaster = 0,
    kATContextTypeMain,
    kATContextTypeTemp,
    
    
} kATContextType;

@interface ATDatabase : NSObject

@property (nonatomic, retain) NSManagedObjectContext* tempMOC;
@property (nonatomic, retain) NSManagedObjectContext* mainMOC;
@property (nonatomic, retain) NSManagedObjectContext* masterMOC;

-(id) initWithDBName:(NSString*) dbName persistent:(BOOL)persistent;
-(void) saveContextType:(kATContextType)contextType;
-(void) clearPersistentData;

@end
