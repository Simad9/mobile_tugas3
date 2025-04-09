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
    return SplayTreeMap.from(map); // Sort berdasarkan kategori
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi Website Edukasi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: groupedWebsites.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Kategori
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    entry.key,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
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

  Widget eduWebContainer(EduWebModel webDetail, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.surface,
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
                      const Icon(Icons.public, size: 80, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        webDetail.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        webDetail.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            webDetail.rating.toString(),
                            style: theme.textTheme.bodySmall,
                          ),
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
                    color: webDetail.isFavorite
                        ? Colors.red
                        : colorScheme.onSurface.withOpacity(0.4),
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
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal membuka situs')),
                    );
                  }
                },
                icon: const Icon(Icons.public, color: Colors.black),
                label: const Text("Kunjungi Situs"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
