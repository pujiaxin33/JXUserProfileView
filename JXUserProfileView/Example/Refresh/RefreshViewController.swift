//
//  RefreshViewController.swift
//  JXUserProfileView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit


fileprivate let JXTableHeaderViewHeight: CGFloat = 200
fileprivate let JXHeightForHeaderOfSection: CGFloat = 50

class RefreshViewController: UIViewController {
    var userProfileView: JXUserProfileView!
    var userHeaderView: UserProfileTableHeaderView!
    var categoryView: JXCategoryView!
    var listViewArray: [TestListBaseView]!
    var titles = ["能力", "爱好", "队友"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "个人中心"
        self.navigationController?.navigationBar.isTranslucent = false

        let powerListView = PowerListView()
        powerListView.delegate = self

        let hobbyListView = HobbyListView()
        hobbyListView.delegate = self

        let partnerListView = PartnerListView()
        partnerListView.delegate = self

        listViewArray = [powerListView, hobbyListView, partnerListView]

        userHeaderView = UserProfileTableHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: JXTableHeaderViewHeight))

        categoryView = JXCategoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: JXHeightForHeaderOfSection))
        categoryView.titles = titles
        categoryView.indicatorLineWidth = 30
        categoryView.backgroundColor = UIColor.white
        categoryView.titleSelectedColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        categoryView.indicatorLineColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        categoryView.titleColor = UIColor.black

        let lineWidth = 1/UIScreen.main.scale
        let lineLayer = CALayer()
        lineLayer.backgroundColor = UIColor.lightGray.cgColor
        lineLayer.frame = CGRect(x: 0, y: categoryView.bounds.height - lineWidth, width: categoryView.bounds.width, height: lineWidth)
        categoryView.layer.addSublayer(lineLayer)

        userProfileView = JXUserProfileView(delegate: self)
        userProfileView.delegate = self
        self.view.addSubview(userProfileView)

        userProfileView.mainTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh));

        categoryView.contentScrollView = userProfileView.listContainerView.collectionView
    }

    @objc func headerRefresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(2)) {
            self.userProfileView.mainTableView.mj_header.endRefreshing()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        userProfileView.frame = self.view.bounds
    }

}

extension RefreshViewController: JXUserProfileViewDelegate {

    func tableHeaderViewHeight(in userProfileView: JXUserProfileView) -> CGFloat {
        return JXTableHeaderViewHeight
    }

    func tableHeaderView(in userProfileView: JXUserProfileView) -> UIView {
        return userHeaderView
    }

    func heightForHeaderOfSection(in userProfileView: JXUserProfileView) -> CGFloat {
        return JXHeightForHeaderOfSection
    }

    func viewForHeaderOfSection(in userProfileView: JXUserProfileView) -> UIView {
        return categoryView
    }

    func numberOfListViews(in userProfileView: JXUserProfileView) -> Int {
        return titles.count
    }

    func userProfileView(_ userProfileView: JXUserProfileView, listViewInRow row: Int) -> UIView & JXUserProfileListViewDelegate {
        return listViewArray[row]
    }
}

extension RefreshViewController: TestListViewDelegate {
    func listViewDidScroll(_ scrollView: UIScrollView) {
        userProfileView.listViewDidScroll(scrollView: scrollView)
    }
}

