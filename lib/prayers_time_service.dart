import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  final String apiUrl =
      "http://api.aladhan.com/v1/timingsByCity?city=Jakarta&country=Indonesia&method=2"; 

  Future<Map<String, String>> getPrayerTimes() async {
    try {
      print('Making API request to $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));
      print('API Response: ${response.body}'); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');
        
        Map<String, String> prayerTimes = {
          'Fajr': data['data']['timings']['Fajr'],
          'Dhuhr': data['data']['timings']['Dhuhr'],
          'Asr': data['data']['timings']['Asr'],
          'Maghrib': data['data']['timings']['Maghrib'],
          'Isha': data['data']['timings']['Isha'],
        };
        
        print('Prayer Times: $prayerTimes'); 
        return prayerTimes;
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      print('Error: $e'); 
      throw Exception('Error fetching prayer times');
    }
  }
}
