<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Notifikasi;
use Illuminate\Support\Facades\Auth;

class NotifikasiController extends Controller
{
    public function index()
    {
        $userId = Auth::id(); // ID User yang sedang login

        // Ambil notifikasi:
        // 1. Yang user_id-nya NULL (Promo Global)
        // 2. ATAU yang user_id-nya sama dengan ID user login (Notif Pribadi)
        $data = Notifikasi::where(function($query) use ($userId) {
                $query->whereNull('user_id')
                      ->orWhere('user_id', $userId);
            })
            ->latest() // Urutkan dari terbaru
            ->get();

        return response()->json([
            'status' => 200,
            'data' => $data
        ]);
    }
}
