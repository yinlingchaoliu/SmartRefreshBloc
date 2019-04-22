import 'dart:async';
import 'dart:convert' show json;

import 'package:example/base/base_bloc.dart';
import 'package:example/base/pulltofresh_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as HTTP;
import 'package:pull_to_refresh/pull_to_refresh.dart';

///@author: chentong
///2019-4-9
///视图层
class TestExample2Page extends StatefulWidget {
  ///路由跳转
  static void pushTestExample22Page(BuildContext context) {
    Navigator.push(
        context,
        new CupertinoPageRoute<void>(
            builder: (ctx) => new BlocProvider<TestExample2Bloc>(
                  child: new TestExample2Page(),
                  bloc: new TestExample2Bloc(),
                )));
  }

  ///获得当前页面实例
  static StatefulWidget newInstance() {
    return new BlocProvider<TestExample2Bloc>(
      child: new TestExample2Page(),
      bloc: new TestExample2Bloc(),
    );
  }

  @override
  _TestExample2PageState createState() => new _TestExample2PageState();
}

///
/// 页面实现
///
class _TestExample2PageState extends State<TestExample2Page> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TestExample2Bloc bloc = BlocProvider.of<TestExample2Bloc>(context);

    bloc.getData();
    return new Scaffold(
        body: new SmartRefresher(
            controller: bloc.refreshController,
            enablePullDown: true,
            enablePullUp: true,
            headerBuilder: bloc.headerCreate,
            footerBuilder: bloc.footerCreate,
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
            child: new GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: bloc.data.length,
              itemBuilder: bloc.buildImage,
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
class TestExample2Bloc extends SmartRefreshBloc {
  int indexPage = 2;
  List<String> data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Future getData({String labelId, int page}) async {
    _fetch();
    return data;
  }

  @override
  Future onRefresh({String labelId}) async {
    indexPage = 2;
    data.clear();
    _fetch();
    return data;
  }

  @override
  Future onLoadMore({String labelId, int page}) async {
    _fetch();
    return null;
  }

  ///自定义头部
  @override
  Widget headerCreate(BuildContext context, RefreshStatus mode) {
    final _loadingContainer = Container(
        height: 50.0,
        color: Colors.black12,
        child: Center(
          child: Opacity(
            opacity: 0.9,
            child: SpinKitWave(
              color: Colors.red,
              size: 50.0,
            ),
          ),
        ));
    return _loadingContainer;
  }

  ///自定义脚部
  @override
  Widget footerCreate(BuildContext context, RefreshStatus mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: 'loading...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Loadmore...',
    );
  }

  Widget buildImage(context, index) {
    return new Item(
      url: data[index],
    );
  }

  void _fetch() {
    HTTP
        .get(
            'http://image.baidu.com/channel/listjson?pn=$indexPage&rn=30&tag1=%E6%98%8E%E6%98%9F&tag2=%E5%85%A8%E9%83%A8&ie=utf8')
        .then((HTTP.Response response) {
      Map map = json.decode(response.body);
      return map["data"];
    }).then((array) {
      for (var item in array) {
        data.add(item["image_url"]);
      }
      indexPage++;
    });
  }
}

class Item extends StatefulWidget {
  final String url;

  Item({this.url});

  @override
  _ItemState createState() => new _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return new Container();
    return new RepaintBoundary(
      child: new Image.network(
        widget.url,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
