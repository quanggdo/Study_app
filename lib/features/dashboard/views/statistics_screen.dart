import 'package:flutter/material.dart';
import 'progress_charts_widget.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê & Báo cáo')),
      body: ProgressChartsWidget(),
    );
  }
}
