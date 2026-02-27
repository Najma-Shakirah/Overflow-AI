// lib/screens/report/report_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportViewModel extends ChangeNotifier {
  final List<ReportChannel> channels = [
    ReportChannel(
      icon: Icons.account_balance,
      label: 'Angkatan Pertahanan Awam Malaysia',
      subtitle: 'Flood Disaster Hotline',
      detail: 'civildefence.gov.my',
      color: Colors.orange,
      url: 'https://www.civildefence.gov.my/talian-kecemasan-bencana-banjir/',
      type: ChannelType.website,
    ),
    ReportChannel(
      icon: Icons.account_balance,
      label: 'e-Reporting PDRM',
      subtitle: 'Report disaster without going to police station',
      detail: 'ereporting.rmp.gov.my',
      color: Color(0xFF1a5a8a),
      url: 'https://ereporting.rmp.gov.my/index.aspx',
      type: ChannelType.website,
    ),
    ReportChannel(
      icon: Icons.account_balance,
      label: 'Pusat Kawalan Operasi Bencana (NADMA)',
      subtitle: 'National Disaster Management Agency',
      detail: 'portalbencana.nadma.gov.my',
      color: Colors.red,
      url:
          'https://portalbencana.nadma.gov.my/images/ndcc/documents/PKOB/SENARAI_NOMBOR_PEJABAT_DAERAH.pdf',
      type: ChannelType.website,
    ),
    ReportChannel(
      icon: Icons.language,
      label: 'Public Infobanjir',
      subtitle: 'Official flood info & reporting portal',
      detail: 'publicinfobanjir.water.gov.my',
      color: Color(0xFF3A83B7),
      url:
          'https://publicinfobanjir.water.gov.my/mengenai-kami/hubungi-kami/?lang=en',
      type: ChannelType.website,
    ),
    ReportChannel(
      icon: Icons.phone,
      label: 'Emergency',
      subtitle: 'Life-threatening situations only',
      detail: '999',
      color: Colors.red[800]!,
      url: 'tel:999',
      type: ChannelType.phone,
    ),
  ];

  Future<void> launch(BuildContext context, ReportChannel channel) async {
    final uri = Uri.parse(channel.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Could not open ${channel.label}. Try manually: ${channel.detail}')),
        );
      }
    }
  }
}

enum ChannelType { website, whatsapp, phone }

class ReportChannel {
  final IconData icon;
  final String label;
  final String subtitle;
  final String detail;
  final Color color;
  final String url;
  final ChannelType type;

  const ReportChannel({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.detail,
    required this.color,
    required this.url,
    required this.type,
  });
}
