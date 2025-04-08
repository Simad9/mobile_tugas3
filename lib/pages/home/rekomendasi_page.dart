import 'package:flutter/material.dart';
import 'package:mobile_tugas3/import/import.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:collection';

class EduWebListPage extends StatefulWidget {
  const EduWebListPage({super.key});

  @override
  State<EduWebListPage> createState() => _EduWebListPageState();
}

class _EduWebListPageState extends State<EduWebListPage> {
  late Map<String, List<EduWebModel>> groupedWebsites;

  @override
  void initState() {
    super.initState();
    groupedWebsites = _groupByCategory(recommendedWebsites);
  }

  Map<String, List<EduWebModel>> _groupByCategory(List<EduWebModel> websites) {
    Map<String, List<EduWebModel>> map = {};
    for (var web in websites) {
      map.putIfAbsent(web.category, () => []).add(web);
    }
    return SplayTreeMap.from(map); // sort by key (category name)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Website Edukasi'),
      ),
      body: SafeArea(
        child: ListView(
          children: groupedWebsites.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul kategori
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                ...entry.value.map((web) => eduWebContainer(web, context)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget eduWebContainer(EduWebModel webDetail, context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EduWebDetailPage(eduWebDetail: webDetail),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    webDetail.logoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.public, size: 80),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        webDetail.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        webDetail.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 18),
                          Text(webDetail.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      webDetail.isFavorite = !webDetail.isFavorite;
                    });
                  },
                  icon: Icon(
                    webDetail.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: webDetail.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(webDetail.siteUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal membuka situs'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.public),
                label: const Text("Go to Website"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
