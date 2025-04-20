import 'package:flutter/material.dart';
import 'package:mobile_tugas3/import/import.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoriteEduWebPage extends StatefulWidget {
  const FavoriteEduWebPage({super.key});

  @override
  State<FavoriteEduWebPage> createState() => _FavoriteEduWebPageState();
}

class _FavoriteEduWebPageState extends State<FavoriteEduWebPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter hanya yang difavoritkan
    final favoriteWebsites =
    recommendedWebsites.where((web) => web.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Website Favorit'),
        centerTitle: true,
      ),
      body: favoriteWebsites.isEmpty
          ? const Center(
        child: Text("Belum ada website yang difavoritkan."),
      )
          : ListView.builder(
        itemCount: favoriteWebsites.length,
        itemBuilder: (context, index) {
          final web = favoriteWebsites[index];
          return _eduWebContainer(web, context);
        },
      ),
    );
  }

  Widget _eduWebContainer(EduWebModel webDetail, BuildContext context) {
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
                          const Icon(Icons.star, color: Colors.amber, size: 18),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
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
