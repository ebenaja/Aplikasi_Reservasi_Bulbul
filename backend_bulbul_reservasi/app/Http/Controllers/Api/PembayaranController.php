<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pembayaran;
use Illuminate\Support\Facades\Validator;

class PembayaranController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validasi (UBAH DISINI)
        // Hapus 'image|mimes:...' agar bisa terima teks nomor referensi
        $validator = Validator::make($request->all(), [
            'reservasi_id' => 'required|exists:reservasis,id',
            'bukti'        => 'required', // Cukup required saja (bisa file atau string)
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $pathBukti = $request->bukti;

        // 2. Cek apakah inputnya File Gambar atau Teks Biasa
        if ($request->hasFile('bukti')) {
            // Jika user upload gambar
            $path = $request->file('bukti')->store('bukti_pembayaran', 'public');
            $pathBukti = asset('storage/' . $path);
        }
        // Jika tidak ada file, berarti $pathBukti berisi string No. Referensi dari Flutter

        // 3. Simpan ke Database
        $pembayaran = Pembayaran::create([
            'reservasi_id' => $request->reservasi_id,
            'bukti'        => $pathBukti, // Isi URL gambar atau No. Referensi
            'status'       => 'menunggu',
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Bukti pembayaran berhasil dikirim',
            'data' => $pembayaran
        ], 201);
    }
}
