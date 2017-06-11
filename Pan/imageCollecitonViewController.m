//
//  imageCollecitonViewController.m
//  Pan
//
//  Created by SWUCOMPUTER on 2017. 5. 25..
//  Copyright © 2017년 Pan. All rights reserved.
//

#import "imageCollecitonViewController.h"
#import "imageCollectionViewCell.h"

@interface imageCollecitonViewController ()<UICollectionViewDelegate , UICollectionViewDataSource>{
    NSMutableArray *imgList;
    FIRDatabaseHandle _refHandle;
    NSUInteger _imageLength;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation imageCollecitonViewController

@synthesize ref;
@synthesize imageTable;

@synthesize loginId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imgList = [[NSMutableArray alloc] init];
    [self configureDatabase];
    // Do any additional setup after loading the view.
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    
//    imgList = [[NSMutableArray alloc] initWithObjects:
//               @"img01.jpg",@"img02.jpg",@"img03.jpg",@"img04.jpg",@"img05.jpg",
//               @"img06.jpg",@"img07.jpg",@"img08.jpg",@"img09.jpg",nil];
    
    
    }

- (void)configureDatabase {
    
    ref = [[FIRDatabase database] reference];
    
    _refHandle = [[[ref child:@"Week"] child: loginId] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [imageTable addObject:snapshot];
        
        _imageLength = imageTable.count;
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return imgList.count;
}


//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    FIRDataSnapshot *imageSnapshot = imageTable[indexPath.row];
//    NSDictionary<NSString *, NSString *> *image = imageSnapshot.value;
//    NSString *name = image[];
//    NSString *imageURL = image[MessageFieldsimageURL];
//    
//    static NSString *cellIdentifier = @"imageCell";
//    imageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    [cell.imgBg setImage:[UIImage imageNamed:[imgList objectAtIndex:indexPath.item]]];
//    
////    for(int i = 0; i<_imageLength; i++){
////        FIRDataSnapshot *imgSnapshot = imageTable[i];
////        imgSnapshot.value;
////    }
//    
//    if ([imageURL hasPrefix:@"gs://"]) {
//        [[[FIRStorage storage] referenceForURL:imageURL] dataWithMaxSize:INT64_MAX completion:^(NSData *data, NSError *error) {
//                                                                  if (error) {
//                                                                      NSLog(@"Error downloading: %@", error);
//                                                                      return;
//                                                                  }
//                                                                  cell.imageView.image = [UIImage imageWithData:data];
//                                                                  [collectionView reloadData];
//                                                              }];
//    }
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
