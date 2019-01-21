# Clear-TodoList-iOS
A delightful TodoList App for iOS



[![CocoaPods](http://img.shields.io/cocoapods/p/YYKit.svg?style=flat)](http://cocoadocs.org/docsets/YYKit)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%2011%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Build Status](https://travis-ci.org/ibireme/YYKit.svg?branch=master)](https://travis-ci.org/ibireme/YYKit)


Clear-TodoList-iOS is a copy of [iOS TODOList App Clear](http://www.realmacsoftware.com/clear/).

It had implemented majority of original App :
* Tap to Edit item
* Swipe to Complete or Delete item
* Pull to Add item
* Pinch to Add item
* LongPress to Move item

Demo Project
==============
| Effect效果  | GIF预览图 |
|-------|-------|
| **Pan Right To Complete 右滑完成** | ![Zoom](https://github.com/Gengj/Clear-TodoList-iOS/blob/master/Gif/complete.gif) | 
| **Pan Left To Delete 左滑删除** | ![Refresh](https://github.com/Gengj/Clear-TodoList-iOS/blob/master/Gif/delete.gif) |
| **LongPress To Move 长按移动** | ![Refresh](https://github.com/Gengj/Clear-TodoList-iOS/blob/master/Gif/move.gif) |
| **Pull Down To Add 下拉添加** | ![Refresh](https://github.com/Gengj/Clear-TodoList-iOS/blob/master/Gif/pullToAdd.gif) |
| **Pinch To Add 捏合添加** | ![Refresh](https://github.com/Gengj/Clear-TodoList-iOS/blob/master/Gif/pinchToAdd.gif) |

What's used
==============
* MVVM ： Custom TextField、UITableViewCell、UITableview
* GCD ： Implementing reading and writing NSKeyedArchiver in background sub-threads  
* CATransform3D ：make 3D Animation Effect of Cell

Notice
==============
* There have resetItems: in GAGItems.m，you can use it for debug
* GAGBaseViewController.m have used resetItem:，you can use or delete that code by your self
```
- (GAGItems *)items {
    if (_items == nil) {
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Welcome to Clear.plist" ofType:nil];
        _items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
               
        //可以使用items的重置方法进行调试
        [_items resetItems];
        [[GAGFileOperation sharedOperation]save:self.items];
    }
    return _items;
}
```

Requirements
==============
This library requires `iOS 11.0+` and `Xcode 9.0+`.
update 2019.1.21 : Already adapted to the iPhone X

Contact
==============
if have any problem , you can contact me :
* Issue
* EMail：35285770@qq.com
* QQ：35285770
* Wechat：AJ316G
---

中文介绍
==============
Clear-TodoList-iOS模仿了[iOS TODOList App Clear](http://www.realmacsoftware.com/clear/).

已经实现了大部分原程序的功能：
* 点击编辑条目
* 滑动标记完成或者删除条目
* 下拉新增条目
* 捏合新增条目
* 长按移动条目

所用技术
==============
* MVVM ： 自定义TextField、UITableViewCell、UITableview
* GCD ： 实现子线程NSKeyedArchiver后台读写
* CATransform3D ：实现Cell的3D动画效果

注意事项
==============
* GAGItems实现了resetItems方法，可以在调试时使用
* GAGBaseViewController.m使用了该方法，可以在调试时删除
```
- (GAGItems *)items {
    if (_items == nil) {
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"Welcome to Clear.plist" ofType:nil];
        _items = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
               
        //可以使用items的重置方法进行调试
        [_items resetItems];
        [[GAGFileOperation sharedOperation]save:self.items];
    }
    return _items;
}
```

系统要求
==============
该项目最低支持 `iOS 11.0` 和 `Xcode 9.0`。
更新 2019.1.21 : 已适配 iPhone X

相关文章
==============
[Ray Wenderlich's site about the creation of a gesture-driven to-do list application inspired by the iOS app Clear
](http://www.raywenderlich.com/21842/how-to-make-a-gesture-driven-to-do-list-app-part-13) 

联系方式
==============
如有任何疑问，欢迎通过以下方式联系我：
* 提issue；
* 邮箱：35285770@qq.com
* QQ：35285770
* 微信：AJ316G
