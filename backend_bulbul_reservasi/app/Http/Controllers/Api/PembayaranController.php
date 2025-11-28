<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pembayaran;
use App\Models\Reservasi;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class PembayaranController extends Controller
{
public function store(Request $request)
    {
        // 1. Validasi (Ubah 'bukti' jadi string, bukan image)
        $validator = Validator::make($request->all(), [
            'reservasi_id' => 'required|exists:reservasis,id',
            'bukti'        => 'required|string', // SEKARANG STRING (No. Referensi)
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // 2. Tidak perlu upload file, langsung simpan stringnya
        $buktiTransaksi = $request->bukti;

        // 3. Simpan ke Tabel Pembayarans
        $pembayaran = Pembayaran::create([
            'reservasi_id' => $request->reservasi_id,
            'bukti'        => $buktiTransaksi, // Menyimpan No. Ref
            'status'       => 'menunggu',
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Konfirmasi pembayaran berhasil dikirim',
            'data' => $pembayaran
        ], 201);
    }
}
