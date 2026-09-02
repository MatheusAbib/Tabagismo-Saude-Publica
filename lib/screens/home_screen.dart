import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tabagismo_app/services/polling_service.dart';
import 'package:tabagismo_app/widgets/loading_overlay.dart';
import 'package:tabagismo_app/widgets/footer_widget.dart';
import 'package:tabagismo_app/widgets/header/header_widget.dart';
import 'package:tabagismo_app/widgets/user/home_materiais_widget.dart';
import 'package:tabagismo_app/widgets/user/home_metas_widget.dart';
import 'package:tabagismo_app/widgets/user/home_sobre_widget.dart';
import 'package:tabagismo_app/services/auth_service.dart';
import 'package:tabagismo_app/screens/sobre_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> _userData;
  int _currentBannerIndex = 0;
  bool _isLoggedIn = false;
  int _selectedTab = 0;
  bool _isLoading = true; 
  bool _bannerLoading = true;
  int _ultimaVersao = 0;

final List<Map<String, dynamic>> _banners = [
  {
    'title': 'Encontre Sua Turma de Apoio',
    'subtitle': 'Acesse "Turmas de Apoio" e comece sua jornada com acompanhamento profissional.',
    'icon': Icons.people_outline,
    'color': Color(0xFF0F172A),
    'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    'image': 'assets/images/Grupo-Apoio.png',
  },
  {
    'title': 'Benefícios Imediatos',
    'subtitle': 'Em apenas 20 minutos, sua pressão arterial e pulsação voltam ao normal.',
    'icon': Icons.favorite_outline,
    'color': Color(0xFF0F172A),
    'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    'image': 'assets/images/Beneficios-Imediatos.png',
  },
  {
    'title': 'Economize Milhares de Reais',
    'subtitle': 'Em um ano sem cigarro, você economiza cerca de R\$7.000.',
    'icon': Icons.attach_money_outlined,
    'color': Color(0xFF0F172A),
    'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    'image': 'assets/images/Economize.png',
  },
  {
    'title': 'Viva Mais e Melhor',
    'subtitle': 'Parar de fumar pode aumentar sua expectativa de vida em até 10 anos.',
    'icon': Icons.self_improvement_outlined,
    'color': Color(0xFF0F172A),
    'gradient': [Color(0xFF0F172A), Color(0xFF1E293B)],
    'image': 'assets/images/Viva-Mais.png',
  },
];

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _checkLoginStatus();
    _startAutoCarousel();
    _loadGoalData();
    _startRealtimeUpdate();
    _loadFagerstromScore();
    _carregarDados(); 
    _preloadBannerImage(0);
  }

  void _preloadBannerImage(int index) async {
    setState(() => _bannerLoading = true);
    try {
      final image = NetworkImage(_banners[index]['image']);
      final completer = Completer();
      final stream = image.resolve(ImageConfiguration());
      final listener = ImageStreamListener(
        (info, sync) => completer.complete(),
        onError: (error, stack) => completer.completeError(error),
      );
      stream.addListener(listener);
      await completer.future;
      stream.removeListener(listener);
    } catch (e) {
      print('Erro ao carregar imagem: $e');
    }
    if (mounted) {
      setState(() => _bannerLoading = false);
    }
  }

  Future<void> _carregarDados() async {
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recarregarSilenciosamente() async {
    _loadGoalData();
    _loadFagerstromScore();
    if (mounted) {
      setState(() {});
    }
  }

  void _checkLoginStatus() {
    final userId = _userData['id'];
    final token = _userData['token'];
    
    if (mounted) { 
      setState(() {
        _isLoggedIn = (userId != null && userId > 0) || token != null;
      });
    }
  }

  void _startRealtimeUpdate() {
    _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _loadGoalData() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      
      if (mounted) {  
        setState(() {
          if (userData['stop_date'] != null && userData['stop_date'] != '' && userData['stop_date'] != 'null') {
            _userData['stopDate'] = userData['stop_date'].toString();
          }
          if (userData['target_days'] != null && userData['target_days'] > 0) {
            _userData['targetDays'] = userData['target_days'];
          }
          if (userData['cigarros_por_dia'] != null && userData['cigarros_por_dia'] != '') {
            int? valor = int.tryParse(userData['cigarros_por_dia'].toString());
            if (valor != null && valor > 0) {
              _userData['cigarrosPorDia'] = valor;
            }
          }
          if (userData['valor_carteira'] != null && userData['valor_carteira'] != '') {
            double? valor = double.tryParse(userData['valor_carteira'].toString());
            if (valor != null && valor > 0) {
              _userData['valorCarteira'] = valor;
            }
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar meta: $e');
    }
  }

  Future<void> _loadFagerstromScore() async {
    try {
      final authService = AuthService();
      final response = await authService.getUserData();
      final userData = response['user'];
      if (userData['scoreFagestrom'] != null && userData['scoreFagestrom'] > 0) {
        if (mounted) {  
          setState(() {
            _userData['scoreFagestrom'] = userData['scoreFagestrom'];
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar score: $e');
    }
  }

  void _startAutoCarousel() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        final nextIndex = (_currentBannerIndex + 1) % _banners.length;
        _currentBannerIndex = nextIndex;
        _preloadBannerImage(nextIndex);
        setState(() {});
        _startAutoCarousel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollingService>(
      builder: (context, pollingService, child) {
        if (_ultimaVersao != pollingService.versao) {
          _ultimaVersao = pollingService.versao;
          if (!_isLoading) {
            _recarregarSilenciosamente();
          }
        }
        
        return LoadingOverlay( 
          isLoading: _isLoading,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    children: [
                      _isLoggedIn 
                        ? HeaderWidget(
                          title: 'DESFUMO',
                          subtitle: 'Apoio ao Tabagismo',
                          icon: Icons.smoke_free_outlined,
                          userData: _userData,
                          isHome: true,
                          onNameUpdated: _updateUserName,
                        )
                        : _buildGuestHeader(constraints),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildHeroBanner(constraints),
                              _buildSectionHeader(),
                              _buildTabBar(),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth < 768 ? 16 : 50,
                                  vertical: 20,
                                ),
                                child: _buildTabContent(constraints),
                              ),
                              const FooterWidget(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

void _updateUserName(String newName) {
  setState(() {
    _userData['nomeCompleto'] = newName;
  });
}


  Widget _buildTabBar() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    List<Tab> tabs = [];
    
    if (_isLoggedIn) {
      tabs = isMobile
          ? const [
              Tab(icon: Icon(Icons.menu_book), text: 'Materiais'),
              Tab(icon: Icon(Icons.flag), text: 'Minhas Metas'),
              Tab(icon: Icon(Icons.info_outline), text: 'Sobre'),
            ]
          : const [
              Tab(icon: Icon(Icons.menu_book), text: 'Material de Apoio'),
              Tab(icon: Icon(Icons.flag), text: 'Minhas Metas'),
              Tab(icon: Icon(Icons.info_outline), text: 'Sobre o Programa'),
            ];
    } else {
      tabs = isMobile
          ? const [
              Tab(icon: Icon(Icons.menu_book), text: 'Materiais'),
              Tab(icon: Icon(Icons.info_outline), text: 'Sobre'),
            ]
          : const [
              Tab(icon: Icon(Icons.menu_book), text: 'Material de Apoio'),
              Tab(icon: Icon(Icons.info_outline), text: 'Sobre o Programa'),
            ];
    }
    
    return Container(
      color: Colors.white,
      child: isMobile
          ? TabBar(
              controller: TabController(
                length: tabs.length,
                initialIndex: _selectedTab < tabs.length ? _selectedTab : 0,
                vsync: _TabBarVSync(),
              ),
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              isScrollable: false,
              indicatorColor: const Color(0xFF1F4E6E),
              indicatorWeight: 3,
              labelColor: const Color(0xFF1F4E6E),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontFamily: 'Inter',
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: tabs,
            )
          : TabBar(
              controller: TabController(
                length: tabs.length,
                initialIndex: _selectedTab < tabs.length ? _selectedTab : 0,
                vsync: _TabBarVSync(),
              ),
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              isScrollable: isMobile,
              indicatorColor: const Color(0xFF1F4E6E),
              indicatorWeight: 3,
              labelColor: const Color(0xFF1F4E6E),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: TextStyle(
                fontSize: isMobile ? 13 : 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontFamily: 'Inter',
              ),
              tabs: tabs,
            ),
    );
  }

  Widget _buildTabContent(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 1100;
    
    if (!_isLoggedIn) {
      switch (_selectedTab) {
        case 0:
          return isMobile
              ? Column(
                  children: [
                    HomeMateriaisWidget(isLoggedIn: _isLoggedIn),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: HomeMateriaisWidget(isLoggedIn: _isLoggedIn),
                    ),
                  ],
                );
        case 1:
          return _buildSobreProgramaContent(isMobile);
        default:
          return const SizedBox.shrink();
      }
    }
    
    switch (_selectedTab) {
      case 0:
        return isMobile
            ? Column(
                children: [
                  HomeMateriaisWidget(isLoggedIn: _isLoggedIn),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: HomeMateriaisWidget(isLoggedIn: _isLoggedIn),
                  ),
                ],
              );
      case 1:
return isMobile
    ? Column(
        children: [
          HomeMetasWidget(
            userData: _userData,
            onRefresh: _carregarDados,
          ),
        ],
      )
    : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: HomeMetasWidget(
              userData: _userData,
              onRefresh: _carregarDados,
            ),
          ),
        ],
      );
      case 2:
        return isMobile
            ? Column(
                children: [
                  const HomeSobreWidget(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: const HomeSobreWidget(),
                  ),
                ],
              );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSobreProgramaContent(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          const HomeSobreWidget(),
        ],
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: const HomeSobreWidget(),
        ),
      ],
    );
  }

  Widget _buildGuestHeader(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    final double horizontalPadding = isMobile ? 16 : (isTablet ? 32 : 50);
    
    return Container(
      color: const Color(0xFF334155),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                  Icons.smoke_free_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESFUMO',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Apoio ao Tabagismo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildGuestMenu(),
        ],
      ),
    );
  }

  Widget _buildGuestMenu() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SobreScreen()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.login_outlined, color: Colors.white, size: isMobile ? 16 : 18),
                const SizedBox(width: 8),
                Text(
                  isMobile ? 'Entrar' : 'Entrar / Cadastrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BoxConstraints constraints) {
    final banner = _banners[_currentBannerIndex];
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    
    double bannerHeight = isMobile ? 400 : (isTablet ? 550 : 720);
    double titleSize = isMobile ? 32 : (isTablet ? 44 : 56);
    double subtitleSize = isMobile ? 14 : (isTablet ? 16 : 18);
    double leftPadding = isMobile ? 20 : (isTablet ? 40 : 60);
    double rightPadding = isMobile ? 20 : (isTablet ? 40 : 60);
    
    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.05, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _bannerLoading
                ? Container(
                    key: const ValueKey('loading'),
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : Image.network(
                    banner['image'],
                    key: ValueKey(banner['image']),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white60, size: 60),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.55),
          ),
          Positioned(
            left: leftPadding,
            right: rightPadding,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner['title']?.toString() ?? '',
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.2,
                                      height: 1.1,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: isMobile ? 40 : 80,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    banner['subtitle']?.toString() ?? '',
                                    style: TextStyle(
                                      fontSize: subtitleSize,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentBannerIndex == index ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    if (isMobile) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 50),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Recursos e Informações',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Recursos selecionados para ajudar na sua jornada',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TabBarVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}