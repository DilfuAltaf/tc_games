import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/pokemon_set.dart';

class PokemonProvider extends ChangeNotifier {
  final List<PokemonSet> _allSets = [];
  final List<PokemonSet> _displayedSets = [];
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 10;
  
  // Menggunakan tipe int nullable untuk variable saldo agar bisa mendeteksi state loading ("null")
  int? _userSaldo;
  String? _saldoErrorMsg;

  List<PokemonSet> get sets => _displayedSets;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  
  int? get userSaldo => _userSaldo;
  String? get saldoErrorMsg => _saldoErrorMsg;

  // Implementasi format Rupiah agar seragam dan bebas bug format
  String formatRupiah(int amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }

  Future<void> fetchSets(String token, {bool isRefresh = false}) async {
    if (_isLoading) return; // Mencegah proses ganda tertimpa
    if (!isRefresh && !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (isRefresh || _allSets.isEmpty) {
        final response = await http.get(
          Uri.parse('https://api-tcg-backend.vercel.app/api/pokemon/sets'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          List<dynamic> jsonList = jsonDecode(response.body);
          
          // JANGAN mengosongkan sebelum fetch berhasil, supaya UI tidak nge-blank.
          _allSets.clear();
          _displayedSets.clear();
          _currentPage = 1;
          _hasMore = true;

          _allSets.addAll(jsonList.map((j) => PokemonSet.fromJson(j)).toList());
        } else {
          throw Exception('Failed to load pokemon sets');
        }
      }

      int startIndex = (_currentPage - 1) * _limit;
      int endIndex = startIndex + _limit;

      if (startIndex < _allSets.length) {
        _displayedSets.addAll(_allSets.sublist(
          startIndex,
          endIndex > _allSets.length ? _allSets.length : endIndex,
        ));
        _currentPage++;
        if (endIndex >= _allSets.length) {
          _hasMore = false;
        }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error fetching sets: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Refresh state loading
    }
  }

  Future<void> initData(String token) async {
    // Menjalankan initial fetch secara bersamaan
    await Future.wait([
      fetchUserBalance(token),
      fetchSets(token),
    ]);
  }

  // Sinkronisasi balance
  Future<void> fetchUserBalance(String token) async {
    _saldoErrorMsg = null;
    notifyListeners();
    // Jangan set _userSaldo = 0 sembarangan di awal, biarkan state-nya saat ini
    try {
      final response = await http.get(
        Uri.parse('https://api-tcg-backend.vercel.app/api/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('saldo')) {
           _userSaldo = data['saldo'] is int ? data['saldo'] : int.tryParse(data['saldo'].toString()) ?? 0;
           notifyListeners();
        } else if (data['data'] != null && data['data']['saldo'] != null) {
           _userSaldo = data['data']['saldo'] is int ? data['data']['saldo'] : int.tryParse(data['data']['saldo'].toString()) ?? 0;
           notifyListeners();
        }
      } else {
         // Fallback endpoint if not profile
         final resp2 = await http.get(Uri.parse('https://api-tcg-backend.vercel.app/api/auth/profile'), headers: {'Authorization': 'Bearer $token'});
         if (resp2.statusCode == 200 || resp2.statusCode == 201) {
            final data = jsonDecode(resp2.body);
            if (data.containsKey('saldo')) {
              _userSaldo = data['saldo'] is int ? data['saldo'] : int.tryParse(data['saldo'].toString()) ?? 0;
              notifyListeners();
            } else if (data['data'] != null && data['data']['saldo'] != null) {
              _userSaldo = data['data']['saldo'] is int ? data['data']['saldo'] : int.tryParse(data['data']['saldo'].toString()) ?? 0;
              notifyListeners();
            } else {
              _saldoErrorMsg = 'Data saldo tidak valid';
              notifyListeners();
            }
         } else if (resp2.statusCode == 401 || resp2.statusCode == 403) {
            _saldoErrorMsg = 'Sesi Kadaluwarsa';
            notifyListeners();
         } else {
            _saldoErrorMsg = 'Gagal mengambil data saldo';
            notifyListeners();
         }
      }
    } catch (e) {
      _saldoErrorMsg = 'Koneksi bermasalah';
      notifyListeners();
      debugPrint('Error fetching balance: $e');
    }
  }

  Future<bool> topUp(String token, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('https://api-tcg-backend.vercel.app/api/users/topup'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"amount": amount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data.containsKey('saldo_baru')) {
          _userSaldo = data['saldo_baru'];
          _saldoErrorMsg = null;
          notifyListeners(); // Pembaruan UI Saldo secara REAL-TIME
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error topping up: $e');
      return false;
    }
  }

  // Fungsi beli Pokemon/Set (UTS)
  Future<bool> buyItem(int price) async {
    if (_userSaldo != null && _userSaldo! >= price) {
      // Simulasi pengurangan Saldo secara lokal 
      // (Bisa juga ditambahkan request ke backend jika API buy sudah tersedia)
      _userSaldo = _userSaldo! - price;
      notifyListeners(); // Update saldo dion widget seketika
      return true;
    } else {
      return false; // Saldo tidak cukup
    }
  }

  void refresh() {
    // Kini state reset ditangani oleh fetchSets(isRefresh: true) langsung
    // Setelah memastikan HTTP response sukses. Agar tidak menyebabkan UI kosong.
  }
}
