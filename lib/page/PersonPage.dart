import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsy_github_app_flutter/common/dao/EventDao.dart';
import 'package:gsy_github_app_flutter/common/dao/ReposDao.dart';
import 'package:gsy_github_app_flutter/common/dao/UserDao.dart';
import 'package:gsy_github_app_flutter/common/model/User.dart';
import 'package:gsy_github_app_flutter/common/net/Address.dart';
import 'package:gsy_github_app_flutter/common/style/GSYStyle.dart';
import 'package:gsy_github_app_flutter/common/utils/CommonUtils.dart';
import 'package:gsy_github_app_flutter/common/utils/NavigatorUtils.dart';
import 'package:gsy_github_app_flutter/widget/EventItem.dart';
import 'package:gsy_github_app_flutter/widget/GSYCommonOptionWidget.dart';
import 'package:gsy_github_app_flutter/widget/GSYListState.dart';
import 'package:gsy_github_app_flutter/widget/GSYPullLoadWidget.dart';
import 'package:gsy_github_app_flutter/widget/GSYTitleBar.dart';
import 'package:gsy_github_app_flutter/widget/UserHeader.dart';
import 'package:gsy_github_app_flutter/widget/UserItem.dart';

/**
 * 个人详情
 * Created by guoshuyu
 * Date: 2018-07-18
 */
class PersonPage extends StatefulWidget {
  static final String sName = "person";

  final String userName;

  PersonPage(this.userName, {Key key}) : super(key: key);

  @override
  _PersonState createState() => _PersonState(userName);
}

class _PersonState extends GSYListState<PersonPage> {
  final String userName;

  String beStaredCount = "---";

  bool focusStatus = false;

  String focus = "";

  User userInfo = User.empty();


  String launchUrl = "";

  _PersonState(this.userName);

  @override
  Future<Null> handleRefresh() async {
    if (isLoading) {
      return null;
    }
    isLoading = true;
    page = 1;
    var userResult = await UserDao.getUserInfo(userName);
    if (userResult != null && userResult.result) {
      userInfo = userResult.data;
      setState(() {
        userInfo = userResult.data;
      });
    } else {
      return null;
    }
    var res = await _getDataLogic();
    if (res != null && res.result) {
      pullLoadWidgetControl.dataList.clear();
      setState(() {
        pullLoadWidgetControl.dataList.addAll(res.data);
        launchUrl = Address.hostWeb + userInfo.login;
      });
    }
    resolveDataResult(res);
    isLoading = false;
    _getFocusStatus();
    ReposDao.getUserRepository100StatusDao(_getUserName()).then((res) {
      if (res != null && res.result) {
        setState(() {
          beStaredCount = res.data.toString();
        });
      }
    });
    return null;
  }

  _getFocusStatus() async {
    var focusRes = await UserDao.checkFollowDao(userName);
    setState(() {
      focus = (focusRes != null && focusRes.result) ? GSYStrings.user_focus : GSYStrings.user_un_focus;
      focusStatus = (focusRes != null && focusRes.result);
    });
  }

  _renderEventItem(index) {
    if (index == 0) {
      return new UserHeaderItem(userInfo, beStaredCount);
    }
    if (userInfo.type == "Organization") {
      return new UserItem(pullLoadWidgetControl.dataList[index - 1], onPressed: () {
        NavigatorUtils.goPerson(context, pullLoadWidgetControl.dataList[index - 1].userName);
      });
    } else {
      return new EventItem(pullLoadWidgetControl.dataList[index - 1]);
    }
  }

  _getUserName() {
    if (userInfo == null) {
      return new User.empty();
    }
    return userInfo.login;
  }

  _getDataLogic() async {
    if (userInfo.type == "Organization") {
      return await UserDao.getMemberDao(_getUserName(), page);
    }
    return await EventDao.getEventDao(_getUserName(), page: page);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  requestRefresh() async {}

  @override
  requestLoadMore() async {
    return await _getDataLogic();
  }

  @override
  bool get isRefreshFirst => true;

  @override
  bool get needHeader => true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: GSYTitleBar(
              (userInfo != null && userInfo.login != null) ? userInfo.login : "",
              rightWidget: GSYCommonOptionWidget(launchUrl),
            )
        ),
        floatingActionButton: new FloatingActionButton(
            child: new Text(focus),
            onPressed: () {
              if (focus == '') {
                return;
              }
              if (userInfo.type == "Organization") {
                Fluttertoast.showToast(msg: GSYStrings.user_focus_no_support);
                return;
              }
              CommonUtils.showLoadingDialog(context);
              UserDao.doFollowDao(userName, focusStatus).then((res) {
                Navigator.pop(context);
                _getFocusStatus();
              });
            }),
        body: GSYPullLoadWidget(
          pullLoadWidgetControl,
              (BuildContext context, int index) => _renderEventItem(index),
          handleRefresh,
          onLoadMore,
          refreshKey: refreshIndicatorKey,
        ));
  }
}
