<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Reservasi;
use App\Models\Ulasan;
use Illuminate\Support\Facades\DB; // <--- POSISI YANG BENAR DI SINI

class AdminController extends Controller
{
    // 1. GET ALL USERS
    public function getAllUsers()
    {
        $users = User::where('role_id', 2)->latest()->get();
        return response()->json(['data' => $users]);
    }

    // 2. GET ALL RESERVATIONS
    public function getAllReservations()
    {
        // Mengambil data reservasi beserta user, fasilitas, dan pembayaran
        $data = Reservasi::with(['user', 'fasilitas', 'pembayaran'])
            ->latest()
            ->get();

        return response()->json(['data' => $data]);
    }

    // 3. UPDATE STATUS RESERVASI
    public function updateReservasiStatus(Request $request, $id)
    {
        $reservasi = Reservasi::find($id);
        if($reservasi) {
            $reservasi->update(['status' => $request->status]);
            return response()->json(['message' => 'Status berhasil diubah']);
        }
        return response()->json(['message' => 'Data tidak ditemukan'], 404);
    }

    // 4. GET ALL ULASAN
    public function getAllUlasan()
    {
        $data = Ulasan::with(['user', 'fasilitas'])->latest()->get();
        return response()->json(['data' => $data]);
    }

    // 5. DELETE ULASAN
    public function deleteUlasan($id)
    {
        Ulasan::destroy($id);
        return response()->json(['message' => 'Ulasan dihapus']);
    }

    // 6. DELETE USER
    public function deleteUser($id)
    {
        User::destroy($id);
        return response()->json(['message' => 'User dihapus']);
    }

    // 7. GET STATISTICS (Laporan Keuangan)
    public function getStatistics()
    {
        // A. Total Pendapatan
        $totalPendapatan = Reservasi::where('status', '!=', 'batal')->sum('total_harga');

        // B. Total Transaksi
        $totalTransaksi = Reservasi::count();

        // C. Fasilitas Terpopuler
        $fasilitasPopuler = Reservasi::select('fasilitas_id', DB::raw('count(*) as total_pesanan'))
            ->groupBy('fasilitas_id')
            ->orderByDesc('total_pesanan')
            ->with('fasilitas')
            ->take(5)
            ->get();

        // D. Transaksi Terbaru
        $transaksiTerbaru = Reservasi::with(['user', 'fasilitas'])
            ->latest()
            ->take(10)
            ->get();

        return response()->json([
            'status' => 200,
            'data' => [
                'total_pendapatan' => $totalPendapatan,
                'total_transaksi' => $totalTransaksi,
                'fasilitas_populer' => $fasilitasPopuler,
                'transaksi_terbaru' => $transaksiTerbaru
            ]
        ]);
    }
}
