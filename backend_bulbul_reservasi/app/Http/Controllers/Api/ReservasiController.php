<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservasi;
use App\Models\Fasilitas;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class ReservasiController extends Controller
{
    // ============================================================
    // 1. STORE — BUAT RESERVASI + CEK TABRAKAN MULTI-HARI (FINAL)
    // ============================================================
    public function store(Request $request)
    {
        // VALIDASI
        $validator = Validator::make($request->all(), [
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'tanggal_sewa' => 'required|date|after_or_equal:today',
            'durasi'       => 'required|integer|min:1|max:7',
            'total_harga'  => 'required|numeric',
            'jam_mulai'    => 'nullable'
        ], [
            'durasi.max' => 'Maksimal durasi sewa adalah 7 hari (1 Minggu).',
            'tanggal_sewa.after_or_equal' => 'Tanggal sewa tidak boleh di masa lalu.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Data tidak valid.',
                'errors' => $validator->errors()
            ], 422);
        }

        // AMBIL STOK FASILITAS
        $fasilitas = Fasilitas::find($request->fasilitas_id);
        $stokMaksimal = $fasilitas->stok;

        // CEK STOK UNTUK SETIAP TANGGAL DALAM DURASI
        $tglMulai = Carbon::parse($request->tanggal_sewa);
        $durasi   = $request->durasi;

        for ($i = 0; $i < $durasi; $i++) {

            $cekTanggal = $tglMulai->copy()->addDays($i)->format('Y-m-d');

            // Rumus overlap FINAL:
            // (tanggal_sewa <= cekTanggal) AND (tanggal_sewa + durasi > cekTanggal)
            $terpakai = Reservasi::where('fasilitas_id', $request->fasilitas_id)
                ->where('status', '!=', 'batal')
                ->where(function ($query) use ($cekTanggal) {
                    $query->where('tanggal_sewa', '<=', $cekTanggal)
                          // Sintaks Postgres: tanggal + (durasi * interval '1 hari')
                            ->whereRaw("(tanggal_sewa + (durasi * INTERVAL '1 day')) > ?", [$cekTanggal]);
                })
                ->count();

            if ($terpakai >= $stokMaksimal) {
                return response()->json([
                    'status'  => 409,
                    'message' => "Mohon maaf, fasilitas penuh pada tanggal " . date('d-m-Y', strtotime($cekTanggal)) . "."
                ], 409);
            }
        }

        // SIMPAN KE DATABASE
        $reservasi = Reservasi::create([
            'user_id'      => Auth::id(),
            'fasilitas_id' => $request->fasilitas_id,
            'tanggal_sewa' => $request->tanggal_sewa,
            'jam_mulai'    => $request->jam_mulai ?? '08:00:00',
            'durasi'       => $durasi,
            'total_harga'  => $request->total_harga,
            'status'       => 'pending',
        ]);

        return response()->json([
            'status'  => 201,
            'message' => 'Reservasi berhasil dibuat. Silakan lanjut ke pembayaran.',
            'data'    => $reservasi
        ], 201);
    }

    // ============================================================
    // 2. CHECK AVAILABILITY — CEK STOK HARIAN
    // ============================================================
    public function checkAvailability(Request $request)
    {
        $request->validate([
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'tanggal_sewa' => 'required|date',
        ]);

        $fasilitas = Fasilitas::find($request->fasilitas_id);
        $stokAdmin = $fasilitas->stok;

        $terpakai = Reservasi::where('fasilitas_id', $request->fasilitas_id)
            ->whereDate('tanggal_sewa', $request->tanggal_sewa)
            ->where('status', '!=', 'batal')
            ->count();

        return response()->json([
            'status'            => 200,
            'nama_fasilitas'    => $fasilitas->nama_fasilitas,
            'tanggal'           => $request->tanggal_sewa,
            'total_stok_admin'  => $stokAdmin,
            'terpakai_hari_ini' => $terpakai,
            'sisa_stok'         => max($stokAdmin - $terpakai, 0)
        ]);
    }

    // ============================================================
    // 3. HISTORY
    // ============================================================
    public function history()
    {
        $userId = Auth::id();

        $data = Reservasi::with('fasilitas')
            ->where('user_id', $userId)
            ->latest()
            ->get();

        return response()->json([
            'status'  => 200,
            'message' => 'Data riwayat berhasil diambil.',
            'data'    => $data
        ]);
    }

    // ============================================================
    // 4. CANCEL
    // ============================================================
    public function cancel($id)
    {
        $userId = Auth::id();

        $reservasi = Reservasi::where('id', $id)
            ->where('user_id', $userId)
            ->first();

        if (!$reservasi) {
            return response()->json(['message' => 'Reservasi tidak ditemukan atau bukan milik Anda'], 404);
        }

        if ($reservasi->status !== 'pending') {
            return response()->json(['message' => 'Pesanan ini tidak bisa dibatalkan'], 400);
        }

        $reservasi->update(['status' => 'batal']);

        return response()->json([
            'status'  => 200,
            'message' => 'Reservasi berhasil dibatalkan.'
        ]);
    }
}
