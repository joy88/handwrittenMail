//
//  RefreshConst.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-23.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import Foundation
import CoreGraphics

let RefreshViewHeight: CGFloat = 64.0
let RefreshSlowAnimationDuration:NSTimeInterval = 0.3
let RefreshFooterPullToRefresh:NSString = BaseFunction.getIntenetString("上拉可以加载更多数据")
let RefreshFooterReleaseToRefresh:NSString =  BaseFunction.getIntenetString("松开立即加载更多数据")
let RefreshFooterRefreshing:NSString =  BaseFunction.getIntenetString("正在加载数据...")
let RefreshHeaderPullToRefresh:NSString =  BaseFunction.getIntenetString("上拉可以刷新")
let RefreshHeaderReleaseToRefresh:NSString =  BaseFunction.getIntenetString("松开立即刷新")
let RefreshHeaderRefreshing:NSString = BaseFunction.getIntenetString("正在刷新中...")
let RefreshHeaderTimeKey:NSString =  "RefreshHeaderView"
let RefreshContentOffset:NSString =  "contentOffset"
let RefreshContentSize:NSString =  "contentSize"

 