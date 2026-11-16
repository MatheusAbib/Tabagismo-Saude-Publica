
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/header/modals/sintomas_modal_widget.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';

class HomeMetasWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onRefresh;

  const HomeMetasWidget({
    Key? key,
    required this.userData,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<HomeMetasWidget> createState() => _HomeMetasWidgetState();
}

class _HomeMetasWidgetState extends State<HomeMetasWidget> {
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF333333);
  static const Color secondary = Color(0xFF4E4E4E);
  static const Color muted = Color(0xFF8A8A85);
  static const Color border = Color(0xFFE4E0D6);

  static const Color mintLight = Color(0xFFD9F0E6);
  static const Color mintMid = Color(0xFFB8E4D2);
  static const Color mintDark = Color(0xFF2F7A63);

  static const Color lavenderLight = Color(0xFFE8E5F4);
  static const Color lavenderDark = Color(0xFF65568D);

  static const Color blueLight = Color(0xFFE1EDF6);
  static const Color blueDark = Color(0xFF426E8C);

  static const Color terraLight = Color(0xFFF2D9CC);
  static const Color terraDark = Color(0xFF8F4A2C);

  static const Color sageLight = Color(0xFFE5EEDC);
  static const Color sageDark = Color(0xFF54734B);

  late Map<String, dynamic> _userData;
  int? _scoreFagerstrom;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _loadFagerstromScore();
  }

  @override
  void didUpdateWidget(covariant HomeMetasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _userData = widget.userData;
  }

  Future<void> _loadFagerstromScore() async {
    try {
      final response = await AuthService().getUserData();
      final user = response['user'];

      if (!mounted || user == null) return;

      final score = int.tryParse(
        user['scoreFagestrom']?.toString() ?? '',
      );

      setState(() {
        _scoreFagerstrom = score != null && score > 0 ? score : null;
      });
    } catch (e) {
      debugPrint('Erro ao carregar score: $e');
    }
  }

  DateTime? _getStopDate() {
    final raw = _userData['stopDate']?.toString();
    if (raw == null || raw.isEmpty || raw == 'null') return null;

    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  int? _getTargetDays() {
    return int.tryParse(_userData['targetDays']?.toString() ?? '');
  }

  int? _getCigarettesPerDay() {
    return int.tryParse(_userData['cigarrosPorDia']?.toString() ?? '');
  }

  double? _getPackPrice() {
    return double.tryParse(_userData['valorCarteira']?.toString() ?? '');
  }

  int _daysWithoutSmoking(DateTime? date) {
    if (date == null) return 0;

    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    final startDay = DateTime(date.year, date.month, date.day);

    return currentDay.difference(startDay).inDays.clamp(0, 999999);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime? _parseDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > DateTime.now().year) return null;

    final date = DateTime(year, month, day);

    if (date.day != day ||
        date.month != month ||
        date.year != year ||
        date.isAfter(DateTime.now())) {
      return null;
    }

    return date;
  }

  String _formatMoney(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final formatted = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'R\$ $formatted,${parts[1]}';
  }

  Future<void> _saveGoal(
    DateTime stopDate,
    int targetDays, {
    int? cigarrosPorDia,
    double? valorCarteira,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final formattedDate =
          '${stopDate.year}-${stopDate.month.toString().padLeft(2, '0')}-${stopDate.day.toString().padLeft(2, '0')}';

      final authService = AuthService();

      await authService.updateGoal(
        formattedDate,
        targetDays,
        cigarrosPorDia,
        valorCarteira,
      );

      final response = await authService.getUserData();
      final user = response['user'];

      if (!mounted) return;

      setState(() {
        if (user != null) {
          final savedDate = user['stop_date']?.toString();

          if (savedDate != null &&
              savedDate.isNotEmpty &&
              savedDate != 'null') {
            _userData['stopDate'] = savedDate;
          }

          final savedTarget = int.tryParse(
            user['target_days']?.toString() ?? '',
          );

          if (savedTarget != null && savedTarget > 0) {
            _userData['targetDays'] = savedTarget;
          }

          final savedCigarettes = int.tryParse(
            user['cigarros_por_dia']?.toString() ?? '',
          );

          if (savedCigarettes != null && savedCigarettes > 0) {
            _userData['cigarrosPorDia'] = savedCigarettes;
          }

          final savedPrice = double.tryParse(
            user['valor_carteira']?.toString() ?? '',
          );

          if (savedPrice != null && savedPrice > 0) {
            _userData['valorCarteira'] = savedPrice;
          }
        }
      });

      widget.onRefresh();
      ToastService.showSuccess(context, 'Meta definida com sucesso!');
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Erro ao salvar meta: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openFagerstrom() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: size.width > 800 ? 850 : size.width * 0.95,
            height: size.height > 800 ? 750 : size.height * 0.85,
            child: FagerstromTestModal(
              onScoreUpdated: (score) {
                if (mounted) {
                  setState(() => _scoreFagerstrom = score);
                  _loadFagerstromScore();
                }
              },
            ),
          ),
        );
      },
    );
  }


void _showGoalModal() {
  final stopDate = _getStopDate();
  final targetDays = _getTargetDays();
  final cigarettes = _getCigarettesPerDay();
  final packPrice = _getPackPrice();

  final dateController = TextEditingController(
    text: stopDate != null ? _formatDate(stopDate) : '',
  );

  final targetController = TextEditingController(
    text: targetDays?.toString() ?? '',
  );

  final cigarettesController = TextEditingController(
    text: cigarettes?.toString() ?? '',
  );

  final priceController = TextEditingController(
    text: packPrice?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );

  const modalBackground = Color(0xFFFFFDF9);
  const modalSurface = Colors.white;
  const modalPrimary = Color(0xFF426E8C);
  const modalPrimaryLight = Color(0xFFE1EDF6);
  const modalText = Color(0xFF333333);
  const modalSecondary = Color(0xFF667078);
  const modalBorder = Color(0xFFE6E5DF);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final screenSize = MediaQuery.sizeOf(dialogContext);
      final isMobile = screenSize.width < 768;
      final keyboardHeight = MediaQuery.viewInsetsOf(dialogContext).bottom;

      void saveGoal() {
        final parsedDate = _parseDate(dateController.text);
        final parsedTarget = int.tryParse(targetController.text);
        final parsedCigarettes = int.tryParse(cigarettesController.text);
        final parsedPrice = double.tryParse(
          priceController.text.replaceAll(',', '.'),
        );

        if (parsedDate == null ||
            parsedTarget == null ||
            parsedTarget <= 0) {
          ToastService.showWarning(
            context,
            'Preencha a data (DD/MM/AAAA) e a meta corretamente',
          );
          return;
        }

        Navigator.pop(dialogContext);

        _saveGoal(
          parsedDate,
          parsedTarget,
          cigarrosPorDia: parsedCigarettes,
          valorCarteira: parsedPrice,
        );
      }

      return Dialog(
        backgroundColor: modalBackground,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 16 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: modalBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 580,
            maxHeight: screenSize.height -
                keyboardHeight -
                (isMobile ? 32 : 48),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 24,
                  vertical: isMobile ? 16 : 20,
                ),
                decoration: const BoxDecoration(
                  color: modalBackground,
                  border: Border(
                    bottom: BorderSide(color: modalBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 40 : 44,
                      height: isMobile ? 40 : 44,
                      decoration: BoxDecoration(
                        color: modalPrimaryLight,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.flag_outlined,
                        color: modalPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Definir meta',
                            style: TextStyle(
                              fontFamily: 'DMSerifDisplay',
                              fontSize: isMobile ? 23 : 26,
                              color: modalText,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Configure seu acompanhamento',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isMobile ? 11 : 12,
                              color: modalSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      tooltip: 'Fechar',
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: modalBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      icon: const Icon(
                        Icons.close,
                        size: 19,
                        color: modalSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 18 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INFORMAÇÕES DA META',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: modalPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Defina quando iniciou sua jornada e por quantos dias deseja manter sua meta.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.55,
                          color: modalSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildFormField(
                        label: 'Data que parou de fumar',
                        description: 'Informe a data de início',
                        icon: Icons.calendar_today_outlined,
                        iconColor: modalPrimary,
                        controller: dateController,
                        hint: 'DD/MM/AAAA',
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9/]'),
                          ),
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildFormField(
                        label: 'Meta em dias',
                        description: 'Quantos dias deseja alcançar?',
                        icon: Icons.flag_outlined,
                        iconColor: modalPrimary,
                        controller: targetController,
                        hint: 'Ex.: 30, 60, 90',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Divider(
                        height: 1,
                        color: modalBorder,
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'CÁLCULO DE ECONOMIA',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: modalPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Preencha os dados abaixo para acompanhar quanto você está economizando. Essas informações são opcionais.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.55,
                          color: modalSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildFormField(
                        label: 'Cigarros por dia',
                        description: 'Quantidade que costumava fumar',
                        icon: Icons.smoke_free_outlined,
                        iconColor: modalPrimary,
                        controller: cigarettesController,
                        hint: 'Ex.: 20',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildFormField(
                        label: 'Valor da carteira',
                        description: 'Preço médio em reais',
                        icon: Icons.payments_outlined,
                        iconColor: modalPrimary,
                        controller: priceController,
                        hint: 'Ex.: 10,00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: modalSecondary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'O cálculo considera 20 cigarros por carteira.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                height: 1.5,
                                color: modalSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 24,
                  vertical: isMobile ? 14 : 18,
                ),
                decoration: const BoxDecoration(
                  color: modalSurface,
                  border: Border(
                    top: BorderSide(color: modalBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: modalText,
                          side: const BorderSide(color: modalBorder),
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: saveGoal,
                        icon: const Icon(
                          Icons.check,
                          size: 18,
                        ),
                        label: const Text('Salvar meta'),
                        style: FilledButton.styleFrom(
                          backgroundColor: modalPrimary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 46),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) {
    dateController.dispose();
    targetController.dispose();
    cigarettesController.dispose();
    priceController.dispose();
  });
}


  
Widget _buildFormField({
  required String label,
  required String description,
  required IconData icon,
  required Color iconColor,
  required TextEditingController controller,
  required String hint,
  required TextInputType keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  const fieldBackground = Colors.white;
  const fieldText = Color(0xFF333333);
  const fieldSecondary = Color(0xFF667078);
  const fieldPrimary = Color(0xFF426E8C);
  const fieldBorder = Color(0xFFE6E5DF);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fieldText,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        description,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: fieldSecondary,
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: fieldText,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: fieldSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: fieldPrimary,
            size: 19,
          ),
          filled: true,
          fillColor: fieldBackground,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: fieldPrimary,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final stopDate = _getStopDate();
    final targetDays = _getTargetDays();
    final cigarettes = _getCigarettesPerDay();
    final packPrice = _getPackPrice();

    final days = _daysWithoutSmoking(stopDate);
    final progress = targetDays != null && targetDays > 0
        ? (days / targetDays).clamp(0.0, 1.0)
        : 0.0;

    final cigarettesAvoided = cigarettes != null && stopDate != null
        ? days * cigarettes
        : 0;

    final savings =
        packPrice != null && cigarettes != null && stopDate != null
            ? cigarettesAvoided * (packPrice / 20)
            : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressPanel(
              isMobile: isMobile,
              stopDate: stopDate,
              days: days,
              targetDays: targetDays,
              progress: progress,
            ),
            const SizedBox(height: 18),
            _buildStatistics(
              constraints.maxWidth,
              stopDate,
              cigarettes,
              packPrice,
              cigarettesAvoided,
              savings,
            ),
            if (stopDate != null && days >= 7) ...[
              const SizedBox(height: 34),
              _buildAchievements(days),
            ],
            const SizedBox(height: 34),
            _buildToolsSection(isMobile),
          ],
        );
      },
    );
  }

  Widget _buildProgressPanel({
    required bool isMobile,
    required DateTime? stopDate,
    required int days,
    required int? targetDays,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 23 : 36),
      decoration: BoxDecoration(
        color: mintLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mintMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressHeading(),
                const SizedBox(height: 23),
                _buildEditButton(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProgressHeading()),
                const SizedBox(width: 20),
                _buildEditButton(),
              ],
            ),
          const SizedBox(height: 32),
          if (stopDate == null)
            _buildEmptyGoal()
          else ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  '$days',
                  style: TextStyle(
                    fontFamily: 'DMSerifDisplay',
                    fontSize: isMobile ? 78 : 102,
                    height: 1,
                    color: mintDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Text(
                    days == 1 ? 'dia sem fumar' : 'dias sem fumar',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              'Início do acompanhamento: ${_formatDate(stopDate)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: secondary,
              ),
            ),
            if (targetDays != null && targetDays > 0) ...[
              const SizedBox(height: 33),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progresso da meta',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: mintDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    mintDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                days >= targetDays
                    ? 'Meta de $targetDays dias alcançada'
                    : '$days de $targetDays dias',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: secondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProgressHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 19,
              color: mintDark,
            ),
            SizedBox(width: 10),
            Text(
              'SEU PROGRESSO',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
                color: mintDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 13),
        Text(
          'Acompanhamento da meta',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 29,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return OutlinedButton.icon(
      onPressed: _saving ? null : _showGoalModal,
      icon: const Icon(Icons.edit_outlined, size: 17),
      label: Text(
        _getStopDate() == null ? 'Definir meta' : 'Editar meta',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: mintDark,
        backgroundColor: surface,
        side: const BorderSide(color: mintMid),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  Widget _buildEmptyGoal() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Você ainda não definiu uma meta.',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 25,
            color: primary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Informe a data em que parou de fumar e quantos dias deseja alcançar para começar seu acompanhamento.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.6,
            color: secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(
    double width,
    DateTime? stopDate,
    int? cigarettes,
    double? packPrice,
    int cigarettesAvoided,
    double savings,
  ) {
    final isMobile = width < 650;

    final first = _buildStatistic(
      icon: Icons.smoke_free_outlined,
      label: 'Cigarros não fumados',
      value: stopDate != null && cigarettes != null
          ? '$cigarettesAvoided'
          : '—',
      detail: cigarettes != null
          ? 'Baseado em $cigarettes cigarros por dia'
          : 'Configure seu consumo anterior',
      background: blueLight,
      accent: blueDark,
    );

    final second = _buildStatistic(
      icon: Icons.savings_outlined,
      label: 'Economia estimada',
      value: stopDate != null &&
              cigarettes != null &&
              packPrice != null
          ? _formatMoney(savings)
          : '—',
      detail: 'Estimativa com base no valor da carteira',
      background: lavenderLight,
      accent: lavenderDark,
    );

    if (isMobile) {
      return Column(
        children: [
          first,
          const SizedBox(height: 16),
          second,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          const SizedBox(width: 16),
          Expanded(child: second),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required String label,
    required String value,
    required String detail,
    required Color background,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 185),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon, surface.withOpacity(0.7), accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: 39,
              height: 1.1,
              color: accent,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            detail,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(int days) {
    final achievements = <Widget>[];

    if (days >= 7) {
      achievements.add(
        _buildAchievement(
          Icons.emoji_events_outlined,
          '7 dias',
          mintLight,
          mintDark,
        ),
      );
    }

    if (days >= 30) {
      achievements.add(
        _buildAchievement(
          Icons.star_outline,
          '1 mês',
          lavenderLight,
          lavenderDark,
        ),
      );
    }

    if (days >= 365) {
      achievements.add(
        _buildAchievement(
          Icons.workspace_premium_outlined,
          '1 ano',
          terraLight,
          terraDark,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conquistas alcançadas',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: 26,
            color: primary,
          ),
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievements,
        ),
      ],
    );
  }

  Widget _buildAchievement(
    IconData icon,
    String label,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: foreground.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ferramentas de acompanhamento',
            style: TextStyle(
              fontFamily: 'DMSerifDisplay',
              fontSize: 28,
              color: primary,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Registre seus sintomas e consulte sua avaliação de dependência.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.6,
              color: secondary,
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _buildToolRow(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Sintomas diários',
                  description: 'Registre e acompanhe sua evolução.',
                  onTap: () => SintomasModalWidget.show(context),
                  accent: blueDark,
                  background: blueLight,
                ),
                const SizedBox(height: 14),
                _buildToolRow(
                  icon: Icons.assignment_outlined,
                  title: 'Teste de Fagerström',
                  description: _scoreFagerstrom != null
                      ? 'Última pontuação: $_scoreFagerstrom'
                      : 'Avalie sua dependência à nicotina.',
                  onTap: _openFagerstrom,
                  accent: terraDark,
                  background: terraLight,
                ),
              ],
            )
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildToolRow(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Sintomas diários',
                      description: 'Registre e acompanhe sua evolução.',
                      onTap: () => SintomasModalWidget.show(context),
                      accent: blueDark,
                      background: blueLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToolRow(
                      icon: Icons.assignment_outlined,
                      title: 'Teste de Fagerström',
                      description: _scoreFagerstrom != null
                          ? 'Última pontuação: $_scoreFagerstrom'
                          : 'Avalie sua dependência à nicotina.',
                      onTap: _openFagerstrom,
                      accent: terraDark,
                      background: terraLight,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolRow({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color accent,
    required Color background,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: accent.withOpacity(0.14),
            ),
          ),
          child: Row(
            children: [
              _iconBox(
                icon,
                surface.withOpacity(0.75),
                accent,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        height: 1.5,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: accent,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(
    IconData icon,
    Color background,
    Color foreground, {
    double size = 43,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: foreground,
        size: 22,
      ),
    );
  }
}
