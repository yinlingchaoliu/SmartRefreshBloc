import 'dart:async';

import 'package:example/base/base_bloc.dart';
import 'package:example/base/pulltofresh_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///@author: chentong
///2019-4-9
///视图层
class TestExample3Page extends StatefulWidget {
  ///路由跳转
  static void pushTestExample32Page(BuildContext context) {
    Navigator.push(
        context,
        new CupertinoPageRoute<void>(
            builder: (ctx) => new BlocProvider<TestExample3Bloc>(
                  child: new TestExample3Page(),
                  bloc: new TestExample3Bloc(),
                )));
  }

  ///获得当前页面实例
  static StatefulWidget newInstance() {
    return new BlocProvider<TestExample3Bloc>(
      child: new TestExample3Page(),
      bloc: new TestExample3Bloc(),
    );
  }

  @override
  _TestExample3PageState createState() => new _TestExample3PageState();
}

///
/// 页面实现
///
class _TestExample3PageState extends State<TestExample3Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TestExample3Bloc bloc = BlocProvider.of<TestExample3Bloc>(context);

    return new Scaffold(
        body: new SmartRefresher(
      controller: bloc.refreshController,
      enablePullDown: true,
      enablePullUp: true,
      headerBuilder: bloc.headerCreate,
      footerBuilder: bloc.footerCreate,
      footerConfig: new RefreshConfig(),
      onRefresh: (up) {
        if (up) {
          ///延时2秒
          new Future.delayed(const Duration(milliseconds: 1000)).then((val) {
            bloc.onRefresh().whenComplete(() {
              setState(() {
                bloc.refreshCompleted();
              });
            }).catchError(() {
              setState(() {
                bloc.refreshFailed();
              });
            });
          });
        } else {
          ///延时2秒
          new Future.delayed(const Duration(milliseconds: 1000)).then((val) {
            bloc.onLoadMore().whenComplete(() {
              setState(() {
                bloc.refreshIdle();
              });
            }).catchError(() {
              setState(() {
                bloc.refreshFailed();
              });
            });
          });
        }
      },
      onOffsetChange: bloc.onOffsetCallback,
      child: new ListView.builder(
        itemExtent: 100.0,
        itemCount: bloc.data.length,
        itemBuilder: (context, index) {
          return bloc.data[index];
        },
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}

///
///逻辑层
///todo:此处逻辑建议迁移出去 分离开解耦
///
class TestExample3Bloc extends SmartRefreshBloc {
  List<Widget> data = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Future getData({String labelId, int page}) async {
    for (int i = 0; i < 14; i++) {
      data.add(getItemWidget('Data $i'));
    }
    return data;
  }

  @override
  Future onRefresh({String labelId}) async {
    data.clear();
    getData();
    return data;
  }

  @override
  Future onLoadMore({String labelId, int page}) async {
    data.add(getItemWidget('Data+我要加1条数据'));
    return null;
  }

  Widget getItemWidget(String text) {
    return new Container(
      color: new Color.fromARGB(255, 250, 250, 250),
      child: new Card(
        margin:
            new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: new Center(
          child: new Text(text),
        ),
      ),
    );
  }
}
