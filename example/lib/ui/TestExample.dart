import 'package:example/base/base_bloc.dart';
import 'package:example/base/pulltofresh_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///@author: chentong
///2019-4-9
///视图层
class TestExamplePage extends StatefulWidget {
  ///路由跳转
  static void pushTestExamplePage(BuildContext context) {
    Navigator.push(
        context,
        new CupertinoPageRoute<void>(
            builder: (ctx) => new BlocProvider<TestExampleBloc>(
                  child: new TestExamplePage(),
                  bloc: new TestExampleBloc(),
                )));
  }

  ///获得当前页面实例
  static StatefulWidget newInstance() {
    return new BlocProvider<TestExampleBloc>(
      child: new TestExamplePage(),
      bloc: new TestExampleBloc(),
    );
  }

  @override
  _TestExamplePageState createState() => new _TestExamplePageState();
}

///
/// 页面实现
///
class _TestExamplePageState extends State<TestExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TestExampleBloc bloc = BlocProvider.of<TestExampleBloc>(context);

    return new Scaffold(
        body: new SmartRefresher(
            controller: bloc.refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: (up) {
              if (up) {
                ///延时2秒
                new Future.delayed(const Duration(milliseconds: 1000))
                    .then((val) {
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
                new Future.delayed(const Duration(milliseconds: 1000))
                    .then((val) {
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
              reverse: true,
              controller: bloc.scrollController,
              itemExtent: 100.0,
              itemCount: bloc.data.length,
              itemBuilder: (context, index) {
                return bloc.buildImage(context, index);
              },
            )));
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
class TestExampleBloc extends SmartRefreshBloc {
  List<Widget> data = [];

  Widget buildImage(context, index) {
    return data[index];
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Future getData({String labelId, int page}) async {
    for (int i = 0; i < 4; i++) {
      data.add(getItemWidget('Data $i'));
    }
    return data;
  }

  @override
  Future onRefresh({String labelId}) async {
    data.clear();
    data.add(getItemWidget('Data up'));
    return data;
  }

  @override
  Future onLoadMore({String labelId, int page}) async {
    data.add(getItemWidget('Data down'));
    return data;
  }

  Widget getItemWidget(String text) {
    return new Card(
      margin:
          new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: new Center(
        child: new Text(text),
      ),
    );
  }
}
