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

  @override
  void initState() {
    super.initState();
    print('Initializing PrayerTimesService...');
    prayerTimes = PrayerTimesService().getPrayerTimes();
    prayerTimes.then((data) {
      print('Received Prayer Times: $data');
    }).catchError((e) {
      print('Error while fetching prayer times: $e');
    });
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
                    image: 'assets/images/alqur\'an.png',
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
                    image: 'assets/images/bookmark.png',
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
                    image: 'assets/images/search.png',
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
                    image: 'assets/images/setting.png',
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
    String currentTime = DateTime.now().toLocal().toString().substring(11, 16);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$currentTime',
          style: TextStyle(fontSize: 70, color: Colors.white),
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
