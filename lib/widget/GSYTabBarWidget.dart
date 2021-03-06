import 'package:flutter/material.dart';

///支持顶部和顶部的TabBar控件
///配合AutomaticKeepAliveClientMixin可以keep住
class GSYTabBarWidget extends StatefulWidget {
  ///底部模式type
  static const int BOTTOM_TAB = 1;

  ///顶部模式type
  static const int TOP_TAB = 2;

  final int type;

  final List<Widget> tabItems;

  final List<Widget> tabViews;

  final Color backgroundColor;

  final Color indicatorColor;

  final Widget title;

  final Widget drawer;

  final Widget floatingActionButton;

  final TarWidgetControl tarWidgetControl;

  GSYTabBarWidget(
      {Key key,
      this.type,
      this.tabItems,
      this.tabViews,
      this.backgroundColor,
      this.indicatorColor,
      this.title,
      this.drawer,
      this.floatingActionButton,
      this.tarWidgetControl})
      : super(key: key);

  @override
  _GSYTabBarState createState() =>
      new _GSYTabBarState(type, tabItems, tabViews, backgroundColor, indicatorColor, title, drawer, floatingActionButton, tarWidgetControl);
}

// ignore: mixin_inherits_from_not_object
class _GSYTabBarState extends State<GSYTabBarWidget> with SingleTickerProviderStateMixin {
  final int _type;

  final List<Widget> _tabItems;

  final List<Widget> _tabViews;

  final Color _backgroundColor;

  final Color _indicatorColor;

  final Widget _title;

  final Widget _drawer;

  final Widget _floatingActionButton;

  final TarWidgetControl tarWidgetControl;

  _GSYTabBarState(this._type, this._tabItems, this._tabViews, this._backgroundColor, this._indicatorColor, this._title, this._drawer,
      this._floatingActionButton, this.tarWidgetControl)
      : super();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (this._type == GSYTabBarWidget.BOTTOM_TAB) {
      _tabController = new TabController(
          vsync: this, //动画效果的异步处理，默认格式，背下来即可
          length: _tabItems.length //需要控制的Tab页数量
          );
    }
  }

  ///整个页面dispose时，记得把控制器也dispose掉，释放内存
  @override
  void dispose() {
    if (this._type == GSYTabBarWidget.BOTTOM_TAB) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this._type == GSYTabBarWidget.TOP_TAB) {
      ///顶部tab bar
      return new DefaultTabController(
        length: _tabItems.length,
        child: new Scaffold(
          floatingActionButton: _floatingActionButton,
          persistentFooterButtons: tarWidgetControl == null ? [] : tarWidgetControl.footerButton,
          appBar: new AppBar(
            backgroundColor: _backgroundColor,
            title: _title,
            bottom: new TabBar(
              tabs: _tabItems,
              indicatorColor: _indicatorColor,
            ),
          ),
          body: new TabBarView(
            children: _tabViews,
          ),
        ),
      );
    }

    ///底部tab bar
    return new Scaffold(
        drawer: _drawer,
        appBar: new AppBar(
          backgroundColor: _backgroundColor,
          title: _title,
        ),
        body: new TabBarView(
            //TabBarView呈现内容，因此放到Scaffold的body中
            controller: _tabController, //配置控制器
            children: _tabViews),
        bottomNavigationBar: new Material(
          //为了适配主题风格，包一层Material实现风格套用
          color: _backgroundColor, //底部导航栏主题颜色
          child: new TabBar(
            //TabBar导航标签，底部导航放到Scaffold的bottomNavigationBar中
            controller: _tabController, //配置控制器
            tabs: _tabItems,
            indicatorColor: _indicatorColor, //tab标签的下划线颜色
          ),
        ));
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
