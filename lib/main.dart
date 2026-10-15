import 'package:flutter/material.dart';
import 'package:offline_slm/offline_slm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TestOfflineSLMApp());
}

class TestOfflineSLMApp extends StatefulWidget {
  const TestOfflineSLMApp({super.key});

  @override
  State<TestOfflineSLMApp> createState() => _TestOfflineSLMAppState();
}

class _TestOfflineSLMAppState extends State<TestOfflineSLMApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline SLM Tester',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFF121417),
        useMaterial3: true,
      ),
      home: TestChatScreen(
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class TestChatScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const TestChatScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<TestChatScreen> createState() => _TestChatScreenState();
}

class _TestChatScreenState extends State<TestChatScreen> {
  late OfflineChatController _controller;
  DownloadProgress? _downloadProgress;
  ModelPreset _selectedPreset = ModelPresets.smolLM2_360M;
  bool _useSimulation = true;

  @override
  void initState() {
    super.initState();
    _controller = OfflineChatController(
      engine: MockSLMEngine(tokenDelayMs: 30),
      systemPrompt:
          'You are a fast, private offline AI assistant running locally on this device.',
    );
    _initDefaultModel();
  }

  Future<void> _initDefaultModel() async {
    await _controller.initializeModel(
      const SLMModelConfig(
        modelPath: 'smollm2_360m.sim',
        contextSize: 2048,
        threads: 4,
      ),
      modelName: 'SmolLM2 360M (Simulator)',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showModelPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Offline Model',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All computation runs 100% locally on your device CPU/GPU.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Simulator Mode (Instant Preview)'),
                      subtitle: const Text(
                        'Test live streaming tokens without waiting to download GGUF',
                      ),
                      value: _useSimulation,
                      onChanged: (val) {
                        setSheetState(() => _useSimulation = val);
                        setState(() => _useSimulation = val);
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 6),
                    ...ModelPresets.all.map((preset) {
                      final isSelected = _selectedPreset.id == preset.id;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withAlpha(50),
                          child: Icon(
                            Icons.memory,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                preset.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                preset.formattedSize,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          preset.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _selectAndLoadModel(preset);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectAndLoadModel(ModelPreset preset) async {
    setState(() {
      _selectedPreset = preset;
    });

    if (_useSimulation) {
      await _controller.initializeModel(
        SLMModelConfig(
          modelPath: '${preset.fileName}.sim',
          contextSize: preset.recommendedContextSize,
        ),
        modelName: '${preset.name} (Simulator)',
        template: preset.template,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${preset.name} (Simulator)')),
        );
      }
      return;
    }

    try {
      final config = await ModelManager.prepareModelConfig(
        preset,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      await _controller.initializeModel(
        config,
        modelName: preset.name,
        template: preset.template,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${preset.name} loaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading model: $e')),
        );
      }
    } finally {
      setState(() {
        _downloadProgress = null;
      });
    }
  }

  void _showSettingsDialog() {
    final systemPromptCtrl =
        TextEditingController(text: _controller.systemPrompt);
    double temp = _controller.generationConfig.temperature;
    double topP = _controller.generationConfig.topP;
    int maxTokens = _controller.generationConfig.maxTokens;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Generation Settings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Prompt',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: systemPromptCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Temperature: ${temp.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Slider(
                      value: temp,
                      min: 0.0,
                      max: 1.5,
                      divisions: 15,
                      label: temp.toStringAsFixed(2),
                      onChanged: (v) => setDialogState(() => temp = v),
                    ),
                    Text(
                      'Top-P: ${topP.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Slider(
                      value: topP,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      label: topP.toStringAsFixed(2),
                      onChanged: (v) => setDialogState(() => topP = v),
                    ),
                    Text(
                      'Max Tokens: $maxTokens',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Slider(
                      value: maxTokens.toDouble(),
                      min: 128,
                      max: 2048,
                      divisions: 15,
                      label: '$maxTokens',
                      onChanged: (v) =>
                          setDialogState(() => maxTokens = v.toInt()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    _controller.systemPrompt = systemPromptCtrl.text;
                    _controller.generationConfig =
                        _controller.generationConfig.copyWith(
                      temperature: temp,
                      topP: topP,
                      maxTokens: maxTokens,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              'Offline SLM Tester',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: widget.isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Settings',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: OfflineChatWidget(
        controller: _controller,
        theme: widget.isDark ? OfflineChatTheme.dark() : OfflineChatTheme.light(),
        downloadProgress: _downloadProgress,
        onSwitchModel: _showModelPickerSheet,
        suggestions: const [
          'What are the advantages of offline SLMs?',
          'Write a Flutter offline data cache service',
          'Explain quantization (Q4_K_M) simply',
          'Give me 3 mobile privacy tips',
        ],
      ),
    );
  }
}
