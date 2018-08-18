//
//  Cubism3Timer.h
//  Cubism3-ARKit
//
//  Created by Yuma Matsune on 2018/08/18.
//  Copyright © 2018 matsune. All rights reserved.
//

#ifndef Cubism3Timer_h
#define Cubism3Timer_h

#import <Foundation/Foundation.h>

@interface Cubism3Timer : NSObject
/**
* @brief 時間を更新する。
*/
+ (void)update;

/**
 * @brief   デルタ時間（前回フレームとの差分）を取得する
 *
 * @return  デルタ時間[ms]
 *
 */
+ (double)getDeltaTime;

@end

#endif /* Cubism3Timer_h */
