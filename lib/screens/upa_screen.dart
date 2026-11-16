import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/services/enrollment_service.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/services/toast_service.dart';
import 'package:tabagismo_app/widgets/header/modals/fagerstrom_modal_widget.dart';
import 'package:tabagismo_app/screens/matriculas_screen.dart';

class UPAScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(String)? onNameUpdated;
  
  const UPAScreen({Key? key, this.userData, this.onNameUpdated}) : super(key: key);

  @override
  _UPAScreenState createState() => _UPAScreenState();
}

class _UPAScreenState extends State<UPAScreen> {
  final _authService = AuthService();
  final Color _primaryDark = const Color(0xFF333333);
  final Color _accentColor = const Color(0xFF426E8C);
  final Color _successColor = const Color(0xFF426E8C);
  
  List<Map<String, dynamic>> _upaList = [];
  List<Map<String, dynamic>> _paginatedList = [];
  bool _isLoading = false;
  final TextEditingController _bairroController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentPage = 1;
  int _itemsPerPage = 8;
  int _totalPages = 1;
  int _ultimaVersao = 0;

  @override
  void initState() {
    super.initState();
    _buscarTodasUPAs();
  }

@override
void dispose() {
  _debounce?.cancel();
  _bairroController.dispose();
  _scrollController.dispose();
  super.dispose();
}

  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      if (query.isEmpty) {
        _buscarTodasUPAs();
        return;
      }
      _buscarPorBairro(query);
    });
  }

  Future<void> _buscarTodasUPAs() async {
    setState(() => _isLoading = true);
    try {
      final upas = await _authService.searchUPA('');
      if (!mounted) return;
      setState(() {
        _upaList = upas;
        _currentPage = 1;
        _updatePagination();
      });
    } catch (e) {
      ToastService.showError(context, 'Erro ao carregar UPAs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarTodasUPAsSilenciosamente() async {
    try {
      final query = _bairroController.text.trim();
      final upas = await _authService.searchUPA(query);
      if (!mounted || query != _bairroController.text.trim()) return;
      if (!mounted) return;
      setState(() {
        _upaList = upas;
        _updatePagination();
      });
    } catch (_) {}
  }

  Future<void> _buscarPorBairro(String bairro) async {
    setState(() => _isLoading = true);
    try {
      final upas = await _authService.searchUPA(bairro);
      setState(() {
        _upaList = upas;
        _currentPage = 1;
        _updatePagination();
      });
    } catch (e) {
      ToastService.showError(context, 'Erro ao buscar UPAs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limparBusca() {
    _debounce?.cancel();
    _bairroController.clear();
    _buscarTodasUPAs();
  }

  void _updatePagination() {
    _totalPages = (_upaList.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;
    _paginatedList = _getCurrentPageItems();
  }

  List<Map<String, dynamic>> _getCurrentPageItems() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > _upaList.length) endIndex = _upaList.length;
    return _upaList.sublist(startIndex, endIndex);
  }

void _goToPage(int page) {
  if (page < 1 || page > _totalPages || page == _currentPage) return;

  setState(() {
    _currentPage = page;
    _paginatedList = _getCurrentPageItems();
  });

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  });
}

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 52),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.outlined(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            color: const Color(0xFF426E8C),
          ),
          const SizedBox(width: 15),
          Text('Página $_currentPage de $_totalPages',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF4E4E4E))),
          const SizedBox(width: 15),
          IconButton.outlined(
            onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            color: const Color(0xFF426E8C),
          ),
        ],
      ),
    );
  }

void _abrirModalMatricula(Map<String, dynamic> upa) async {
    if (!mounted) return;
    try {
      final response = await AuthService().verificarMatriculaAtiva();
      if (!mounted) return;
      if (response['hasActiveEnrollment'] == true) {
        final matricula = Map<String, dynamic>.from(response['enrollment'] as Map);
        final isEmEspera = matricula['status'] == 'em_espera';
        await showDialog<void>(context: context, builder: (dialogContext) => _standardDialog(dialogContext,
          _modalDialogBody(
            header: _modalHeader(icon: isEmEspera ? Icons.hourglass_empty_outlined : Icons.check_circle_outline,
              title: isEmEspera ? 'Matrícula em espera' : 'Matrícula ativa', subtitle: 'Você já possui uma matrícula',
              iconColor: isEmEspera ? const Color(0xFFB87935) : const Color(0xFF397C69),
              iconBackground: isEmEspera ? const Color(0xFFFFF0DB) : const Color(0xFFE8F4EF),
              onClose: () => Navigator.pop(dialogContext)),
            body: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isEmEspera ? 'Sua matrícula está aguardando confirmação.' : 'Sua matrícula já está confirmada.', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF333333), height: 1.5)),
              const SizedBox(height: 18),
              Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFAF8F3), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE6E5DF))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Unidade de atendimento', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF667078))),
                const SizedBox(height: 5),
                Text('${matricula['upa_nome'] ?? 'Não informado'}', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 14),
                const Text('Turma', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF667078))),
                const SizedBox(height: 5),
                Text('${matricula['turma_horario'] ?? 'Não informado'}', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                if (isEmEspera) ...[const SizedBox(height: 12), const Text('Aguardando confirmação', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFB87935), fontWeight: FontWeight.w600))],
              ])),
              const SizedBox(height: 16),
              Text(isEmEspera ? 'Você receberá um contato em até 5 dias úteis para confirmar sua vaga.' : 'Acompanhe os detalhes na seção de matrículas.', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF667078), height: 1.5)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF667078), side: const BorderSide(color: Color(0xFFE6E5DF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Fechar'))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(dialogContext); Navigator.push(context, MaterialPageRoute(builder: (_) => MyEnrollmentsScreen(userData: widget.userData, onNameUpdated: widget.onNameUpdated))); }, icon: const Icon(Icons.list_alt_outlined, size: 17), label: const Text('Ver matrículas'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF426E8C), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)))),
              ]),
            ]),
          ), maxWidth: 500));
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    await showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => _standardDialog(dialogContext,
      EnrollmentModal(upa: upa, userData: widget.userData, onNameUpdated: widget.onNameUpdated), maxWidth: 820));
  }

  Widget _modalHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF426E8C),
    Color iconBackground = const Color(0xFFE1EDF6),
    VoidCallback? onClose,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE6E5DF)))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 23)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF667078))),
        ])),
        if (onClose != null) IconButton.outlined(onPressed: onClose, icon: const Icon(Icons.close, size: 19), color: const Color(0xFF667078), style: IconButton.styleFrom(side: const BorderSide(color: Color(0xFFE6E5DF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ]),
    );
  }

  Widget _modalDialogBody({required Widget header, required Widget body}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      header,
      Flexible(fit: FlexFit.loose, child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: body)),
    ]);
  }

  Dialog _standardDialog(BuildContext dialogContext, Widget child, {double maxWidth = 500}) {
    final size = MediaQuery.sizeOf(dialogContext);
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xFFFFFDF9),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(horizontal: size.width < 400 ? 8 : 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE6E5DF))),
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: size.height * 0.85), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _buscarTodasUPAsSilenciosamente();
            });
          }
        }
        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F3),
          body: Column(
            children: [
              HeaderWidget(
                title: 'DESFUMO',
                subtitle: 'Apoio ao Tabagismo',
                icon: Icons.smoke_free_outlined,
                userData: widget.userData ?? {},
                isHome: true,
                onNameUpdated: widget.onNameUpdated,
                showBackButton: true,
              ),
              Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                    children: [
                      _buildSearchSection(),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(64),
                          child: CircularProgressIndicator(color: Color(0xFF426E8C)),
                        )
                      else if (_upaList.isEmpty)
                        _buildEmptyWidget()
                      else ...[
                        _buildUPACardsList(),
                        if (_totalPages > 1) _buildPagination(),
                      ],
                      const FooterWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


Widget _buildSearchSection() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1250),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFE1EDF6),
            border: Border.all(color: const Color(0xFFC9DEED)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = MediaQuery.sizeOf(context).width < 768;

              final introduction = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF426E8C),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'UNIDADES DE ATENDIMENTO',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Color(0xFF426E8C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Encontre uma unidade de saúde.',
                    style: TextStyle(
                      fontFamily: 'DMSerifDisplay',
                      fontSize: compact ? 36 : 46,
                      height: 1.12,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Busque pelo bairro e consulte as unidades cadastradas para realizar sua matrícula.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.7,
                      color: Color(0xFF4E4E4E),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: compact ? double.infinity : null,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyEnrollmentsScreen(
                              userData: widget.userData,
                              onNameUpdated: widget.onNameUpdated,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.list_alt_outlined,
                        size: 18,
                      ),
                      label: const Text('Ver minhas matrículas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF426E8C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );

              final search = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BUSCAR POR BAIRRO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Color(0xFF426E8C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bairroController,
                    onChanged: (value) {
                      setState(() {});
                      _onSearchChanged(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Digite o nome do bairro...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF8A8A85),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF426E8C),
                      ),
                      suffixIcon: _bairroController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _limparBusca,
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF426E8C),
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFC9DEED),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF426E8C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        introduction,
                        const SizedBox(height: 26),
                        search,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: introduction,
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          flex: 5,
                          child: search,
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    ),
  );
}


  Widget _buildEmptyWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE4E0D6)), borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              const Icon(Icons.location_off_outlined, size: 44, color: Color(0xFF426E8C)),
              const SizedBox(height: 18),
              const Text('Nenhuma unidade encontrada', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 19, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 8),
              const Text('Tente buscar por outro bairro ou limpe o campo para visualizar todas as unidades.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6, color: Color(0xFF4E4E4E))),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: _limparBusca, icon: const Icon(Icons.refresh), label: const Text('Ver todas as unidades'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF426E8C))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildUPACardsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;
                return compact
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Unidades encontradas', style: TextStyle(fontFamily: 'Poppins', fontSize: 19, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        const SizedBox(height: 5),
                        Text('${_upaList.length} resultado(s)', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8A8A85))),
                      ])
                    : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Unidades encontradas', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        Text('${_upaList.length} resultado(s)', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF8A8A85))),
                      ]);
              }),
              const SizedBox(height: 22),
              LayoutBuilder(builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850 ? 2 : 1;
                const spacing = 18.0;
                final cardWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _paginatedList.map((upa) => SizedBox(width: cardWidth, child: _buildUPACard(upa))).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUPACard(Map<String, dynamic> upa) {
    final name = (upa['nome'] ?? 'Unidade de Saúde').toString();
    final city = (upa['cidade'] ?? 'Cidade não informada').toString();
    final address = (upa['endereco'] ?? 'Endereço não informado').toString();
    final cep = _formatarCep(upa['cep']?.toString() ?? '');
    final phone = _formatarTelefone((upa['telefone'] ?? '').toString());
    final horario = (upa['horario'] ?? '').toString().trim();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5EB)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE1EDF6), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.local_hospital_outlined, color: Color(0xFF426E8C), size: 24)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 4),
                Text(city, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF8A8A85))),
              ])),
            ]),
            const SizedBox(height: 19),
            const Divider(height: 1, color: Color(0xFFE4E0D6)),
            const SizedBox(height: 18),
            _buildUPAInfoRow(Icons.location_on_outlined, cep.isEmpty ? address : '$address • CEP $cep'),
            const SizedBox(height: 12),
            _buildUPAInfoRow(Icons.phone_outlined, phone),
            if (horario.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildUPAInfoRow(Icons.access_time_outlined, horario),
            ],
            const SizedBox(height: 23),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirModalMatricula(upa),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Realizar matrícula'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF426E8C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUPAInfoRow(IconData icon, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: const Color(0xFF426E8C)),
      const SizedBox(width: 11),
      Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.5, color: Color(0xFF4E4E4E)))),
    ]);
  }

String _formatarCep(String cep) {
  if (cep.isEmpty) return '';
  String limpo = cep.replaceAll(RegExp(r'[^\d]'), '');
  if (limpo.length == 8) {
    return '${limpo.substring(0, 5)}-${limpo.substring(5)}';
  }
  return cep;
}

  String _formatarTelefone(String telefone) {
    if (telefone.isEmpty) return 'Telefone não informado';
    String apenasNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (apenasNumeros.length == 10) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
    } else if (apenasNumeros.length == 11) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
    }
    return telefone;
  }
}

class EnrollmentModal extends StatefulWidget {
  final Map<String, dynamic> upa;
  final Map<String, dynamic>? userData; 
  final Function(String)? onNameUpdated; 

  const EnrollmentModal({
    Key? key, 
    required this.upa,
    this.userData,
    this.onNameUpdated,
  }) : super(key: key);

  @override
  _EnrollmentModalState createState() => _EnrollmentModalState();
}

class _EnrollmentModalState extends State<EnrollmentModal> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentService = EnrollmentService();
  final _authService = AuthService();
  
  final Color _primaryDark = const Color(0xFF0F2B3D);
  final Color _accentColor = const Color(0xFF1F4E6E);
  final Color _successColor = const Color(0xFF2E8B6A);
  final Color _warningColor = const Color(0xFFD97706);
  final Color _dangerColor = const Color(0xFFC65D47);
  
  String? _turmaSelecionada;
  String? _segundaOpcaoTurma;  
  String? _escolaridade;
  int? _scoreFagestrom;
  String? _medicamento;
  bool _isLoadingScore = true;
  bool _isSubmitting = false;
  bool _carregandoTurmas = true;
  String? _outroMedicamento;

  List<Map<String, dynamic>> _turmasComVagas = [];

  @override
  void initState() {
    super.initState();
    _carregarScoreUsuario();
    _carregarTurmasComVagas();
  }

  Future<void> _carregarTurmasComVagas() async {
    setState(() => _carregandoTurmas = true);
    try {
      final response = await _enrollmentService.getTurmasPorUPA(widget.upa['id']);
      setState(() {
        _turmasComVagas = List<Map<String, dynamic>>.from(response['turmas']);
        _carregandoTurmas = false;
      });
    } catch (e) {
      setState(() => _carregandoTurmas = false);
      ToastService.showError(context, 'Erro ao carregar turmas: $e');
    }
  }

void _showConfirmationDialog() {
    showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => _standardDialog(dialogContext,
      _modalDialogBody(
        header: _modalHeader(icon: Icons.how_to_reg_outlined, title: 'Confirmar matrícula', subtitle: 'Confira antes de continuar', iconColor: const Color(0xFF397C69), iconBackground: const Color(0xFFE8F4EF), onClose: () => Navigator.pop(dialogContext)),
        body: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Deseja realmente se matricular em ${widget.upa['nome']}?', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333), height: 1.5)),
          const SizedBox(height: 14),
          const Text('Após a confirmação, você entrará na lista de espera e receberá contato em até 5 dias úteis.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF667078), height: 1.6)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF667078), side: const BorderSide(color: Color(0xFFE6E5DF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Cancelar'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(dialogContext); _submitEnrollment(); }, icon: const Icon(Icons.check, size: 17), label: const Text('Confirmar'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF397C69), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)))),
          ]),
        ]),
      ), maxWidth: 460));
  }

  Widget _modalHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF426E8C),
    Color iconBackground = const Color(0xFFE1EDF6),
    VoidCallback? onClose,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE6E5DF)))),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 23)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF667078))),
        ])),
        if (onClose != null) IconButton.outlined(onPressed: onClose, icon: const Icon(Icons.close, size: 19), color: const Color(0xFF667078), style: IconButton.styleFrom(side: const BorderSide(color: Color(0xFFE6E5DF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ]),
    );
  }

  Widget _modalDialogBody({required Widget header, required Widget body}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      header,
      Flexible(fit: FlexFit.loose, child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: body)),
    ]);
  }

  Dialog _standardDialog(BuildContext dialogContext, Widget child, {double maxWidth = 500}) {
    final size = MediaQuery.sizeOf(dialogContext);
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xFFFFFDF9),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(horizontal: size.width < 400 ? 8 : 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE6E5DF))),
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: size.height * 0.85), child: child),
    );
  }

  Map<String, List<Map<String, dynamic>>> _comorbidades = {
    'cancer': [],
    'cardiovascular': [],
    'metabolico': [],
    'psiquiatrico': [],
    'respiratorio': [],
  };

  final List<String> _escolaridades = ['Fundamental', 'Médio', 'Superior', 'Pós-graduação'];
  final List<String> _medicamentos = ['Nenhum', 'Adesivo de nicotina', 'Goma de nicotina', 'Pastilha de nicotina', 'Outro'];

  final Map<String, List<String>> _opcoesComorbidades = {
    'cancer': ['bexiga', 'útero', 'esôfago', 'estomago', 'faringe', 'fígado', 'laringe', 'leucemia', 'pâncreas', 'pulmão', 'rim', 'outros', 'nenhum'],
    'cardiovascular': ['angina', 'avc', 'HÁ', 'trombose', 'outros', 'nenhum'],
    'metabolico': ['DM 1', 'DM 2'],
    'psiquiatrico': ['depressão', 'esquizofrenia', 'bipolar', 'ansiedade', 'outro', 'nenhum'],
    'respiratorio': ['asma', 'bronquite', 'enfisema', 'infecção respiratória', 'covid', 'outro', 'nenhum'],
  };

  Future<void> _carregarScoreUsuario() async {
    setState(() => _isLoadingScore = true);
    try {
      final response = await _authService.getUserData();
      final userData = response['user'];
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        setState(() => _scoreFagestrom = userData['scoreFagestrom']);
      }
    } catch (e) {
      ToastService.showError(context, 'Erro ao carregar score: $e');
    } finally {
      setState(() => _isLoadingScore = false);
    }
  }

  void _toggleComorbidade(String categoria, String valor) {
    setState(() {
      final lista = _comorbidades[categoria]!;
      final index = lista.indexWhere((item) => item['valor'] == valor);
      
      if (valor == 'nenhum') {
        if (index == -1) {
          _comorbidades[categoria] = [{'valor': 'nenhum', 'outroTexto': null}];
        } else {
          _comorbidades[categoria] = [];
        }
      } else {
        final hasNenhum = lista.any((item) => item['valor'] == 'nenhum');
        if (hasNenhum) _comorbidades[categoria] = [];
        
        if (index == -1) {
          lista.add({'valor': valor, 'outroTexto': valor == 'outro' || valor == 'outros' ? '' : null});
        } else {
          lista.removeAt(index);
        }
      }
    });
  }

  bool _isSelected(String categoria, String valor) => _comorbidades[categoria]!.any((item) => item['valor'] == valor);
  bool _isNenhumSelected(String categoria) => _comorbidades[categoria]!.any((item) => item['valor'] == 'nenhum');

  Future<void> _submitEnrollment() async {
    if (_formKey.currentState!.validate()) {
      if (_turmaSelecionada == null) {
        ToastService.showWarning(context, 'Selecione uma turma');
        return;
      }
      if ((_scoreFagestrom == null || _scoreFagestrom == 0) && !_isLoadingScore) {
        ToastService.showWarning(context, 'Você precisa fazer o teste de Fagerström antes de se matricular');
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final data = {
          'upaId': widget.upa['id'],
          'upaNome': widget.upa['nome'],
          'turmaHorario': _turmaSelecionada,
          'segundaOpcaoTurma': _segundaOpcaoTurma,
          'escolaridade': _escolaridade,
          'scoreFagestrom': _scoreFagestrom,
          'medicamento': _medicamento == 'Outro' ? (_outroMedicamento ?? '') : _medicamento,
          'comorbidades': _comorbidades,
        };
        await _enrollmentService.enroll(data);
        Navigator.pop(context);
        ToastService.showSuccess(context, 'Matrícula realizada com sucesso! Você está na lista de espera.');
      } catch (e) {
        String errorMessage = e.toString();
        
        if (errorMessage.contains('já possui uma matrícula')) {
          if (!mounted) return;
          showDialog<void>(context: context, builder: (dialogContext) => _standardDialog(dialogContext,
            _modalDialogBody(
              header: _modalHeader(icon: Icons.warning_amber_outlined, title: 'Matrícula existente', subtitle: 'Não foi possível concluir a matrícula', iconColor: const Color(0xFFB87935), iconBackground: const Color(0xFFFFF0DB), onClose: () => Navigator.pop(dialogContext)),
              body: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(errorMessage.replaceFirst('Exception: ', ''), style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6, color: Color(0xFF667078))),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF667078), side: const BorderSide(color: Color(0xFFE6E5DF)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Fechar'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => MyEnrollmentsScreen(userData: widget.userData, onNameUpdated: widget.onNameUpdated))); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF426E8C), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Ver matrículas'))),
                ]),
              ]),
            ), maxWidth: 460));
        } else {
          ToastService.showError(context, 'Erro ao realizar matrícula: $e');
        }
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.sizeOf(context).width < 600;
  final isFormValid = _turmaSelecionada != null && _escolaridade != null && _medicamento != null && (_scoreFagestrom != null && _scoreFagestrom! > 0);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _modalHeader(icon: Icons.school_outlined, title: isMobile ? 'Matrícula' : 'Nova matrícula', subtitle: '${widget.upa['nome'] ?? 'UPA'}', onClose: () => Navigator.pop(context)),
      Flexible(
        fit: FlexFit.loose,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 960;
                        
                        return isSmallScreen
                            ? Column(
                                children: [
                                  _buildTurmaSection('Primeira opção', _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
                                  const SizedBox(height: 16),
                                  _buildTurmaSection('Segunda opção', _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildTurmaSection('Primeira opção', _turmaSelecionada, (value) => setState(() => _turmaSelecionada = value)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTurmaSection('Segunda opção', _segundaOpcaoTurma, (value) => setState(() => _segundaOpcaoTurma = value), isOptional: true),
                                  ),
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),
                    const Text(
                      'Informações Pessoais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEscolaridadeField(),
                    const SizedBox(height: 16),
                    _buildMedicamentoField(),
                    const SizedBox(height: 16),
                    _buildScoreFieldCompact(),
                    const SizedBox(height: 24),
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Comorbidades',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Opcional',
                            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Inter'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione as condições de saúde existentes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildComorbidadesGrid(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isFormValid && !_isSubmitting ? _showConfirmationDialog : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successColor,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMobile ? 'Confirmar' : 'Confirmar Matrícula',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

  Widget _buildEscolaridadeField() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Escolaridade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonFormField<String>(
            value: _escolaridade,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
              hintText: 'Selecione',
              hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Color(0xFF94A3B8)),
            ),
            icon: Icon(Icons.expand_more, color: _accentColor),
            dropdownColor: Colors.white,
            items: _escolaridades.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 13 : 14)),
              );
            }).toList(),
            onChanged: (value) => setState(() => _escolaridade = value),
            validator: (v) => v == null ? 'Selecione a escolaridade' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicamentoField() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Medicamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontFamily: 'Inter')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonFormField<String>(
            value: _medicamento,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
              hintText: 'Selecione',
              hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Color(0xFF94A3B8)),
            ),
            icon: Icon(Icons.expand_more, color: _accentColor),
            dropdownColor: Colors.white,
            items: _medicamentos.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 13 : 14)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _medicamento = value;
                if (value != 'Outro') _outroMedicamento = null;
              });
            },
            validator: (v) => v == null ? 'Selecione o medicamento' : null,
          ),
        ),
        if (_medicamento == 'Outro')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Digite o medicamento',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
                ),
                onChanged: (text) => _outroMedicamento = text,
                validator: (value) {
                  if (_medicamento == 'Outro' && (value == null || value.isEmpty)) {
                    return 'Digite o nome do medicamento';
                  }
                  return null;
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildComorbidadesGrid() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    final List<Map<String, dynamic>> categorias = [
      {'titulo': 'Câncer', 'categoria': 'cancer', 'opcoes': _opcoesComorbidades['cancer']!, 'icon': Icons.health_and_safety},
      {'titulo': 'Cardiovascular', 'categoria': 'cardiovascular', 'opcoes': _opcoesComorbidades['cardiovascular']!, 'icon': Icons.favorite},
      {'titulo': 'Metabólico', 'categoria': 'metabolico', 'opcoes': _opcoesComorbidades['metabolico']!, 'icon': Icons.science},
      {'titulo': 'Psiquiátrico', 'categoria': 'psiquiatrico', 'opcoes': _opcoesComorbidades['psiquiatrico']!, 'icon': Icons.psychology},
      {'titulo': 'Respiratório', 'categoria': 'respiratorio', 'opcoes': _opcoesComorbidades['respiratorio']!, 'icon': Icons.air},
    ];
    
    return Column(
      children: categorias.map((cat) {
        bool temOutroSelecionado = _comorbidades[cat['categoria']]!.any((item) => 
          item['valor'] == 'outro' || item['valor'] == 'outros');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 14),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(cat['icon'], size: isMobile ? 16 : 18, color: _accentColor),
                    const SizedBox(width: 8),
                    Text(
                      cat['titulo'],
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 10 : 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (cat['opcoes'] as List<String>).map((opcao) {
                    bool isSelected = _isSelected(cat['categoria'], opcao);
                    bool isDisabled = _isNenhumSelected(cat['categoria']) && opcao != 'nenhum';
                    return FilterChip(
                      label: Text(opcao, style: TextStyle(fontSize: isMobile ? 10 : 12, fontFamily: 'Inter')),
                      selected: isSelected,
                      onSelected: isDisabled ? null : (selected) => _toggleComorbidade(cat['categoria'], opcao),
                      backgroundColor: Colors.white,
                      selectedColor: _accentColor.withValues(alpha: 0.15),
                      checkmarkColor: _accentColor,
                      side: BorderSide(
                        color: isSelected ? _accentColor : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      shape: const StadiumBorder(),
                    );
                  }).toList(),
                ),
              ),
              if (temOutroSelecionado)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Especifique...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (text) {
                        final item = _comorbidades[cat['categoria']]!.firstWhere(
                          (item) => item['valor'] == 'outro' || item['valor'] == 'outros');
                        item['outroTexto'] = text;
                        setState(() {});
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoreFieldCompact() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score Fagerström', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryDark)),
        const SizedBox(height: 8),
        if (_isLoadingScore)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(child: CircularProgressIndicator(color: _accentColor, strokeWidth: 2)),
          )
        else if (_scoreFagestrom != null && _scoreFagestrom! > 0)
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _successColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: _successColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$_scoreFagestrom pontos',
                    style: TextStyle(fontWeight: FontWeight.w600, color: _successColor, fontSize: isMobile ? 13 : 14),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: _warningColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Não registrado',
                    style: TextStyle(fontWeight: FontWeight.w500, color: _warningColor, fontSize: isMobile ? 11 : 12),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return Dialog(
                          insetPadding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width > 800 ? 700 : MediaQuery.of(context).size.width * 0.95,
                            height: MediaQuery.of(context).size.height > 800 ? 700 : MediaQuery.of(context).size.height * 0.85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: FagerstromTestModal(
                                onScoreUpdated: (score) {
                                  _scoreFagestrom = score;
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                    await _carregarScoreUsuario();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _warningColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Fazer teste', style: TextStyle(fontSize: isMobile ? 10 : 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
      ],
    );
  }

Widget _buildTurmaSection(String title, String? selected, Function(String?) onChanged, {bool isOptional = false}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  if (_carregandoTurmas) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  if (_turmasComVagas.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _warningColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber, color: _warningColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'Nenhuma turma disponível no momento',
            style: TextStyle(fontSize: 14, color: _warningColor, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: isOptional ? _warningColor.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isOptional ? _warningColor.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 14),
          decoration: BoxDecoration(
            color: isOptional ? _warningColor.withValues(alpha: 0.1) : _accentColor.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              if (isOptional) Icon(Icons.info_outline, color: _warningColor, size: 16),
              if (isOptional) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: isOptional ? _warningColor : const Color(0xFF0F172A),
                  fontFamily: 'Inter',
                ),
              ),
              if (isOptional) ...[
                const SizedBox(width: 8),
                Text(
                  '(opcional)',
                  style: TextStyle(fontSize: isMobile ? 10 : 11, color: Color(0xFF64748B), fontFamily: 'Inter'),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          child: Column(
            children: _turmasComVagas.map((turma) {
              String turmaTexto = '${turma['dia_semana']} - ${turma['horario']}';
              int vagasDisponiveis = turma['vagas_disponiveis'] ?? 0;
              int vagasTotais = turma['vagas_totais'] ?? 4;
              bool estaLotado = turma['status'] == 'lotado' || vagasDisponiveis <= 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: selected == turmaTexto ? _accentColor.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == turmaTexto 
                      ? _accentColor 
                      : (estaLotado ? _dangerColor.withValues(alpha: 0.2) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    turmaTexto,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: selected == turmaTexto ? FontWeight.w600 : FontWeight.normal,
                      color: estaLotado ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: estaLotado 
                        ? _dangerColor.withValues(alpha: 0.1)
                        : (vagasDisponiveis <= 2 ? _warningColor.withValues(alpha: 0.1) : _successColor.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estaLotado 
                        ? 'Lotado' 
                        : '$vagasDisponiveis/$vagasTotais',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        color: estaLotado 
                          ? _dangerColor
                          : (vagasDisponiveis <= 2 ? _warningColor : _successColor),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  value: turmaTexto,
                  groupValue: selected,
                  onChanged: estaLotado ? null : onChanged,
                  activeColor: _accentColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 8),
                  dense: isMobile,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

}