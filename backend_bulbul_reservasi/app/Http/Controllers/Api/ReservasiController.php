<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservasi;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReservasiController extends Controller
{
    // 1. BUAT RESERVASI BARU
    public function store(Request $request)
    {
        // Validasi Input
        $validator = Validator::make($request->all(), [
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'tanggal_sewa' => 'required|date',
            'durasi'       => 'required|integer|min:1',
            'total_harga'  => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Simpan ke Database
        $reservasi = Reservasi::create([
            'user_id'      => Auth::id(),
            'fasilitas_id' => $request->fasilitas_id,
            'tanggal_sewa' => $request->tanggal_sewa,
            'durasi'       => $request->durasi,
            'total_harga'  => $request->total_harga,
            'status'       => 'pending',
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Reservasi Berhasil dibuat',
            'data' => $reservasi
        ], 201);
    }

    // 2. LIHAT RIWAYAT PESANAN (HISTORY)
    // Ini penting untuk Tab Pemesanan di Flutter
    public function history()
    {
        $userId = Auth::id();

        // Ambil data reservasi milik user yang sedang login
        // 'with(fasilitas)' -> Join tabel fasilitas biar namanya muncul di aplikasi
        $reservasi = Reservasi::with('fasilitas')
            ->where('user_id', $userId)
            ->latest() // Urutkan dari yang paling baru
            ->get();

        return response()->json([
            'status' => 200,
            'data' => $reservasi
        ]);
    }
}
