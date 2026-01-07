import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VeriYoneticisi.yukle();
  runApp(const FitProUltimate());
}

class FitProUltimate extends StatelessWidget {
  const FitProUltimate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.deepOrange,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
        ),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      home: globalProfiller.isEmpty
          ? const KayitEkrani()
          : const ProfilSecimEkrani(),
    );
  }
}

// --- VERİ YÖNETİCİSİ ---
class VeriYoneticisi {
  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = globalProfiller
        .map((k) => jsonEncode(k.toMap()))
        .toList();
    await prefs.setStringList('profiller', jsonList);
  }

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('profiller');
    if (jsonList != null) {
      globalProfiller = jsonList
          .map((j) => Kullanici.fromMap(jsonDecode(j)))
          .toList();
    }
  }
}

// --- MODELLER ---
List<Kullanici> globalProfiller = [];

class Kullanici {
  String ad;
  double boy, kilo, yas, hedefKilo, tdee, hedefKalori;
  String cinsiyet;
  String aktiviteSeviyesi;
  int renkKod; // YENİ: Renk Kodu
  Map<String, GunlukVeri> gecmis = {};

  Kullanici({
    required this.ad,
    required this.boy,
    required this.kilo,
    required this.yas,
    required this.cinsiyet,
    required this.hedefKilo,
    required this.tdee,
    required this.hedefKalori,
    required this.aktiviteSeviyesi,
    required this.renkKod, // YENİ
  });

  Map<String, dynamic> toMap() => {
    'ad': ad, 'boy': boy, 'kilo': kilo, 'yas': yas, 'hedefKilo': hedefKilo,
    'tdee': tdee, 'hedefKalori': hedefKalori, 'cinsiyet': cinsiyet,
    'aktiviteSeviyesi': aktiviteSeviyesi,
    'renkKod': renkKod, // YENİ
    'gecmis': gecmis.map((k, v) => MapEntry(k, v.toMap())),
  };

  factory Kullanici.fromMap(Map<String, dynamic> map) {
    var k = Kullanici(
      ad: map['ad'],
      boy: map['boy'],
      kilo: map['kilo'],
      yas: map['yas'],
      hedefKilo: map['hedefKilo'],
      tdee: map['tdee'],
      hedefKalori: map['hedefKalori'],
      cinsiyet: map['cinsiyet'],
      aktiviteSeviyesi: map['aktiviteSeviyesi'] ?? "Orta",
      renkKod: map['renkKod'] ?? 0xFFFF5722, // Varsayılan DeepOrange
    );
    if (map['gecmis'] != null) {
      Map<String, dynamic> g = map['gecmis'];
      k.gecmis = g.map((key, val) => MapEntry(key, GunlukVeri.fromMap(val)));
    }
    return k;
  }
}

class GunlukVeri {
  double alinanKalori = 0;
  double alinanProtein = 0;
  double alinanKarb = 0;
  double yakilanSpor = 0;
  double yakilanAdim = 0;
  double suLitre = 0;
  double uykuSaat = 0;
  String uykuAraligi = "Girmedi";
  int adimSayisi = 0;

  GunlukVeri();

  Map<String, dynamic> toMap() => {
    'alinanKalori': alinanKalori,
    'alinanProtein': alinanProtein,
    'alinanKarb': alinanKarb,
    'yakilanSpor': yakilanSpor,
    'suLitre': suLitre,
    'yakilanAdim': yakilanAdim,
    'uykuSaat': uykuSaat,
    'uykuAraligi': uykuAraligi,
    'adimSayisi': adimSayisi,
  };

  factory GunlukVeri.fromMap(Map<String, dynamic> map) {
    var g = GunlukVeri();
    g.alinanKalori = (map['alinanKalori'] ?? 0).toDouble();
    g.alinanProtein = (map['alinanProtein'] ?? 0).toDouble();
    g.alinanKarb = (map['alinanKarb'] ?? 0).toDouble();
    g.yakilanSpor = (map['yakilanSpor'] ?? 0).toDouble();
    g.suLitre = (map['suLitre'] ?? 0).toDouble();
    g.yakilanAdim = (map['yakilanAdim'] ?? 0).toDouble();
    g.uykuSaat = (map['uykuSaat'] ?? 0).toDouble();
    g.uykuAraligi = map['uykuAraligi'] ?? "Girmedi";
    g.adimSayisi = map['adimSayisi'] ?? 0;
    return g;
  }
}

// --- 1. EKRAN: PROFİL SEÇİMİ ---
class ProfilSecimEkrani extends StatefulWidget {
  const ProfilSecimEkrani({super.key});
  @override
  State<ProfilSecimEkrani> createState() => _ProfilSecimEkraniState();
}

class _ProfilSecimEkraniState extends State<ProfilSecimEkrani> {
  void _profilSil(Kullanici k) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Profili Sil"),
        content: Text("${k.ad} adlı profili silmek istediğine emin misin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                globalProfiller.remove(k);
              });
              VeriYoneticisi.kaydet();
              Navigator.pop(ctx);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "KİM SPOR YAPIYOR?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "(Silmek için profile basılı tut)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                ...globalProfiller.map((p) => _avatar(p, false)),
                _avatar(null, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(Kullanici? k, bool isAdd) {
    return GestureDetector(
      onTap: () {
        if (isAdd) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const KayitEkrani()),
          ).then((v) => setState(() {}));
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => AnaDashboard(k: k!)),
          );
        }
      },
      onLongPress: () {
        if (!isAdd && k != null) _profilSil(k);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: isAdd
                ? Colors.white10
                : Color(k!.renkKod), // Seçilen Renk
            child: Icon(
              isAdd ? Icons.add : Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAdd ? "Yeni Profil" : k!.ad,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// --- 2. EKRAN: KAYIT ---
class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});
  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final ad = TextEditingController();
  final kilo = TextEditingController();
  final boy = TextEditingController();
  final yas = TextEditingController();
  final hedef = TextEditingController();

  String cinsiyet = "Erkek";
  String aktivite = "Orta Hareketli (1.55)";
  Color secilenRenk = Colors.deepOrange; // Varsayılan

  final List<Color> renkSecenekleri = [
    Colors.deepOrange,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  final Map<String, double> aktiviteKatsayilari = {
    "Hareketsiz (1.2)": 1.2,
    "Az Hareketli (1.375)": 1.375,
    "Orta Hareketli (1.55)": 1.55,
    "Çok Hareketli (1.725)": 1.725,
    "Sporcu / Ağır İş (1.9)": 1.9,
  };

  void kaydet() {
    double k = double.tryParse(kilo.text) ?? 0;
    double b = double.tryParse(boy.text) ?? 0;
    double y = double.tryParse(yas.text) ?? 0;
    double h = double.tryParse(hedef.text) ?? 0;

    if (ad.text.isEmpty || k == 0) return;

    double bmr =
        (10 * k) + (6.25 * b) - (5 * y) + (cinsiyet == "Erkek" ? 5 : -161);
    double carpan = aktiviteKatsayilari[aktivite]!;
    double tdee = bmr * carpan;

    double hedefKal;
    if (h < k) {
      hedefKal = tdee - 500;
    } else if (h > k) {
      hedefKal = tdee + 300;
    } else {
      hedefKal = tdee;
    }

    globalProfiller.add(
      Kullanici(
        ad: ad.text,
        boy: b,
        kilo: k,
        yas: y,
        cinsiyet: cinsiyet,
        hedefKilo: h,
        tdee: tdee,
        hedefKalori: hedefKal,
        aktiviteSeviyesi: aktivite,
        renkKod: secilenRenk.value, // Renk kaydı
      ),
    );

    VeriYoneticisi.kaydet();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const ProfilSecimEkrani()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Oluştur")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _input(ad, "Adınız", Icons.person, false),
          _input(kilo, "Kilo (kg)", Icons.monitor_weight, true),
          _input(boy, "Boy (cm)", Icons.height, true),
          _input(yas, "Yaş", Icons.cake, true),
          _input(hedef, "Hedef Kilo", Icons.flag, true),

          const SizedBox(height: 15),
          const Text("Cinsiyet", style: TextStyle(color: Colors.white70)),
          DropdownButton<String>(
            value: cinsiyet,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            items: [
              "Erkek",
              "Kadın",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => cinsiyet = v!),
          ),

          const SizedBox(height: 15),
          const Text(
            "Hareket Seviyesi",
            style: TextStyle(color: Colors.white70),
          ),
          DropdownButton<String>(
            value: aktivite,
            isExpanded: true,
            dropdownColor: Colors.grey[900],
            items: aktiviteKatsayilari.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => aktivite = v!),
          ),

          const SizedBox(height: 15),
          const Text("Tema Rengi Seç", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 15,
            children: renkSecenekleri.map((renk) {
              return GestureDetector(
                onTap: () => setState(() => secilenRenk = renk),
                child: CircleAvatar(
                  backgroundColor: renk,
                  radius: 20,
                  child: secilenRenk == renk
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: kaydet,
            style: ElevatedButton.styleFrom(
              backgroundColor: secilenRenk,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
            ),
            child: const Text("KAYDET VE BAŞLA"),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String l, IconData i, bool n) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          keyboardType: n ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: l,
            prefixIcon: Icon(i, color: secilenRenk),
            border: const OutlineInputBorder(),
          ),
        ),
      );
}

// --- 3. EKRAN: ANA DASHBOARD ---
class AnaDashboard extends StatefulWidget {
  final Kullanici k;
  const AnaDashboard({super.key, required this.k});
  @override
  State<AnaDashboard> createState() => _AnaDashboardState();
}

class _AnaDashboardState extends State<AnaDashboard> {
  int _tabIndex = 0;
  late String bugun;

  @override
  void initState() {
    super.initState();
    var n = DateTime.now();
    bugun = "${n.day}.${n.month}.${n.year}";
    if (!widget.k.gecmis.containsKey(bugun))
      widget.k.gecmis[bugun] = GunlukVeri();
  }

  void _kaydetGuncelle() {
    setState(() {});
    VeriYoneticisi.kaydet();
  }

  @override
  Widget build(BuildContext context) {
    Color temaRenk = Color(widget.k.renkKod); // Profilin Rengi

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.k.ad.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, color: temaRenk),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (c) => const ProfilSecimEkrani()),
            ),
          ),
        ],
      ),
      body: _tabIndex == 0 ? _panelSayfasi(temaRenk) : _gecmisSayfasi(temaRenk),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: temaRenk,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Panel"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Geçmiş"),
        ],
      ),
    );
  }

  // --- PANEL SAYFASI ---
  Widget _panelSayfasi(Color temaRenk) {
    var v = widget.k.gecmis[bugun]!;
    double toplamYakilan = v.yakilanSpor + v.yakilanAdim;
    double kalan = (widget.k.hedefKalori + toplamYakilan) - v.alinanKalori;

    double hedefProtein = widget.k.kilo * 2.0;
    double hedefKarb = widget.k.kilo * 3.5;

    String hedefDurumu = "";
    String hedefAciklamasi = "";
    if (widget.k.hedefKilo < widget.k.kilo) {
      hedefDurumu = "Zayıflama Hedefi";
      hedefAciklamasi =
          "Min. Alman Gereken: ${widget.k.hedefKalori.toInt()} kcal\n(500 kcal açık hesaplanmıştır)";
    } else if (widget.k.hedefKilo > widget.k.kilo) {
      hedefDurumu = "Kilo Alma Hedefi";
      hedefAciklamasi =
          "Min. Alman Gereken: ${widget.k.hedefKalori.toInt()} kcal\n(300 kcal fazlalık hesaplanmıştır)";
    } else {
      hedefDurumu = "Kilo Koruma";
      hedefAciklamasi = "Günlük İhtiyaç: ${widget.k.hedefKalori.toInt()} kcal";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ÖZET KARTI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [temaRenk.withOpacity(0.6), Colors.black],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: temaRenk.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  hedefDurumu,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hedefAciklamasi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const Divider(color: Colors.white24),

                const Text(
                  "KALAN HAKKIN",
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${kalan.toInt()}",
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "(Günlük Yaktığın: ${toplamYakilan.toInt()} kcal dahil)",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),

                _makroBar(
                  "Protein",
                  v.alinanProtein,
                  hedefProtein,
                  Colors.greenAccent,
                ),
                const SizedBox(height: 8),
                _makroBar(
                  "Karbonhidrat",
                  v.alinanKarb,
                  hedefKarb,
                  Colors.cyanAccent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              _card(
                "Yemek Ekle +",
                "${v.alinanKalori.toInt()} kcal",
                temaRenk,
                () => _yemekEkle(v),
              ),
              _card(
                "Spor Yap +",
                "${v.yakilanSpor.toInt()} kcal",
                Colors.redAccent,
                () => _sporDetayliEkle(v),
              ),
              _card(
                "Su İç +",
                "${v.suLitre.toStringAsFixed(1)} L",
                Colors.blue,
                () {
                  v.suLitre += 0.25;
                  _kaydetGuncelle();
                },
              ),
              _card(
                "Adım Gir +",
                "${v.adimSayisi} Adım",
                Colors.green,
                () => _adimEkle(v),
              ),
              _card(
                "Uyku Gir +",
                v.uykuAraligi,
                Colors.indigo,
                () => _uykuEkle(v),
              ),
              _card(
                "Bugünlük Rapor",
                "Detay Gör",
                Colors.purple,
                () => _raporGoster(v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- GEÇMİŞ SAYFASI ---
  Widget _gecmisSayfasi(Color temaRenk) {
    if (widget.k.gecmis.isEmpty) {
      return const Center(child: Text("Henüz geçmiş veri yok."));
    }
    var tarihler = widget.k.gecmis.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: tarihler.length,
      itemBuilder: (context, index) {
        String tarih = tarihler[index];
        var veri = widget.k.gecmis[tarih]!;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              tarih,
              style: TextStyle(fontWeight: FontWeight.bold, color: temaRenk),
            ),
            subtitle: Text(
              "Alınan: ${veri.alinanKalori.toInt()} kcal | Yakılan: ${(veri.yakilanSpor + veri.yakilanAdim).toInt()} kcal",
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _raporGoster(veri),
          ),
        );
      },
    );
  }

  Widget _makroBar(String baslik, double alinan, double hedef, Color renk) {
    double oran = (alinan / hedef).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$baslik: ${alinan.toInt()} / ${hedef.toInt()}g",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              "%${(oran * 100).toInt()}",
              style: TextStyle(fontSize: 12, color: renk),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: oran,
          color: renk,
          backgroundColor: Colors.white10,
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _card(String t, String v, Color c, VoidCallback tap) =>
      GestureDetector(
        onTap: tap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: c.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t,
                style: TextStyle(color: c, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                v,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  // --- MODALLAR ---

  void _yemekEkle(GunlukVeri v) {
    var cKal = TextEditingController();
    var cPro = TextEditingController();
    var cKarb = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Öğün Girişi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniInput(cKal, "Kalori (kcal)"),
            _miniInput(cPro, "Protein (g)"),
            _miniInput(cKarb, "Karb (g)"),
            TextButton(
              onPressed: () {
                v.alinanKalori = 0;
                v.alinanProtein = 0;
                v.alinanKarb = 0;
                _kaydetGuncelle();
                Navigator.pop(ctx);
              },
              child: const Text("SIFIRLA", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              v.alinanKalori += double.tryParse(cKal.text) ?? 0;
              v.alinanProtein += double.tryParse(cPro.text) ?? 0;
              v.alinanKarb += double.tryParse(cKarb.text) ?? 0;
              _kaydetGuncelle();
              Navigator.pop(ctx);
            },
            child: const Text("EKLE"),
          ),
        ],
      ),
    );
  }

  void _sporDetayliEkle(GunlukVeri v) {
    bool vg = false, kosu = false;
    var sureVG = TextEditingController();
    var sureKosu = TextEditingController();
    var hizKosu = TextEditingController();
    var egimKosu = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Antrenman Ekle",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              CheckboxListTile(
                title: const Text("Ağırlık Antrenmanı"),
                value: vg,
                onChanged: (val) => setModalState(() => vg = val!),
                activeColor: Colors.deepOrange,
              ),
              if (vg) _miniInput(sureVG, "Süre (dk)"),

              CheckboxListTile(
                title: const Text("Yürüyüş Bandı / Koşu"),
                value: kosu,
                onChanged: (val) => setModalState(() => kosu = val!),
                activeColor: Colors.deepOrange,
              ),
              if (kosu)
                Row(
                  children: [
                    Expanded(child: _miniInput(sureKosu, "Süre (dk)")),
                    const SizedBox(width: 10),
                    Expanded(child: _miniInput(hizKosu, "Hız (km/s)")),
                    const SizedBox(width: 10),
                    Expanded(child: _miniInput(egimKosu, "Eğim %")),
                  ],
                ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  double toplam = 0;
                  if (vg) toplam += (double.tryParse(sureVG.text) ?? 0) * 5;

                  if (kosu) {
                    double s = double.tryParse(sureKosu.text) ?? 0;
                    double h = double.tryParse(hizKosu.text) ?? 5;
                    double e = double.tryParse(egimKosu.text) ?? 0;
                    double kaloriDakika =
                        (0.1 * h * 16.6) + (1.8 * h * 16.6 * (e / 100));
                    double yakilan =
                        (kaloriDakika / 1000) * 5 * widget.k.kilo * s;
                    toplam += yakilan > 0 ? yakilan : s * 6;
                  }

                  v.yakilanSpor += toplam;
                  _kaydetGuncelle();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text("HESAPLA VE KAYDET"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _adimEkle(GunlukVeri v) {
    var cAdim = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adım Sayısı"),
        content: _miniInput(cAdim, "Bugün kaç adım attın?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              int adim = int.tryParse(cAdim.text) ?? 0;
              v.adimSayisi = adim;
              v.yakilanAdim = adim * 0.04;
              _kaydetGuncelle();
              Navigator.pop(ctx);
            },
            child: const Text("KAYDET"),
          ),
        ],
      ),
    );
  }

  void _uykuEkle(GunlukVeri v) async {
    TimeOfDay? yatma = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 0),
      helpText: "KAÇTA YATTIN?",
    );
    if (yatma == null) return;
    TimeOfDay? kalkma = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      helpText: "KAÇTA KALKTIN?",
    );
    if (kalkma == null) return;

    double y = yatma.hour + (yatma.minute / 60);
    double k = kalkma.hour + (kalkma.minute / 60);
    double sure = (k < y) ? (24 - y) + k : k - y;

    v.uykuSaat = sure;
    v.uykuAraligi = "${yatma.format(context)} - ${kalkma.format(context)}";
    _kaydetGuncelle();
  }

  void _raporGoster(GunlukVeri v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Günün Özeti"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🍴 Alınan: ${v.alinanKalori.toInt()} kcal"),
            Text("🔥 Spor Yakımı: ${v.yakilanSpor.toInt()} kcal"),
            Text(
              "🚶 Adım Yakımı: ${v.yakilanAdim.toInt()} kcal (${v.adimSayisi} adım)",
            ),
            const Divider(),
            Text("💧 Su: ${v.suLitre.toStringAsFixed(1)} L"),
            Text(
              "😴 Uyku: ${v.uykuAraligi} (${v.uykuSaat.toStringAsFixed(1)} sa)",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  Widget _miniInput(TextEditingController c, String l) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
