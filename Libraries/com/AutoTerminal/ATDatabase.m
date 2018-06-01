//
//  ATDatabase.m
//  AEMC
//
//  Created by i'Mac on 8/7/14.
//  Copyright (c) 2014 i'Mac. All rights reserved.
//
#import "ATDatabase.h"
#import <UIKit/UIKit.h>

@interface ATDatabase() {
    
    NSString* _dbName;
    NSString* _dbNameExt;
    BOOL _persistent; // NO - cache data, will not be backed up to iCloud, YES - user data, will be backed up
    
    NSManagedObjectModel* _managedObjectModel;
    NSPersistentStoreCoordinator* _persistentStoreCoordinator;
    
}

@end

@implementation ATDatabase

-(id) initWithDBName:(NSString*) dbName persistent:(BOOL)persistent {
    
    if (self == [super init]) {
        _dbName = dbName;
        _dbNameExt = [dbName stringByAppendingString:@".sqllite"];
        _persistent = persistent;
    }
    
    return self;
}


#pragma mark - Public Methods
- (void) clearPersistentData {
    
    [self removeLocalCopyOfDatabase];
    _managedObjectModel = nil;
    _persistentStoreCoordinator = nil;
    self.tempMOC = nil;
    self.mainMOC = nil;
    self.masterMOC = nil;
    
}

- (void) saveContextType:(kATContextType)contextType
{
    NSError *error = nil;
    NSManagedObjectContext *context;
    
    switch (contextType) {
        case kATContextTypeTemp:
            context = self.tempMOC;
            break;
        case kATContextTypeMain:
            context = self.mainMOC;
            break;
            
        default:
            break;
    }
    
    if (context != nil) {
        if ([context hasChanges]) {
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } else {
                [self saveMasterContext];
            }
        }
    }
}


#pragma mark - Private methods
- (void) saveMasterContext
{
    NSError *error = nil;
    NSManagedObjectContext *masterContext = [self masterMOC];
    
    if (masterContext != nil) {
        
        if ([masterContext hasChanges]) {
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:masterContext];
            
            if (![masterContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [notificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:masterContext];
        }
    }
}

#pragma mark -  Notification delegates
- (void) contextChanged:(NSNotification*)notification
{
    // Only interested in merging from master to main
    if ([notification object] == _masterMOC) {
    
        if (![NSThread isMainThread]) {
            [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
            return;
        }
        
        @synchronized(self) {
            [self.mainMOC performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
            
            [self.mainMOC performBlock:^{
                [self.mainMOC mergeChangesFromContextDidSaveNotification:notification];
            }];
        }

    }
    
}


#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)masterMOC
{
    if (_masterMOC == nil) {
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _masterMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_masterMOC setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return _masterMOC;

}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)mainMOC
{

    if (_mainMOC == nil) {
    
        if ([self masterMOC] != nil) {
            _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainMOC setUndoManager:nil];
            [_mainMOC setParentContext:[self masterMOC]];
        }
    
    }
    return _mainMOC;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)tempMOC
{

    if (_tempMOC == nil) {
    
        if ([self masterMOC] != nil) {
            _tempMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
            [_tempMOC setUndoManager:nil];
            [_tempMOC setParentContext:[self masterMOC]];
        }
    
    }

    return _tempMOC;

}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_dbName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

        // This is the recommended way so we don't have to worry about extension mom or momd
        // It's unused because it will not allow use of multiple object models with the same name
        //_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    }
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:_dbNameExt];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // if persistent, option = nil, else option journal_mode DELETE - means the database will not be backed up during PC/iCloud sync
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:(_persistent ? nil : @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"}}) error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        // remove local copy
        [self removeLocalCopyOfDatabase];
        
        // create new copy
        //[self createEditableCopyOfDatabaseIfNeeded];
        // retry
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Database Error" message:@"Inconsistent data structure. Please contact support!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            
            
            _persistentStoreCoordinator = nil;
        }
        
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Initialize our writable copy of the database

- (void) createEditableCopyOfDatabaseIfNeeded {
    // First test for existence - we don't want to wipe out a user's DB
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDir = [self applicationDocumentsDirectory];
    NSURL *writableDBPath = [documentsDir URLByAppendingPathComponent:_dbNameExt];
    
    BOOL dbExists = [fileManager fileExistsAtPath:[writableDBPath path]];
    if (!dbExists) {
        // The writable DB doesn't exist so we'll copy our default one there.
        NSURL *defaultDBPath = [[NSBundle mainBundle] URLForResource:_dbName withExtension:@"sqllite"];
        NSError *error;
        BOOL success = [fileManager copyItemAtURL:defaultDBPath toURL:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
}

- (void) removeLocalCopyOfDatabase {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDir = [self applicationDocumentsDirectory];
    NSURL *writableDBPath = [documentsDir URLByAppendingPathComponent:_dbNameExt];
    
    BOOL dbExists = [fileManager fileExistsAtPath:[writableDBPath path]];
    if (dbExists) {
        
        NSError *error;
        BOOL success = [fileManager removeItemAtURL:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete writable database file with message '%@'.", [error localizedDescription]);
        }
    }
}

@end
