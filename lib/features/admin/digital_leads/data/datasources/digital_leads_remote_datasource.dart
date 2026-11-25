import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timelay_health/features/admin/digital_leads/data/endpoints/digital_leads_endpoints.dart';
import 'package:timelay_health/features/admin/digital_leads/data/models/digital_lead_model.dart';

class DigitalLeadsResult {
  final List<DigitalLead> leads;
  final LeadCounts? counts;
  final int total;

  const DigitalLeadsResult({
    required this.leads,
    this.counts,
    this.total = 0,
  });
}

class DigitalLeadsRemoteDataSource {
  DigitalLeadsRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<DigitalLeadsResult> getConsultationLeads({
    int page = 1,
    int limit = 100,
  }) async {
    final url = DigitalLeadsEndpoints.consultationLeads(
      page: page,
      limit: limit,
    );
    late final http.Response response;

    try {
      response = await _client.get(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      final sample = DigitalLead.sampleLeads();
      return DigitalLeadsResult(
        leads: sample,
        counts: LeadCounts(
          totalLeads: sample.length,
          newLeads: sample.where((l) => l.status == LeadStatus.newLead).length,
          contacted:
              sample.where((l) => l.status == LeadStatus.contacted).length,
          converted:
              sample.where((l) => l.status == LeadStatus.converted).length,
          rejected: sample.where((l) => l.status == LeadStatus.rejected).length,
        ),
        total: sample.length,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final sample = DigitalLead.sampleLeads();
      return DigitalLeadsResult(
        leads: sample,
        counts: LeadCounts(
          totalLeads: sample.length,
          newLeads: sample.where((l) => l.status == LeadStatus.newLead).length,
          contacted:
              sample.where((l) => l.status == LeadStatus.contacted).length,
          converted:
              sample.where((l) => l.status == LeadStatus.converted).length,
          rejected: sample.where((l) => l.status == LeadStatus.rejected).length,
        ),
        total: sample.length,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        LeadCounts? counts;
        if (decoded['counts'] is Map) {
          counts = LeadCounts.fromJson(
            Map<String, dynamic>.from(decoded['counts'] as Map),
          );
        }

        final listRaw = decoded['data'] ?? decoded['leads'];
        final total = (decoded['total'] as num?)?.toInt() ?? 0;

        if (listRaw is List) {
          final items = <DigitalLead>[];
          for (var i = 0; i < listRaw.length; i++) {
            final item = listRaw[i];
            if (item is Map) {
              items.add(
                DigitalLead.fromJson(Map<String, dynamic>.from(item), i),
              );
            }
          }

          if (items.isNotEmpty) {
            return DigitalLeadsResult(
              leads: items,
              counts: counts ??
                  LeadCounts(
                    totalLeads: items.length,
                    newLeads: items
                        .where((l) => l.status == LeadStatus.newLead)
                        .length,
                    contacted: items
                        .where((l) => l.status == LeadStatus.contacted)
                        .length,
                    converted: items
                        .where((l) => l.status == LeadStatus.converted)
                        .length,
                    rejected: items
                        .where((l) => l.status == LeadStatus.rejected)
                        .length,
                  ),
              total: total > 0 ? total : items.length,
            );
          }
        }
      }

      final sample = DigitalLead.sampleLeads();
      return DigitalLeadsResult(
        leads: sample,
        counts: LeadCounts(
          totalLeads: sample.length,
          newLeads: sample.where((l) => l.status == LeadStatus.newLead).length,
          contacted:
              sample.where((l) => l.status == LeadStatus.contacted).length,
          converted:
              sample.where((l) => l.status == LeadStatus.converted).length,
          rejected: sample.where((l) => l.status == LeadStatus.rejected).length,
        ),
        total: sample.length,
      );
    } catch (_) {
      final sample = DigitalLead.sampleLeads();
      return DigitalLeadsResult(
        leads: sample,
        counts: LeadCounts(
          totalLeads: sample.length,
          newLeads: sample.where((l) => l.status == LeadStatus.newLead).length,
          contacted:
              sample.where((l) => l.status == LeadStatus.contacted).length,
          converted:
              sample.where((l) => l.status == LeadStatus.converted).length,
          rejected: sample.where((l) => l.status == LeadStatus.rejected).length,
        ),
        total: sample.length,
      );
    }
  }
}
