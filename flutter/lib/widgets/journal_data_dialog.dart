import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/journal_data_service.dart';

/// 웹 MVP `DataTransferDialog.tsx` 대응.
class JournalDataDialog extends StatefulWidget {
  const JournalDataDialog({
    super.key,
    required this.service,
    required this.onImported,
  });

  final JournalDataService service;
  final VoidCallback onImported;

  @override
  State<JournalDataDialog> createState() => _JournalDataDialogState();
}

class _JournalDataDialogState extends State<JournalDataDialog> {
  late final TextEditingController _exportController;
  late final TextEditingController _importController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _exportController = TextEditingController(text: widget.service.exportJson());
    _importController = TextEditingController();
  }

  @override
  void dispose() {
    _exportController.dispose();
    _importController.dispose();
    super.dispose();
  }

  Future<void> _copyExport() async {
    await Clipboard.setData(ClipboardData(text: _exportController.text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON이 클립보드에 복사되었습니다.')),
    );
  }

  Future<void> _handleImport() async {
    final success = await widget.service.importJson(_importController.text);
    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _error = '유효하지 않은 JSON 형식입니다. 스키마 version 1을 확인하세요.';
      });
      return;
    }

    widget.onImported();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('데이터 가져오기 /보내기'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '웹 MVP와 Flutter 앱 간 JSON 백업 파일을 공유할 수 있습니다.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text('보내기', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _exportController,
                readOnly: true,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _copyExport,
                  child: const Text('클립보드 복사'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('가져오기', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _importController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: '{"version":1,"taskStore":{...}}',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _handleImport,
          child: const Text('가져오기'),
        ),
      ],
    );
  }
}
