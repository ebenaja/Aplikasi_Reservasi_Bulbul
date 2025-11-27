<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Ulasan;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class UlasanController extends Controller
{
    // --- TAMBAHAN PENTING: Ambil Semua Ulasan Terbaru (Untuk Beranda) ---
    public function allReviews()
    {
        // Ambil 5 ulasan terakhir dari semua fasilitas
        $ulasan = Ulasan::with('user:id,nama') // Join tabel user ambil namanya
            ->latest() // Urutkan dari yang paling baru
            ->take(5)  // Batasi cuma 5
            ->get();

        return response()->json([
            'status' => 200,
            'data' => $ulasan
        ]);
    }
    // ---------------------------------------------------------------------

    // 1. GET: Ambil Ulasan per Fasilitas
    public function index($fasilitas_id)
    {
        $ulasan = Ulasan::where('fasilitas_id', $fasilitas_id)
            ->with('user:id,nama')
            ->latest()
            ->get();

        return response()->json([
            'status' => 200,
            'data' => $ulasan
        ]);
    }

    // 2. POST: Tambah Ulasan
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'fasilitas_id' => 'required|exists:fasilitas,id',
            'rating'       => 'required|integer|min:1|max:5',
            'komentar'     => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $ulasan = Ulasan::create([
            'user_id'      => Auth::id(),
            'fasilitas_id' => $request->fasilitas_id,
            'rating'       => $request->rating,
            'komentar'     => $request->komentar,
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Ulasan berhasil dikirim',
            'data' => $ulasan
        ], 201);
    }
}
