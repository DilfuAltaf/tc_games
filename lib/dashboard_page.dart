import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'providers/auth_provider.dart';
import 'providers/pokemon_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
    // Menjalankan Infinite Scroll trigger
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  void _initialLoad() async {
    final authProvider = context.read<AuthProvider>();
    // Membaca token untuk persistensi saat refresh manual
    await authProvider.loadToken();
    final token = authProvider.token;
    
    if (token != null) {
      final pokemonProvider = context.read<PokemonProvider>();
      // Memanggil fungsi initData yang akan fetch balance & sets secara bersamaan
      await pokemonProvider.initData(token);
    }
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _loadMore() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<PokemonProvider>().fetchSets(token);
    }
  }

  void _handleBuy(int price) async {
    final provider = context.read<PokemonProvider>();
    final success = await provider.buyItem(price);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil membeli kartu! Saldo telah dipotong.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saldo tidak mencukupi! Silakan topup terlebih dahulu.'),
          backgroundColor: const Color(0xFFE3350D), // Pokemon Red
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'TOPUP',
            textColor: Colors.yellow,
            onPressed: () {
              context.push('/topup');
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark Mode Background
      appBar: AppBar(
        title: const Text(
          'CARDS GALLERY',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xFFFFCC00),
            shadows: [Shadow(color: Color(0xFF3B4CCA), offset: Offset(2, 2))],
          ),
        ),
        backgroundColor: const Color(0xFFE3350D),
        elevation: 10,
        actions: [
          // AppBar menampilkan Saldo User Real-time
          Consumer<PokemonProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3B4CCA), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Color(0xFFE3350D)),
                    const SizedBox(width: 8),
                    if (provider.saldoErrorMsg != null)
                      Text(
                        provider.saldoErrorMsg!,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                      )
                    else if (provider.userSaldo == null)
                      const SizedBox(
                        width: 14, 
                        height: 14, 
                        child: CircularProgressIndicator(color: Color(0xFFE3350D), strokeWidth: 2)
                      )
                    else
                      Text(
                        provider.formatRupiah(provider.userSaldo!),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                      ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFFFCC00), size: 32),
            onPressed: () => context.push('/topup'),
            tooltip: 'Top Up Balance',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          if (_isInitializing || (provider.sets.isEmpty && provider.isLoading)) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00)));
          }

          if (provider.sets.isEmpty) {
            return const Center(
              child: Text('No Cards Found. Check back later!',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFE3350D),
            backgroundColor: Colors.white,
            onRefresh: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                // Jangan panggil provider.refresh() lagi untuk menghindari blank UI.
                // Parameter isRefresh akan men-handle pengosongan data JIKA sukses.
                await Future.wait([
                  provider.fetchUserBalance(token),
                  provider.fetchSets(token, isRefresh: true),
                ]);
              }
            },
            // Menggunakan GridView yang efisien untuk list seperti Galeri Kartu
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.58, // Rasio ideal Kartu Pokemon fisik
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.sets.length + (provider.hasMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.sets.length) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFCC00)));
                }

                final set = provider.sets[index];
                
                return _buildPokemonCard(set, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPokemonCard(set, PokemonProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A), // Dark grey
            Color(0xFF1E1E1E), // Extremely dark grey
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: const Color(0xFFFFCC00).withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: -2,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Kartu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      set.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    (set.hp != null && set.hp.toString().isNotEmpty) ? 'HP ${set.hp}' : 'HP --',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Color(0xFFE4431B), // Warna Oranye Kemerahan
                      shadows: [
                        Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Body Kartu (Gambar tajam di tengah)
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Holographic glow effect
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE4431B).withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Image
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: CachedNetworkImage(
                      imageUrl: set.logo,
                      fit: BoxFit.contain, // Maintain art ratio and tajam
                      placeholder: (context, url) => const SizedBox(
                        height: 40, width: 40,
                        child: CircularProgressIndicator(color: Color(0xFFFFCC00), strokeWidth: 3),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image, size: 50, color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer Kartu
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF151515), // Very dark background for footer
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Column(
                children: [
                  // Rarity & Types
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          set.types != null ? set.types.join(", ") : 'Normal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        set.rarity ?? 'Common',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFFFFCC00),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Tombol 'BUY'
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => _handleBuy(set.price),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4431B), // Oranye kemerahan seperti instruksi
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFE4431B).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('BUY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('•', style: TextStyle(color: Colors.white70)),
                          ),
                          Text(
                            provider.formatRupiah(set.price),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
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
  }
}
