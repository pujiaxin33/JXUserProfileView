# JXUserProfileView
iOS：一分钟集成主流APP个人资料页（如简书、微博等）

## 仓库迁移

**本仓库已经停止更新，所有代码已经迁移至[JXPagingView](https://github.com/pujiaxin33/JXPagingView)**

## Github
[仓库地址](https://github.com/pujiaxin33/JXUserProfileView) 如果你喜欢，记得点颗❤️哟
## 前言
  伴随着APP不断迭代更新，各种功能也是越堆越多。对于用户来说，在个人资料页面需要显示的元素也越来越多。如何井然有序的展示且交互简单，变成了一个难事。当然这一点也难不倒产品经理，他们总会想出各种奇淫怪术来折磨我们（程序员）。下面以简书和微博来解读下主流APP是如何处理的。

## 简书&微博
![简书](https://upload-images.jianshu.io/upload_images/1085173-0da903effc6c05af.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)

![微博](https://upload-images.jianshu.io/upload_images/1085173-cb5c095f4ed0e065.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)

  正如上图所示，简书和微博的布局如出一辙。一个TableHeaderView显示背景图、头像、简介等基础信息。然后有一个SectionHeaderView，承载不同的内容分类指引（动态、文章、更多等），可以悬浮在顶部。然后就是不同分类的数据流的TableView，可以直接滚动。**建议大家打开简书和微博，把玩一下。**

  第一眼看上去，感觉没有什么难度嘛，就是一个主TableView嵌套一个ScrollView，支持左右滚动切换，然后ScrollView放三个TableView。但是仔细思考会有许多难点需要解决，比如主TableView和嵌套TableView的手势冲突，三个子TableView的位置更新等。

  如果要自己解决这些问题，且要调试到目标效果，可能要花上你大半天时间了。而且本身个人资料页面的业务逻辑就特别多，如果还要插入这种页面交互逻辑，说实话，当你看到许多零散的代码交织在一起时，你的头会和足球一样大！！！
![足球头](https://upload-images.jianshu.io/upload_images/1085173-aee6817c3954c1d4.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)

  所以这篇文章不会着重讲解如何解决上面的问题（可以查看源码分析），而是将页面结构封装好，你只需要花一分钟填充你的业务逻辑即可。妈妈再也不用担心我去调试页面交互逻辑了👏

## 核心原理
 让滑动手势给每个ScrollView都可以处理，只是对于mainTableView和listView有不同的逻辑
```
class JXUserProfileMainTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder())
    }
}
```
- 对于mainTableView的滚动事件处理
```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.mainTableViewDidScroll?(scrollView)

        if (self.listItemScrollView != nil && self.listItemScrollView!.contentOffset.y > 0) {
            //mainTableView的header已经滚动不见，开始滚动某一个listView，那么固定mainTableView的contentOffset，让其不动
            self.mainTableView.contentOffset = CGPoint(x: 0, y: self.delegate.tableHeaderViewHeight(in: self))
        }

        if (scrollView.contentOffset.y < self.delegate.tableHeaderViewHeight(in: self)) {
            //mainTableView已经显示了header，listView的contentOffset需要重置
            for index in 0..<self.delegate.numberOfListViews(in: self) {
                let listView = self.delegate.userProfileView(self, listViewInRow: index)
                listView.scrollView.contentOffset = CGPoint.zero
            }
        }
    }
```
- 对于listView的滚动事件处理
```swift
/// 外部传入的listView，当其内部的scrollView滚动时，需要调用该方法
    open func listViewDidScroll(scrollView: UIScrollView) {
        self.listItemScrollView = scrollView

        if (self.mainTableView.contentOffset.y < self.delegate.tableHeaderViewHeight(in: self)) {
            //mainTableView的header还没有消失，让listScrollView一直为0
            scrollView.contentOffset = CGPoint.zero;
            scrollView.showsVerticalScrollIndicator = false;
        } else {
            //mainTableView的header刚好消失，固定mainTableView的位置，显示listScrollView的滚动条
            self.mainTableView.contentOffset = CGPoint(x: 0, y: self.delegate.tableHeaderViewHeight(in: self));
            scrollView.showsVerticalScrollIndicator = true;
        }
    }
```

## 实现效果
![JXUserProfileViewGif.gif](https://upload-images.jianshu.io/upload_images/1085173-981d275f1b8a4bdb.gif?imageMogr2/auto-orient/strip)

## 使用
1.实例化`JXUserProfileView`
```swift
        userProfileView = JXUserProfileView(delegate: self)
        userProfileView.delegate = self
        self.view.addSubview(userProfileView)
```
2.实现`JXUserProfileViewDelegate`
```swift
@objc protocol JXUserProfileViewDelegate {

    ///mainTableView的滚动回调，用于实现头图跟随缩放
    @objc optional func mainTableViewDidScroll(_ scrollView: UIScrollView)

    ///tableHeaderView的高度
    func tableHeaderViewHeight(in userProfileView: JXUserProfileView) -> CGFloat

    ///返回tableHeaderView
    func tableHeaderView(in userProfileView: JXUserProfileView) -> UIView

    ///heightForHeaderOfSection，就是分类视图的高度
    func heightForHeaderOfSection(in userProfileView: JXUserProfileView) -> CGFloat

    ///viewForHeaderOfSection，分类视图，我用的是自己封装的JXCategoryView，你也可以选择其他的或者自己写
    func viewForHeaderOfSection(in userProfileView: JXUserProfileView) -> UIView

    ///底部listView的条数
    func numberOfListViews(in userProfileView: JXUserProfileView) -> Int

    ///返回对应index的listView，需要是UIView的子类，且要遵循JXUserProfileListViewDelegate。这里要求返回一个UIView而不是一个UIScrollView，因为listView可能并不只是一个单纯的TableView，还会有其他的元素
    func userProfileView(_ userProfileView: JXUserProfileView, listViewInRow row: Int) -> JXUserProfileListViewDelegate & UIView
}
```

3.让外部listView遵从`JXUserProfileListViewDelegate`协议
```swift
//该协议主要用于mainTableView已经显示了header，listView的contentOffset需要重置时，内部需要访问到外部传入进来的listView内的scrollView
@objc protocol JXUserProfileListViewDelegate {
    var scrollView: UIScrollView { get }
}
```

4.将外部listView的滚动事件传入userProfileView
```
func listViewDidScroll(_ scrollView: UIScrollView) {
        userProfileView.listViewDidScroll(scrollView: scrollView)
    }
```

  不用一分钟，就可以集成完毕👏

## Github
[仓库地址](https://github.com/pujiaxin33/JXUserProfileView) 如果你喜欢，记得点颗❤️哟

## 推荐阅读
[SGPagingView](https://github.com/kingsic/SGPagingView)



