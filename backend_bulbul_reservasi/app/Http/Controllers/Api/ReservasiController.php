<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservasi;
use App\Models\Fasilitas; // Pastikan Model Fasilitas diimport
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ReservasiController extends Controller
{
    // =================================================================
    // 1. FUNGSI MEMBUAT RESERVASI (STORE)
    // =================================================================
    public function store(Request $request)
    {
        // A. Validasi Input
        $validator = Validator::make($request->all(), [
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'tanggal_sewa' => 'required|date|after:today', // Wajib Besok dst
            'durasi'       => 'required|integer|min:1',
            'total_harga'  => 'required|numeric',
            'jam_mulai'    => 'nullable'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data tidak valid atau tanggal salah (harus besok).',
                'errors' => $validator->errors()
            ], 422);
        }

        // B. Cek Ketersediaan Stok (Logika Harian)
        $fasilitas = Fasilitas::find($request->fasilitas_id);

        $jumlahTerpesan = Reservasi::where('fasilitas_id', $request->fasilitas_id)
            ->where('tanggal_sewa', $request->tanggal_sewa)
            ->whereNotIn('status', ['batal', 'ditolak'])
            ->count();

        if ($jumlahTerpesan >= $fasilitas->stok) {
            return response()->json([
                'message' => 'Maaf, stok fasilitas ini sudah habis untuk tanggal tersebut. Silakan pilih tanggal lain.'
            ], 400); // Bad Request
        }

        // C. Simpan ke Database
        $reservasi = Reservasi::create([
            'user_id'      => Auth::id(),
            'fasilitas_id' => $request->fasilitas_id,
            'tanggal_sewa' => $request->tanggal_sewa,
            'jam_mulai'    => $request->jam_mulai ?? '08:00:00',
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

    // =================================================================
    // 2. FUNGSI MELIHAT RIWAYAT (HISTORY)
    // =================================================================
    public function history()
    {
        // Ambil ID user yang sedang login dari Token
        $userId = Auth::id();

        // Ambil data reservasi milik user tersebut
        $data = Reservasi::with('fasilitas') // Join tabel fasilitas
            ->where('user_id', $userId)
            ->latest() // Urutkan dari yang terbaru
            ->get();

        return response()->json([
            'status' => 200,
            'message' => 'Data riwayat berhasil diambil',
            'data' => $data
        ]);
    }

    // FUNGSI BATALKAN RESERVASI
    public function cancel($id)
    {
        $userId = Auth::id();

        // Cari reservasi milik user ini yang statusnya 'pending'
        $reservasi = Reservasi::where('id', $id)
            ->where('user_id', $userId)
            ->first();

        if (!$reservasi) {
            return response()->json(['message' => 'Reservasi tidak ditemukan atau bukan milik Anda'], 404);
        }

        if ($reservasi->status !== 'pending') {
            return response()->json(['message' => 'Pesanan ini tidak bisa dibatalkan'], 400);
        }

        // Update status jadi batal
        $reservasi->update(['status' => 'batal']);

        return response()->json([
            'status' => 200,
            'message' => 'Reservasi berhasil dibatalkan'
        ]);
    }
}

