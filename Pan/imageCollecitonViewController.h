//
//  imageCollecitonViewController.h
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 25..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Firebase;

@interface imageCollecitonViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *imageTable;

@property (strong, nonatomic) NSString *loginId;

@end
