import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../shared/services/safe_delta_converter.dart';

/// 일기용 리치 텍스트 에디터
class DiaryRichTextEditor extends StatefulWidget {
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
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Quill 컨트롤러 초기화
  void _initializeController() {
    try {
      Document document;

      // 초기 콘텐츠가 비어있거나 기본값인 경우
      if (widget.initialContent.isEmpty ||
          widget.initialContent == '[]' ||
          widget.initialContent == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // 안전한 Delta 파싱
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

      // 내용 변경 리스너 추가
      _controller.addListener(_onContentChanged);

      _isInitialized = true;
      debugPrint('📝 Quill 에디터 초기화 완료');
    } catch (e) {
      debugPrint('📝 Quill 에디터 초기화 실패: $e');

      // 초기화 실패 시 빈 문서로 생성
      _controller = QuillController.basic();
      _controller.addListener(_onContentChanged);
      _isInitialized = true;
    }
  }

  /// 내용 변경 콜백
  void _onContentChanged() {
    if (!_isInitialized) return;

    try {
      final delta = _controller.document.toDelta();
      final deltaJson = jsonEncode(delta.toJson());
      widget.onContentChanged(deltaJson);
    } catch (e) {
      debugPrint('📝 Delta JSON 변환 실패: $e');
    }
  }

  /// 내용 로드 (공개 메서드)
  void loadContent(String content) {
    if (!_isInitialized) return;

    try {
      Document document;

      // 내용이 비어있거나 기본값인 경우
      if (content.isEmpty ||
          content == '[]' ||
          content == '[{"insert":"\\n"}]') {
        document = Document();
      } else {
        // 안전한 Delta 파싱
        final deltaJson = SafeDeltaConverter.validateAndCleanDelta(content);
        final deltaList = jsonDecode(deltaJson) as List<dynamic>;
        document = Document.fromJson(deltaList);
      }

      // 컨트롤러 업데이트
      _controller.document = document;
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );

      debugPrint('📝 에디터 내용 로드 완료: ${content.length}자');
    } catch (e) {
      debugPrint('📝 에디터 내용 로드 실패: $e');
    }
  }

  /// 음성 텍스트 삽입 (공개 메서드)
  void insertSpeechText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // 현재 커서 위치에 텍스트 삽입
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // 기존 내용이 있으면 줄바꿈 추가
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // 커서를 삽입된 텍스트 끝으로 이동
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('📝 음성 텍스트 삽입 완료: $text');
    } catch (e) {
      debugPrint('📝 음성 텍스트 삽입 실패: $e');
    }
  }

  /// OCR 텍스트 삽입 (공개 메서드)
  void insertOCRText(String text) {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // 현재 커서 위치에 텍스트 삽입
      final selection = _controller.selection;
      final index = selection.baseOffset;

      // 기존 내용이 있으면 줄바꿈 추가
      final currentText = _controller.document.toPlainText();
      String textToInsert = text;

      if (currentText.trim().isNotEmpty && index > 0) {
        textToInsert = '\n\n$text';
      }

      _controller.document.insert(index, textToInsert);

      // 커서를 삽입된 텍스트 끝으로 이동
      final newCursorPosition = index + textToInsert.length;
      _controller.updateSelection(
        TextSelection.collapsed(offset: newCursorPosition),
        ChangeSource.local,
      );

      debugPrint('📝 OCR 텍스트 삽입 완료: $text');
    } catch (e) {
      debugPrint('📝 OCR 텍스트 삽입 실패: $e');
    }
  }

  /// 현재 내용을 Delta JSON으로 반환
  String getCurrentDeltaJson() {
    if (!_isInitialized) return '[]';

    try {
      final delta = _controller.document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      debugPrint('📝 현재 Delta JSON 추출 실패: $e');
      return '[]';
    }
  }

  /// 현재 내용을 일반 텍스트로 반환
  String getCurrentPlainText() {
    if (!_isInitialized) return '';

    try {
      return _controller.document.toPlainText();
    } catch (e) {
      debugPrint('📝 현재 일반 텍스트 추출 실패: $e');
      return '';
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.removeListener(_onContentChanged);
      _controller.dispose();
    }
    _focusNode.dispose();
    _scrollController.dispose();
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
          // 최소한의 툴바 (핵심 기능만)
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
                // 실행 취소/다시 실행
                _buildToolbarButton(
                  icon: Icons.undo,
                  tooltip: '실행 취소',
                  onPressed: () => _controller.undo(),
                ),
                _buildToolbarButton(
                  icon: Icons.redo,
                  tooltip: '다시 실행',
                  onPressed: () => _controller.redo(),
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, color: Colors.grey),
                const SizedBox(width: 8),
                // 굵게, 기울임, 밑줄
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: '굵게',
                  onPressed: () => _controller.formatSelection(Attribute.bold),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: '기울임',
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
                // 정렬
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  tooltip: '왼쪽 정렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.leftAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  tooltip: '가운데 정렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.centerAlignment),
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  tooltip: '오른쪽 정렬',
                  onPressed: () =>
                      _controller.formatSelection(Attribute.rightAlignment),
                ),
              ],
            ),
          ),

          // 에디터 (최대 공간 확보)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.black87,
                    displayColor: Colors.black87,
                  ),
                ),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    height: 1.6,
                  ),
                  child: QuillEditor.basic(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: const QuillEditorConfig(
                      autoFocus: false,
                      expands: true,
                      padding: EdgeInsets.zero,
                      placeholder: '오늘의 이야기를 기록해 보세요...',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 툴바 버튼 빌더
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

/// Delta 변환 유틸리티
class DeltaConverter {
  /// Delta JSON을 일반 텍스트로 안전하게 변환
  static String deltaToText(String deltaJson) {
    return SafeDeltaConverter.deltaToText(deltaJson);
  }

  /// Delta JSON을 Markdown으로 변환
  static String deltaToMarkdown(String deltaJson) {
    try {
      final deltaJsonList = jsonDecode(deltaJson) as List<dynamic>;
      final document = Document.fromJson(deltaJsonList);
      // Markdown 변환은 별도 라이브러리가 필요하므로 간단한 텍스트 변환으로 대체
      return document.toPlainText();
    } catch (e) {
      return '변환 중 오류가 발생했습니다.';
    }
  }

  /// HTML을 Delta JSON으로 변환
  static String htmlToDelta(String html) {
    try {
      // HTML을 Delta로 변환하는 것은 복잡하므로 빈 문서로 반환
      final document = Document();
      final delta = document.toDelta();
      return jsonEncode(delta.toJson());
    } catch (e) {
      return '[]';
    }
  }

  /// 텍스트를 Delta JSON으로 변환
  static String textToDelta(String text) {
    return SafeDeltaConverter.textToDelta(text);
  }

  /// Delta JSON 검증 및 정리
  static String validateDelta(String deltaJson) {
    return SafeDeltaConverter.validateAndCleanDelta(deltaJson);
  }
}
