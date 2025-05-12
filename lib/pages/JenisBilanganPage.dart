import 'package:flutter/material.dart';

class JenisBilanganPage extends StatefulWidget {
  @override
  _JenisBilanganPageState createState() => _JenisBilanganPageState();
}

class _JenisBilanganPageState extends State<JenisBilanganPage> {
  final TextEditingController controller = TextEditingController();
  List<String> hasil = [];

  void cek() {
    setState(() {
      try {
        double input = double.parse(controller.text);
        hasil = cekJenisBilangan(input);
      } catch (e) {
        hasil = ["Input tidak valid"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jenis Bilangan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: "Masukkan angka"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: cek,
              child: Text("Cek"),
            ),
            SizedBox(height: 20),
            ...hasil.map((e) => Text("• $e")).toList(),
          ],
        ),
      ),
    );
  }
}

List<String> cekJenisBilangan(num x) {
  List<String> jenis = [];

  if (x is double && x % 1 != 0) {
    if (x > 0) {
      jenis.add("Bilangan Desimal Positif");
    } else {
      jenis.add("Bilangan Desimal Negatif");
    }

  }

  if (x % 1 == 0) {
    int xInt = x.toInt();
    if (xInt >= 0) {
      jenis.add("Bilangan Bulat Positif");
      jenis.add("Bilangan Cacah");
    } else {
      jenis.add("Bilangan Bulat Negatif");
    }

    if (xInt > 1) {
      bool isPrima = true;
      for (int i = 2; i * i <= xInt; i++) {
        if (xInt % i == 0) {
          isPrima = false;
          break;
        }
      }
      if (isPrima) {
        jenis.add("Bilangan Prima");
      }
    }
  }

  if (jenis.isEmpty) {
    jenis.add("Tidak termasuk kategori khusus");
  }

  return jenis;
}