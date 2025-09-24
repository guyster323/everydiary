import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/ocr_service.dart' as ocr_service;
import '../../diary/screens/diary_write_screen.dart';
import '../widgets/text_block_editor.dart';
import '../widgets/text_editor_controls.dart';

/// 텍스트 편집 화면
/// OCR로 인식된 텍스트를 편집하고 일기에 추가할 수 있는 화면입니다.
class TextEditorScreen extends ConsumerStatefulWidget {
  final ocr_service.OCRResult ocrResult;

  const TextEditorScreen({super.key, required this.ocrResult});

  @override
  ConsumerState<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends ConsumerState<TextEditorScreen> {
  late TextEditingController _textController;
  late List<TextBlock> _textBlocks;
  bool _isEditing = false;
  String _originalText = '';

  @override
  void initState() {
    super.initState();
    _initializeTextBlocks();
    // 안전한 텍스트 사용 (빈 결과 방지)
    final safeText = widget.ocrResult.safeText;
    _textController = TextEditingController(text: safeText);
    _originalText = safeText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 텍스트 블록 초기화
  void _initializeTextBlocks() {
    _textBlocks = widget.ocrResult.textBlocks.map((blockText) {
      return TextBlock(
        id: blockText.hashCode.toString(),
        text: blockText,
        confidence: widget.ocrResult.confidence, // OCRResult의 전체 신뢰도 사용
        isSelected: false,
      );
    }).toList();
  }

  /// 텍스트 블록 선택/해제
  void _toggleTextBlockSelection(int index) {
    setState(() {
      _textBlocks[index].isSelected = !_textBlocks[index].isSelected;
    });
  }

  /// 선택된 텍스트 블록 편집
  void _editSelectedBlocks() {
    final selectedBlocks = _textBlocks
        .where((block) => block.isSelected)
        .toList();
    if (selectedBlocks.isEmpty) {
      _showInfoDialog('편집할 텍스트 블록을 선택해주세요.');
      return;
    }

    setState(() {
      _isEditing = true;
    });

    // 선택된 블록들의 텍스트를 편집 모드로 설정
    final selectedText = selectedBlocks.map((block) => block.text).join('\n');
    _textController.text = selectedText;
  }

  /// 텍스트 편집 완료
  void _finishEditing() {
    if (_textController.text.trim().isEmpty) {
      _showErrorDialog('텍스트를 입력해주세요.');
      return;
    }

    setState(() {
      _isEditing = false;
      // 편집된 텍스트를 전체 텍스트에 반영
      _updateFullText();
    });
  }

  /// 전체 텍스트 업데이트
  void _updateFullText() {
    final editedText = _textController.text;
    final selectedBlocks = _textBlocks
        .where((block) => block.isSelected)
        .toList();

    if (selectedBlocks.isNotEmpty) {
      // 선택된 블록들을 편집된 텍스트로 교체
      String fullText = widget.ocrResult.fullText;
      for (final block in selectedBlocks) {
        fullText = fullText.replaceFirst(block.text, editedText);
      }
      _textController.text = fullText;
    }
  }

  /// 텍스트 복사
  void _copyText() {
    Clipboard.setData(ClipboardData(text: _textController.text));
    _showInfoDialog('텍스트가 클립보드에 복사되었습니다.');
  }

  /// 텍스트 저장 (일기에 추가)
  void _saveToDiary() {
    if (_textController.text.trim().isEmpty) {
      _showErrorDialog('저장할 텍스트가 없습니다.');
      return;
    }

    debugPrint('🔍 OCR 텍스트 저장: ${_textController.text.length}자');
    debugPrint('🔍 OCR 텍스트 내용: "${_textController.text}"');

    // 일기 저장 기능 - 일기 작성 화면으로 이동하여 텍스트 전달
    if (mounted) {
      try {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => DiaryWriteScreen(
              initialContent: _textController.text,
              initialTitle: 'OCR로 작성한 일기',
            ),
          ),
        );
      } catch (e) {
        debugPrint('🔍 일기 작성 화면으로 이동 실패: $e');
        _showErrorDialog('일기 작성 화면으로 이동하는 중 오류가 발생했습니다.');
      }
    }
  }

  /// 텍스트 초기화
  void _resetText() {
    setState(() {
      _textController.text = _originalText;
      _isEditing = false;
      for (final block in _textBlocks) {
        block.isSelected = false;
      }
    });
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 정보 다이얼로그 표시
  void _showInfoDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정보'),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('텍스트 편집'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isEditing)
            TextButton(onPressed: _finishEditing, child: const Text('완료')),
        ],
      ),
      body: Column(
        children: [
          // OCR 정보 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'OCR 인식 결과',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '신뢰도: ${(widget.ocrResult.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                ),
                Text(
                  '텍스트 블록: ${_textBlocks.length}개',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                ),
              ],
            ),
          ),

          // 텍스트 블록 목록
          if (!_isEditing) ...[
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _textBlocks.length,
                itemBuilder: (context, index) {
                  final block = _textBlocks[index];
                  return TextBlockEditor(
                    block: block,
                    onTap: () => _toggleTextBlockSelection(index),
                    onEdit: () {
                      setState(() {
                        _textBlocks[index].isSelected = true;
                      });
                      _editSelectedBlocks();
                    },
                  );
                },
              ),
            ),
          ],

          // 텍스트 편집 영역
          Expanded(
            flex: _isEditing ? 3 : 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isEditing ? Icons.edit : Icons.text_fields,
                        color: _isEditing ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditing ? '텍스트 편집 중' : '전체 텍스트',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isEditing ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: '인식된 텍스트가 여기에 표시됩니다...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 컨트롤 버튼들
          TextEditorControls(
            isEditing: _isEditing,
            hasSelectedBlocks: _textBlocks.any((block) => block.isSelected),
            onEdit: _editSelectedBlocks,
            onFinish: _finishEditing,
            onCopy: _copyText,
            onSave: _saveToDiary,
            onReset: _resetText,
          ),
        ],
      ),
    );
  }
}

/// 텍스트 블록 데이터 클래스
class TextBlock {
  final String id;
  String text;
  final double confidence;
  bool isSelected;

  TextBlock({
    required this.id,
    required this.text,
    required this.confidence,
    this.isSelected = false,
  });
}
