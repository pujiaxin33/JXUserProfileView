//
//  JXUserProfileView.swift
//  JXUserProfileView
//
//  Created by jiaxin on 2018/5/22.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

//该协议主要用于mainTableView已经显示了header，listView的contentOffset需要重置时，内部需要访问到外部传入进来的listView内的scrollView
@objc protocol JXUserProfileListViewDelegate {
    var scrollView: UIScrollView { get }
}

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

class JXUserProfileView: UIView {
    open var listContainerView: JXUserProfileListContainerView!
    unowned var delegate: JXUserProfileViewDelegate
    var mainTableView: JXUserProfileMainTableView!
    fileprivate var currentScrollingListView: UIScrollView?

    init(delegate: JXUserProfileViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        initializeViews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func initializeViews(){

        mainTableView = JXUserProfileMainTableView(frame: CGRect.zero, style: .plain)
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.showsHorizontalScrollIndicator = false
        mainTableView.separatorStyle = .none
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.tableHeaderView = self.delegate.tableHeaderView(in: self)
        mainTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        addSubview(mainTableView)

        listContainerView = JXUserProfileListContainerView(delegate: self)
        listContainerView.mainTableView = mainTableView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        mainTableView.frame = self.bounds
    }


    /// 外部传入的listView，当其内部的scrollView滚动时，需要调用该方法
    open func listViewDidScroll(scrollView: UIScrollView) {
        self.currentScrollingListView = scrollView

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

    open func reloadData() {
        self.mainTableView.reloadData()
        self.listContainerView.reloadData()
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension JXUserProfileView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bounds.height - self.delegate.heightForHeaderOfSection(in: self)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        listContainerView.frame = cell.contentView.bounds
        cell.contentView.addSubview(listContainerView)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.delegate.heightForHeaderOfSection(in: self)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.delegate.viewForHeaderOfSection(in: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate.mainTableViewDidScroll?(scrollView)

        if (self.currentScrollingListView != nil && self.currentScrollingListView!.contentOffset.y > 0) {
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
}

extension JXUserProfileView: JXUserProfileListContainerViewDelegate {
    func numberOfRows(in listContainerView: JXUserProfileListContainerView) -> Int {
        return self.delegate.numberOfListViews(in: self)
    }
    func listContainerView(_ listContainerView: JXUserProfileListContainerView, viewForListInRow row: Int) -> UIView {
        return self.delegate.userProfileView(self, listViewInRow: row)
    }
}



