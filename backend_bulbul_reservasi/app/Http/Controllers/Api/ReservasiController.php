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
    public function store(Request $request)
    {
        // 1. Validasi Input
        $validator = Validator::make($request->all(), [
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'tanggal_sewa' => 'required|date|after_or_equal:today', // Tidak boleh tanggal lampau
            'durasi'       => 'required|integer|min:1',
            'total_harga'  => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Data tidak valid', 'errors' => $validator->errors()], 422);
        }

        // 2. CEK KETERSEDIAAN STOK (LOGIKA HARIAN)
        $fasilitas = Fasilitas::find($request->fasilitas_id);

        // Hitung jumlah reservasi yang SUDAH ada di tanggal tersebut
        // Kita kecualikan yang statusnya 'batal' atau 'ditolak'
        $jumlahTerpesan = Reservasi::where('fasilitas_id', $request->fasilitas_id)
            ->where('tanggal_sewa', $request->tanggal_sewa)
            ->whereNotIn('status', ['batal', 'ditolak'])
            ->count();

        // Jika jumlah pesanan di tanggal itu sudah >= stok fasilitas
        if ($jumlahTerpesan >= $fasilitas->stok) {
            return response()->json([
                'message' => 'Maaf, stok fasilitas ini sudah habis untuk tanggal tersebut. Silakan pilih tanggal lain.'
            ], 400); // Bad Request
        }

        // 3. Simpan Reservasi ke Database
        // Kolom disesuaikan persis dengan CREATE TABLE reservasis
        $reservasi = Reservasi::create([
            'user_id'      => Auth::id(), // Dari token user yang login
            'fasilitas_id' => $request->fasilitas_id,
            'tanggal_sewa' => $request->tanggal_sewa,
            'durasi'       => $request->durasi,
            'total_harga'  => $request->total_harga,
            'status'       => 'pending', // Default value
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Reservasi Berhasil dibuat',
            'data' => $reservasi
        ], 201);
    }

    // Tambahkan fungsi history jika belum ada (untuk tab riwayat di Flutter)
    public function history()
    {
        $userId = Auth::id();
        $reservasi = Reservasi::with('fasilitas')
            ->where('user_id', $userId)
            ->latest()
            ->get();

        return response()->json([
            'status' => 200,
            'data' => $reservasi
        ]);
    }
}
