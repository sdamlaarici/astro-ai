import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AstroApp());
}

class AstroApp extends StatelessWidget {
  const AstroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Astro AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  DateTime? secilenTarih;
  TimeOfDay? secilenSaat;
  
  // Artık enlem/boylam yerine sadece şehir ismi alıyoruz
  final TextEditingController sehirController = TextEditingController(text: "Ankara");

  String gunesBurcu = "";
  String yukselenBurcu = "";
  String gunlukYorum = "Yıldızların mesajı bekleniyor...";
  bool yukleniyor = false;

  Future<void> tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 3, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (secilen != null) {
      setState(() {
        secilenTarih = secilen;
      });
    }
  }

  Future<void> saatSec(BuildContext context) async {
    final TimeOfDay? secilen = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
    );
    if (secilen != null) {
      setState(() {
        secilenSaat = secilen;
      });
    }
  }

  Future<void> yorumuGetir() async {
    if (secilenTarih == null || secilenSaat == null || sehirController.text.isEmpty) {
      setState(() {
        gunlukYorum = "Lütfen doğum tarihinizi, saatinizi ve şehrinizi eksiksiz girin!";
      });
      return;
    }

    setState(() {
      yukleniyor = true;
      gunlukYorum = "Gökyüzü haritanız hesaplanıyor ve yapay zeka tarafından yorumlanıyor...\nLütfen bekleyin.";
    });

    try {
      double saatFloat = secilenSaat!.hour + (secilenSaat!.minute / 60.0);
      
      // Artık Python'a doğrudan kullanıcının yazdığı şehri gönderiyoruz
      final url = Uri.parse(
          'http://127.0.0.1:8000/gunluk-yorum?yil=${secilenTarih!.year}&ay=${secilenTarih!.month}&gun=${secilenTarih!.day}&saat=$saatFloat&sehir=${sehirController.text}&utc_farki=3');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          gunesBurcu = data['gunes_burcu'];
          yukselenBurcu = data['yukselen_burcu'];
          gunlukYorum = data['gunluk_yorum'];
        });
      } else {
        setState(() {
          gunlukYorum = "Sunucu hatası: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        gunlukYorum = "Bağlantı hatası! Lütfen arka planda Python sunucusunun çalıştığından emin ol.";
      });
    } finally {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ Astro AI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => tarihSec(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(secilenTarih == null 
                        ? "Tarih Seç" 
                        : "${secilenTarih!.day}/${secilenTarih!.month}/${secilenTarih!.year}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => saatSec(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(secilenSaat == null 
                        ? "Saat Seç" 
                        : "${secilenSaat!.hour}:${secilenSaat!.minute.toString().padLeft(2, '0')}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // YENİ ŞEHİR GİRİŞ KUTUSU
            TextField(
              controller: sehirController,
              decoration: const InputDecoration(
                labelText: 'Doğduğunuz Şehir (Örn: Ankara, İstanbul)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: yukleniyor ? null : yorumuGetir,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: yukleniyor
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kendi Yorumunu Al', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),

            if (gunesBurcu.isNotEmpty)
              Text(
                '🌞 Güneş: $gunesBurcu   |   ⬆️ Yükselen: $yukselenBurcu',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.5)),
              ),
              child: Text(
                gunlukYorum,
                style: const TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}