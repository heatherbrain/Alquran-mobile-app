import 'dart:async'; // Tambahkan import ini untuk Timer
import 'package:alquran_app/prayers_time_service.dart';
import 'package:alquran_app/screens/pengaturan_screen.dart';
import 'package:alquran_app/screens/search_screen.dart';
import 'package:alquran_app/screens/surah_screen.dart';
import 'package:alquran_app/screens/terakhir_baca_screen.dart';
import 'package:flutter/material.dart';
import 'package:alquran_app/model/dashboardbutton.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, String>?> prayerTimes;
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    prayerTimes = PrayerTimesService().getPrayerTimes();

    _currentTime = _getCurrentTime();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    return DateTime.now().toLocal().toString().substring(11, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: const Color(0xFF85BCCE),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          _buildCurrentTimeWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  DashboardButton(
                    image: 'assets/svg/alqur\'an.svg',
                    label: 'Baca Qur\'an',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return SurahScreen();
                          },
                        ),
                      );
                    },
                  ),
                  DashboardButton(
                    image: 'assets/svg/bookmark.svg',
                    label: 'Terakhir Baca',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return TerakhirBacaScreen();
                          },
                        ),
                      );
                    },
                  ),
                  DashboardButton(
                    image: 'assets/svg/search.svg',
                    label: 'Pencarian',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return SearchScreen();
                          },
                        ),
                      );
                    },
                  ),
                  DashboardButton(
                    image: 'assets/svg/setting.svg',
                    label: 'Pengaturan',
                    onTap: () {
                      Navigator.push(context, PageRouteBuilder(pageBuilder:
                          (context, animation, secondaryAnimation) {
                        return PengaturanScreen();
                      }));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentTime, 
          style: const TextStyle(
            fontSize: 70,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 90,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
