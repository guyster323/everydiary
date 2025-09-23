import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../shared/services/safe_delta_converter.dart';

/// ?�기??리치 ?�스???�디??class DiaryRichTextEditor extends StatefulWidget {
  final String initialContent;
  final void Function(String) onContentChanged;
  final double height;

  const DiaryRichTextEditor({
    super.key,
    required this.initialContent,
    required this.onContentChanged,
    this.height = 200,
  });

  @override
  State<DiaryRichTextEditor> createState() => DiaryRichTextEditorState();
}

class DiaryRichTextEditorState extends State<DiaryRichTextEditor> {
  late QuillController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Quill 컨트롤러 초기??  void _initializeController() {
    try {
      Document document;

      // 초기 콘텐츠�? 비어?�거??기본값인 경우
      if (widget.initialContent.isEmpty ||
          widget.initialContent == '[]' ||
          widget.initialContent == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // ?�전??Delta ?�싱
        final deltaJson = SafeDeltaConverter.validateAndCleanDelta(
          widget.initialContent,
        );
        final deltaList = jsonDecode(deltaJson) as List<dynamic>;
        document = Document.fromJson(deltaList);
      }

      _controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // ?�용 변�?리스??추�?
      _controller.addListener(_onContentChanged);

      _isInitialized = true;
      debugPrint('?�� Quill ?�디??초기???�료');
    } catch (e) {
      debugPrint('?�� Quill ?�디??초기???�패: $e');

      // 초기???�패 ??�?문서�??�성
      _controller = QuillController.basic();
      _controller.addListener(_onContentChanged);
      _isInitialized = true;
    }
  }

  /// ?�용 변�?콜백
  void _onContentChanged() {
    if (!_isInitialized) return;

    try {
      final delta = _controller.document.toDelta();
      final deltaJson = jsonEncode(delta.toJson());
      widget.onContentChanged(deltaJson);
    } catch (e) {
      debugPrint('?�� Delta JSON 변???�패: $e');
    }
  }

  /// ?�용 로드 (공개 메서??
  void loadContent(String content) {
    if (!_isInitialized) return;

    try {
      Document document;

      // ?�용??비어?�거??기본값인 경우
      if (content.isEmpty ||
          content == '[]' ||
          content == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // ?�전??Delta ?�싱
        final deltaJson = SafeDeltaConverter.validateAndCleanDelta(content);
        final deltaList = jsonDecode(deltaJson) as List<dynamic>;
        document = Document.fromJson(deltaList);
      }

      // 컨트롤러 ?�데?�트
      _controller.document = document;
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );

      debugPrint('?�� ?�디???�용 로드 ?�료: ${content.length}??);
    } catch (e) {
      debugPrint('?�� ?�디???�용 로드 ?�패: $e');
    }
  }

  /// ?�성 ?�스???�입 (공개 메서??
  void insertSpeechText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // ?�재 커서 ?�치???�스???�입
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // 기존 ?�용???�으�?줄바�?추�?
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // 커서�??�입???�스???�으�??�동
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('?�� ?�성 ?�스???�입 ?�료: $text');
    } catch (e) {
      debugPrint('?�� ?�성 ?�스???�입 ?�패: $e');
    }
  }

  /// OCR ?�스???�입 (공개 메서??
  void insertOCRText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // ?�재 커서 ?�치???�스???�입
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // 기존 ?�용???�으�?줄바�?추�?
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // 커서�??�입???�스???�으�??�동
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('?�� OCR ?�스???�입 ?�료: $text');
    } catch (e) {
      debugPrint('?�� OCR ?�스???�입 ?�패: $e');
    }
  }

  /// ?�재 ?�용??Delta JSON?�로 반환
  String getCurrentDeltaJson() {
    if (!_isInitialized) return '[]';

    try {
      final delta = _controller.document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      debugPrint('?�� ?�재 Delta JSON 추출 ?�패: $e');
      return '[]';
    }
  }

  /// ?�재 ?�용???�반 ?�스?�로 반환
  String getCurrentPlainText() {
    if (!_isInitialized) return '';

    try {
      return _controller.document.toPlainText();
    } catch (e) {
      debugPrint('?�� ?�재 ?�반 ?�스??추출 ?�패: $e');
      return '';
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.removeListener(_onContentChanged);
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 최소?�의 ?�바 (?�심 기능�?
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // ?�행 취소/?�시 ?�행
                _buildToolbarButton(
                  icon: Icons.undo,
                  tooltip: '?�행 취소',
                  onPressed: () => _controller.undo(),
                ),
                _buildToolbarButton(
                  icon: Icons.redo,
                  tooltip: '?�시 ?�행',
                  onPressed: () => _controller.redo(),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: Colors.grey),
                const SizedBox(width: 8),
                // 굵게, 기울?? 밑줄
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: '굵게',
                  onPressed: () => _controller.formatSelection(Attribute.bold),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: '기울??,
                  onPressed: () =>
                      _controller.formatSelection(Attribute.italic),
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  tooltip: '밑줄',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.underline),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: Colors.grey),
                const SizedBox(width: 8),
                // 목록
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: '글머리 기호 목록',
                  onPressed: () => _controller.formatSelection(Attribute.ul),
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  tooltip: '번호 목록',
                  onPressed: () => _controller.formatSelection(Attribute.ol),
                ),
                const Spacer(),
                // ?�렬
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  tooltip: '?�쪽 ?�렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.leftAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  tooltip: '가?�데 ?�렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.centerAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  tooltip: '?�른�??�렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.rightAlignment),
                ),
              ],
            ),
          ),

          // ?�디??(최�? 공간 ?�보)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }

  /// ?�바 버튼 빌더
  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Icon(icon, size: 18, color: Colors.grey[700]),
        ),
      ),
    );
  }
}

/// Delta 변???�틸리티
class DeltaConverter {
  /// Delta JSON???�반 ?�스?�로 ?�전?�게 변??  static String deltaToText(String deltaJson) {
    return SafeDeltaConverter.deltaToText(deltaJson);
  }

  /// Delta JSON??Markdown?�로 변??  static String deltaToMarkdown(String deltaJson) {
    try {
      final deltaJsonList = jsonDecode(deltaJson) as List<dynamic>;
      final document = Document.fromJson(deltaJsonList);
      // Markdown 변?��? 별도 ?�이브러리�? ?�요?��?�?간단???�스??변?�으�??��?      return document.toPlainText();
    } catch (e) {
      return '변??�??�류가 발생?�습?�다.';
    }
  }

  /// HTML??Delta JSON?�로 변??  static String htmlToDelta(String html) {
    try {
      // HTML??Delta�?변?�하??것�? 복잡?��?�?�?문서�?반환
      final document = Document();
      final delta = document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      return '[]';
    }
  }

  /// ?�스?��? Delta JSON?�로 변??  static String textToDelta(String text) {
    return SafeDeltaConverter.textToDelta(text);
  }

  /// Delta JSON 검�?�??�리
  static String validateDelta(String deltaJson) {
    return SafeDeltaConverter.validateAndCleanDelta(deltaJson);
  }
}
  /// ?�전??Delta JSON 변??  static String textToDelta(String text) {
    try {
      if (text.isEmpty) {
        return '[{"insert":"\\n"}]';
      }

      // ?�스???�에 개행???�으�?추�? (Quill ?�구?�항)
