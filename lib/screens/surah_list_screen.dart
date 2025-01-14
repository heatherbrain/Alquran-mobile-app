import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  final int surahId;
   final int lastReadAyat;

  SurahListScreen({
    required this.surahId,
    required this.lastReadAyat,
  });

  @override
  _SurahListScreenState createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> surahData = [];
  List<Map<String, dynamic>> allSurahData = [];

  @override
  void initState() {
    super.initState();
    fetchSurahData(widget.surahId);
    fetchAllSurahData();
  }

  Future<void> fetchAllSurahData() async {
    try {
      final response = await http.get(
        Uri.parse('https://quran-api.santrikoding.com/api/surah'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allSurahData = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load surah list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching surah list: $error');
    }
  }

  Future<void> fetchSurahData(int surahId) async {
    try {
      final response = await http.get(
        Uri.parse('https://quran-api.santrikoding.com/api/surah/$surahId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['nomor'] != null) {
          final surahDetails = {
            'nomor': data['nomor'],
            'nama': data['nama'],
            'nama_latin': data['nama_latin'],
            'jumlah_ayat': data['jumlah_ayat'],
            'tempat_turun': data['tempat_turun'],
            'arti': data['arti'],
            'deskripsi': data['deskripsi'],
            'audio': data['audio'],
          };

          setState(() {
            surahData = [surahDetails];
            isLoading = false;
          });
        } else {
          throw Exception('No surah data available for the given ID');
        }
      } else {
        throw Exception(
            'Failed to load surah data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching surah data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayat Surah Al-Qur\'an'),
        backgroundColor: Color(0xFFE6F1F3),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF819BA0)),
              ),
            )
          : DefaultTabController(
              length: allSurahData.length,
              initialIndex: widget.surahId - 1,
              child: Column(
                children: [
                  Container(
                    color: Color(0xFFE6F1F3),
                    child: TabBar(
                      isScrollable: true,
                      indicatorColor: Color(0xFF819BA0),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: allSurahData.map((surah) {
                        return Tab(
                          text: surah['nama_latin'],
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: allSurahData.map((surah) {
                        return SurahDetailScreen(
                          surahName: surah['nama_latin'],
                          surahNumber: surah['nomor'],
                          ayatNumber: surah['jumlah_ayat'],
                          lastReadAyat: surah['nomor'] == widget.surahId ? widget.lastReadAyat : null,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
