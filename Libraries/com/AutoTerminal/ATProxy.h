//
//  ATProxy.h
//  AEMC
//
//  Created by i'Mac on 12/10/12.
//  Copyright (c) 2012 i'Mac. All rights reserved.
//

#import "Proxy.h"
#import "ATJSONRequest.h"
#import "ATGlobal.h"
#import "ATDatabase.h"

@interface ATProxy : Proxy <ATJSONRequestDelegate>

// Data source properties
@property (nonatomic, retain) NSString* cacheName; // For caching
@property (nonatomic, retain) NSString* entityName;
@property (nonatomic, retain) NSString* sectionKey; // For grouping
@property (nonatomic, retain) NSString* predicateFormat; // For filtering
@property (nonatomic, retain) NSArray* predicateArguments; // For filtering
@property (nonatomic, retain) NSArray* sortDescriptors; // For sorting
@property (nonatomic, retain) NSArray* sortKeys; // For sorting (keys)
@property (nonatomic, retain) NSArray* sortOrders; // For sorting (orders: 1 - ascending, 0 - descending)
@property (nonatomic, retain) NSFetchedResultsController* fetchedData;
@property (nonatomic, retain) ATDatabase* database;
@property (nonatomic, retain) ATJSONRequest* jsonRequest;

-(void) fetchLocalData;

- (id) fetchLocalDataWithContext:(NSManagedObjectContext*) managedObjectContext
                      entityName:(NSString*) entityName
                 sortDescriptors:(NSArray*)sortDescriptors
                       predicate:(NSPredicate*)predicate
                      sectionKey:(NSString*)sectionKey
                       cacheName:(NSString*)cacheName;

-(void) mergeData:(NSArray*)serverData
               insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
                  keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
           sortDescriptors:(NSArray*) sortDescriptors;

-(void) mergeDataWithUpdate:(NSArray*)serverData
                insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
                updateBlock:(void (^)(NSManagedObject* object, NSDictionary* dictionary, NSManagedObjectContext* context))updateBlock
                   keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
  sortDescriptors:(NSArray*) sortDescriptors;

-(void) appendData:(NSArray*)serverData
       insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
          keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
   sortDescriptors:(NSArray*) sortDescriptors;

-(void) appendDataWithUpdate:(NSArray*)serverData
                insertBlock:(NSManagedObject* (^)(NSManagedObjectContext* context))insertBlock
                updateBlock:(void (^)(NSManagedObject* object, NSDictionary* dictionary, NSManagedObjectContext* context))updateBlock
                   keyBlock:(NSString*(^)(NSDictionary* dictionary))keyBlock
            sortDescriptors:(NSArray*) sortDescriptors;

-(void) clearData;

@end
