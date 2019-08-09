import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AbilityWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AbilityWidget();
  }
}

class _AbilityWidget extends State<AbilityWidget>
    with SingleTickerProviderStateMixin {
  var _angle = 0.0;
  AnimationController controller;
  Animation<double> animation;

  var data = {
    "攻击力": 70.0,
    "生命": 90.0,
    "闪避": 50.0,
    "暴击": 70.0,
    "破格": 80.0,
    "格挡": 100.0,
  };

  double mRadius = 100;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    var tween = Tween(begin: 0.0, end: 360.0);
    animation = tween.animate(controller); //生成动画
    animation.addListener(() {
      setState(() {
        _angle = animation.value;
      });
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var paint = CustomPaint(
      painter: AbilityPainter(mRadius, data),
    );
    var outlinePainter = Transform.rotate(
      angle: _angle / 180 * pi,
      child: CustomPaint(
        painter: OutlinePainter(mRadius),
      ),
    );
    var img = Transform.rotate(
      angle: _angle / 180 * pi,
      child: Opacity(
        opacity: animation.value / 360 * 0.4,
        child: ClipOval(
          child: Image.asset(
            "assets/images/naizi01.jpg",
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    var center = Transform.rotate(angle: -_angle / 180 * pi,
      child: Transform.scale(scale: 0.5 + animation.value / 360 / 2,
        child: SizedBox(
          width: 200,
          height: 200,
          child: paint,
        ),),);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[img, center, outlinePainter],
      ),
    );
  }
}

class AbilityPainter extends CustomPainter {
  Map<String, double> _data;
  double _r; //外圆半径
  Paint mLinePaint; //线画笔
  Paint mAbilityPaint; //区域画笔
  Paint mFillPaint; //填充画笔

  Path mLinePath; //短直线路劲
  Path mAbilityPath; //范围路劲

  AbilityPainter(this._r, this._data) {
    mLinePath = Path();
    mAbilityPath = Path();
    mLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.008 * _r
      ..isAntiAlias = true;

    mFillPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.05 * _r
      ..isAntiAlias = true;

    mAbilityPaint = Paint()
      ..color = Color(0x8897C5FE)
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //剪切画布
    Rect rect = Offset.zero & size;
    canvas.clipRect(rect);

    canvas.translate(_r, _r); //移动坐标
    drawInnerCircle(canvas);
    drawInfoText(canvas);
    drawAbility(canvas, _data.values.toList());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  //绘制外圈
  void drawOutCircle(Canvas canvas) {
    canvas.save(); //新建图层
    canvas.drawCircle(Offset(0, 0), _r, mLinePaint); //圆形的绘制
    double r2 = _r - 0.08 * _r; //下圆半径
    canvas.drawCircle(Offset(0, 0), r2, mLinePaint);
    for (var i = 0; i < 22; i++) {
      //循环画出小黑条
      canvas.save();
      canvas.rotate(360 / 22 * i / 180 * pi); //旋转：注意传入的事弧度
      canvas.drawLine(Offset(0, -_r), Offset(0, -r2), mFillPaint);
      canvas.restore(); //释放图层

    }
    canvas.restore();
  }

  void drawInnerCircle(Canvas canvas) {
    double innerRadius = 0.618 * _r; //内圆半径
    canvas.drawCircle(Offset(0, 0), innerRadius, mLinePaint);
    canvas.save();
    for (var i = 0; i < 6; i++) {
      //遍历6条线
      canvas.save();
      canvas.rotate(60 * i.toDouble() / 180 * pi); //每次旋转60
      mLinePath.moveTo(0, -innerRadius);
      mLinePath.relativeLineTo(0, innerRadius);
      for (int j = 1; j < 6; j++) {
        //在内圆线上加5条横线
        mLinePath.moveTo(-_r * 0.02, innerRadius / 6 * j);
        mLinePath.relativeLineTo(_r * 0.02 * 2, 0);
      }
      canvas.drawPath(mLinePath, mLinePaint); //绘制线
      canvas.restore();
    }
    canvas.restore();
  }

  /**
   * 绘制文字
   */
  void drawInfoText(Canvas canvas) {
    double r2 = _r - 0.08 * _r; //下圆半径
    for (int i = 0; i < _data.length; i++) {
      canvas.save();
      canvas.rotate(360 / _data.length * i / 180 * pi + pi);
      drawText(canvas, _data.keys.toList()[i], Offset(-50, r2 - 0.22 * _r),
          fontSize: _r * 0.1);
      canvas.restore();
    }
  }

  //绘制文字
  void drawText(Canvas canvas, String text, Offset offset,
      {Color color = Colors.black,
        double maxWith = 100,
        double fontSize,
        String fontFamily,
        TextAlign textAlign = TextAlign.center,
        FontWeight fontWeight = FontWeight.bold}) {
    //绘制文字
    var paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: fontFamily,
        textAlign: textAlign,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    paragraphBuilder.pushStyle(
        ui.TextStyle(color: color, textBaseline: TextBaseline.alphabetic));
    paragraphBuilder.addText(text);
    var paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWith));
    canvas.drawParagraph(paragraph, Offset(offset.dx, offset.dy));
  }

  //绘制区域
  void drawAbility(Canvas canvas, List<double> value) {
    double step = _r * 0.618 / 6; //每小段的长度
    mAbilityPath.moveTo(0, -value[0] / 20 * step); //起点
    for (int i = 1; i < 6; i++) {
      double mark = value[i] / 20; //占几段
      mAbilityPath.lineTo(mark * step * cos(pi / 180 * (-30 + 60 * (i - 1))),
          mark * step * sin(pi / 180 * (-30 + 60 * (i - 1))));
    }
    mAbilityPath.close();
    canvas.drawPath(mAbilityPath, mAbilityPaint);
  }
}

class OutlinePainter extends CustomPainter {
  double _radius = 100; //外圆半径
  Paint mLinePaint; //线画笔
  Paint mFillPaint;

  OutlinePainter(this._radius) {
    mLinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.008 * _radius
      ..isAntiAlias = true;

    mFillPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.05 * _radius
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawOutCircle(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  //绘制外圈
  void drawOutCircle(Canvas canvas) {
    canvas.save(); //新建图层
    canvas.drawCircle(Offset(0, 0), _radius, mLinePaint); //圆形的绘制
    double r2 = _radius - 0.08 * _radius; //下圆半径
    canvas.drawCircle(Offset(0, 0), r2, mLinePaint);
    for (var i = 0; i < 22; i++) {
      //循环画出小黑条
      canvas.save();
      canvas.rotate(360 / 22 * i / 180 * pi); //旋转：注意传入的事弧度
      canvas.drawLine(Offset(0, -_radius), Offset(0, -r2), mFillPaint);
      canvas.restore(); //释放图层

    }
    canvas.restore();
  }
}
