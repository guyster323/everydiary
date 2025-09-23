import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../shared/services/safe_delta_converter.dart';

/// ?¼ê¸°??ë¦¬ì¹˜ ?ìŠ¤???ë””??class DiaryRichTextEditor extends StatefulWidget {
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

  /// Quill ì»¨íŠ¸ë¡¤ëŸ¬ ì´ˆê¸°??  void _initializeController() {
    try {
      Document document;

      // ì´ˆê¸° ì½˜í…ì¸ ê? ë¹„ì–´?ˆê±°??ê¸°ë³¸ê°’ì¸ ê²½ìš°
      if (widget.initialContent.isEmpty ||
          widget.initialContent == '[]' ||
          widget.initialContent == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // ?ˆì „??Delta ?Œì‹±
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

      // ?´ìš© ë³€ê²?ë¦¬ìŠ¤??ì¶”ê?
      _controller.addListener(_onContentChanged);

      _isInitialized = true;
      debugPrint('?“ Quill ?ë””??ì´ˆê¸°???„ë£Œ');
    } catch (e) {
      debugPrint('?“ Quill ?ë””??ì´ˆê¸°???¤íŒ¨: $e');

      // ì´ˆê¸°???¤íŒ¨ ??ë¹?ë¬¸ì„œë¡??ì„±
      _controller = QuillController.basic();
      _controller.addListener(_onContentChanged);
      _isInitialized = true;
    }
  }

  /// ?´ìš© ë³€ê²?ì½œë°±
  void _onContentChanged() {
    if (!_isInitialized) return;

    try {
      final delta = _controller.document.toDelta();
      final deltaJson = jsonEncode(delta.toJson());
      widget.onContentChanged(deltaJson);
    } catch (e) {
      debugPrint('?“ Delta JSON ë³€???¤íŒ¨: $e');
    }
  }

  /// ?´ìš© ë¡œë“œ (ê³µê°œ ë©”ì„œ??
  void loadContent(String content) {
    if (!_isInitialized) return;

    try {
      Document document;

      // ?´ìš©??ë¹„ì–´?ˆê±°??ê¸°ë³¸ê°’ì¸ ê²½ìš°
      if (content.isEmpty ||
          content == '[]' ||
          content == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // ?ˆì „??Delta ?Œì‹±
        final deltaJson = SafeDeltaConverter.validateAndCleanDelta(content);
        final deltaList = jsonDecode(deltaJson) as List<dynamic>;
        document = Document.fromJson(deltaList);
      }

      // ì»¨íŠ¸ë¡¤ëŸ¬ ?…ë°?´íŠ¸
      _controller.document = document;
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );

      debugPrint('?“ ?ë””???´ìš© ë¡œë“œ ?„ë£Œ: ${content.length}??);
    } catch (e) {
      debugPrint('?“ ?ë””???´ìš© ë¡œë“œ ?¤íŒ¨: $e');
    }
  }

  /// ?Œì„± ?ìŠ¤???½ì… (ê³µê°œ ë©”ì„œ??
  void insertSpeechText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // ?„ì¬ ì»¤ì„œ ?„ì¹˜???ìŠ¤???½ì…
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // ê¸°ì¡´ ?´ìš©???ˆìœ¼ë©?ì¤„ë°”ê¿?ì¶”ê?
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // ì»¤ì„œë¥??½ì…???ìŠ¤???ìœ¼ë¡??´ë™
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('?“ ?Œì„± ?ìŠ¤???½ì… ?„ë£Œ: $text');
    } catch (e) {
      debugPrint('?“ ?Œì„± ?ìŠ¤???½ì… ?¤íŒ¨: $e');
    }
  }

  /// OCR ?ìŠ¤???½ì… (ê³µê°œ ë©”ì„œ??
  void insertOCRText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // ?„ì¬ ì»¤ì„œ ?„ì¹˜???ìŠ¤???½ì…
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // ê¸°ì¡´ ?´ìš©???ˆìœ¼ë©?ì¤„ë°”ê¿?ì¶”ê?
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // ì»¤ì„œë¥??½ì…???ìŠ¤???ìœ¼ë¡??´ë™
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('?“ OCR ?ìŠ¤???½ì… ?„ë£Œ: $text');
    } catch (e) {
      debugPrint('?“ OCR ?ìŠ¤???½ì… ?¤íŒ¨: $e');
    }
  }

  /// ?„ì¬ ?´ìš©??Delta JSON?¼ë¡œ ë°˜í™˜
  String getCurrentDeltaJson() {
    if (!_isInitialized) return '[]';

    try {
      final delta = _controller.document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      debugPrint('?“ ?„ì¬ Delta JSON ì¶”ì¶œ ?¤íŒ¨: $e');
      return '[]';
    }
  }

  /// ?„ì¬ ?´ìš©???¼ë°˜ ?ìŠ¤?¸ë¡œ ë°˜í™˜
  String getCurrentPlainText() {
    if (!_isInitialized) return '';

    try {
      return _controller.document.toPlainText();
    } catch (e) {
      debugPrint('?“ ?„ì¬ ?¼ë°˜ ?ìŠ¤??ì¶”ì¶œ ?¤íŒ¨: $e');
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
          // ìµœì†Œ?œì˜ ?´ë°” (?µì‹¬ ê¸°ëŠ¥ë§?
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
                // ?¤í–‰ ì·¨ì†Œ/?¤ì‹œ ?¤í–‰
                _buildToolbarButton(
                  icon: Icons.undo,
                  tooltip: '?¤í–‰ ì·¨ì†Œ',
                  onPressed: () => _controller.undo(),
                ),
                _buildToolbarButton(
                  icon: Icons.redo,
                  tooltip: '?¤ì‹œ ?¤í–‰',
                  onPressed: () => _controller.redo(),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: Colors.grey),
                const SizedBox(width: 8),
                // êµµê²Œ, ê¸°ìš¸?? ë°‘ì¤„
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'êµµê²Œ',
                  onPressed: () => _controller.formatSelection(Attribute.bold),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'ê¸°ìš¸??,
                  onPressed: () =>
                      _controller.formatSelection(Attribute.italic),
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  tooltip: 'ë°‘ì¤„',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.underline),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: Colors.grey),
                const SizedBox(width: 8),
                // ëª©ë¡
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: 'ê¸€ë¨¸ë¦¬ ê¸°í˜¸ ëª©ë¡',
                  onPressed: () => _controller.formatSelection(Attribute.ul),
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  tooltip: 'ë²ˆí˜¸ ëª©ë¡',
                  onPressed: () => _controller.formatSelection(Attribute.ol),
                ),
                const Spacer(),
                // ?•ë ¬
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  tooltip: '?¼ìª½ ?•ë ¬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.leftAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  tooltip: 'ê°€?´ë° ?•ë ¬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.centerAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  tooltip: '?¤ë¥¸ìª??•ë ¬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.rightAlignment),
                ),
              ],
            ),
          ),

          // ?ë””??(ìµœë? ê³µê°„ ?•ë³´)
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

  /// ?´ë°” ë²„íŠ¼ ë¹Œë”
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

/// Delta ë³€??? í‹¸ë¦¬í‹°
class DeltaConverter {
  /// Delta JSON???¼ë°˜ ?ìŠ¤?¸ë¡œ ?ˆì „?˜ê²Œ ë³€??  static String deltaToText(String deltaJson) {
    return SafeDeltaConverter.deltaToText(deltaJson);
  }

  /// Delta JSON??Markdown?¼ë¡œ ë³€??  static String deltaToMarkdown(String deltaJson) {
    try {
      final deltaJsonList = jsonDecode(deltaJson) as List<dynamic>;
      final document = Document.fromJson(deltaJsonList);
      // Markdown ë³€?˜ì? ë³„ë„ ?¼ì´ë¸ŒëŸ¬ë¦¬ê? ?„ìš”?˜ë?ë¡?ê°„ë‹¨???ìŠ¤??ë³€?˜ìœ¼ë¡??€ì²?      return document.toPlainText();
    } catch (e) {
      return 'ë³€??ì¤??¤ë¥˜ê°€ ë°œìƒ?ˆìŠµ?ˆë‹¤.';
    }
  }

  /// HTML??Delta JSON?¼ë¡œ ë³€??  static String htmlToDelta(String html) {
    try {
      // HTML??Deltaë¡?ë³€?˜í•˜??ê²ƒì? ë³µì¡?˜ë?ë¡?ë¹?ë¬¸ì„œë¡?ë°˜í™˜
      final document = Document();
      final delta = document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      return '[]';
    }
  }

  /// ?ìŠ¤?¸ë? Delta JSON?¼ë¡œ ë³€??  static String textToDelta(String text) {
    return SafeDeltaConverter.textToDelta(text);
  }

  /// Delta JSON ê²€ì¦?ë°??•ë¦¬
  static String validateDelta(String deltaJson) {
    return SafeDeltaConverter.validateAndCleanDelta(deltaJson);
  }
}
  /// ?ˆì „??Delta JSON ë³€??  static String textToDelta(String text) {
    try {
      if (text.isEmpty) {
        return '[{"insert":"\\n"}]';
      }

      // ?ìŠ¤???ì— ê°œí–‰???†ìœ¼ë©?ì¶”ê? (Quill ?”êµ¬?¬í•­)
