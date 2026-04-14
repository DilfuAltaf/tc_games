import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/pokemon_provider.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  final List<int> _quickAmounts = [10000, 50000, 100000, 500000];

  Future<void> _topup() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount!'),
          backgroundColor: Color(0xFFE3350D), // Pokemon Red
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = context.read<AuthProvider>().token;
      if (token == null) throw Exception("Trainer not authenticated");

      final pokemonProvider = context.read<PokemonProvider>();
      final success = await pokemonProvider.topUp(token, amount);

      if (!mounted) return;

      if (success) {
        final newBalanceFormatted = pokemonProvider.formatRupiah(pokemonProvider.userSaldo);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Topup Success! New Balance: $newBalanceFormatted',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Topup failed. Did Team Rocket interfere?'),
            backgroundColor: Color(0xFFE3350D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: const Color(0xFFE3350D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark Theme
      appBar: AppBar(
        title: const Text(
          'TOP UP BALANCE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xFFFFCC00),
            shadows: [
              Shadow(
                color: Color(0xFF3B4CCA),
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFE3350D),
        elevation: 10,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Current Balance beautifully
              Consumer<PokemonProvider>(
                builder: (context, provider, child) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3B4CCA), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCC00).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Color(0xFFE3350D),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'YOUR BALANCE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B4CCA),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.formatRupiah(provider.userSaldo),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Quick Nominal Choices
              const Text(
                'QUICK TOP UP',
                style: TextStyle(
                  color: Color(0xFFFFCC00),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<PokemonProvider>(
                builder: (context, provider, _) { 
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _quickAmounts.map((amount) {
                      return ChoiceChip(
                        label: Text(
                          provider.formatRupiah(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        selected: _amountController.text == amount.toString(),
                        onSelected: (selected) {
                          setState(() {
                            _amountController.text = amount.toString();
                          });
                        },
                        selectedColor: const Color(0xFFFFCC00),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _amountController.text == amount.toString()
                              ? Colors.black
                              : const Color(0xFF3B4CCA),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: _amountController.text == amount.toString()
                                ? const Color(0xFFE3350D)
                                : const Color(0xFF3B4CCA),
                            width: 2,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              ),
              const SizedBox(height: 32),

              // Custom Amount TextField
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Or enter custom amount...',
                  labelStyle: const TextStyle(
                    color: Color(0xFF3B4CCA),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF3B4CCA), width: 3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF3B4CCA), width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFE3350D), width: 4),
                  ),
                ),
                onChanged: (val) {
                  setState(() {}); // Trigger rebuild to update ChoiceChip selection
                },
              ),
              const SizedBox(height: 48),

              // Big Action Button
              ElevatedButton(
                onPressed: _isLoading ? null : _topup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3350D),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.white, width: 4),
                  ),
                  elevation: 10,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CONFIRM TOP UP',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
