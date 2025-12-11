<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Fasilitas;
use App\Models\Notifikasi; // Pastikan ini ada
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class FasilitasController extends Controller
{
    // GET: Ambil Semua Data
    public function index()
    {
        $data = Fasilitas::withAvg('ulasan', 'rating')->get();
        return response()->json([
            'status' => 200,
            'data' => $data
        ], 200);
    }

    // POST: Tambah Data
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama_fasilitas' => 'required|string|max:100',
            'harga'          => 'required|numeric',
            'stok'           => 'required|integer',
            'foto'           => 'nullable',
            'is_promo'       => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi Gagal', 'errors' => $validator->errors()], 422);
        }

        // 1. Upload Foto
        $pathFoto = null;
        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('fasilitas', 'public');
            $pathFoto = asset('storage/' . $path);
        } else {
            $pathFoto = $request->foto;
        }

        // 2. Deteksi Promo (Handle String "1", "true", "on")
        $isPromo = $request->filled('is_promo') &&
        ($request->is_promo == '1' || $request->is_promo == 'true' || $request->is_promo === true);


        // 3. Simpan
        $fasilitas = Fasilitas::create([
            'nama_fasilitas' => $request->nama_fasilitas,
            'deskripsi'      => $request->deskripsi,
            'harga'          => $request->harga,
            'stok'           => $request->stok,
            'status'         => $request->status ?? 'tersedia',
            'foto'           => $pathFoto,
            'is_promo'       => $isPromo ? 1 : 0,
        ]);

        // 4. Buat Notifikasi jika Promo
        if ($isPromo) {
            Notifikasi::create([
                'judul'        => 'Promo Baru: ' . $fasilitas->nama_fasilitas,
                'pesan'        => 'Harga spesial Rp ' . number_format($fasilitas->harga),
                'tipe'         => 'promo',
                'user_id'      => null, // Broadcast ke semua
                'reservasi_id' => null
            ]);
        }

        return response()->json(['status' => 201, 'message' => 'Sukses', 'data' => $fasilitas], 201);
    }

    // PUT: Update Data
    public function update(Request $request, $id)
    {
        $fasilitas = Fasilitas::find($id);
        if (!$fasilitas) {
            return response()->json(['status' => 404, 'message' => 'Data tidak ditemukan'], 404);
        }

        // 1. Handle Foto
        $pathFoto = $fasilitas->foto;
        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('fasilitas', 'public');
            $pathFoto = asset('storage/' . $path);
        } elseif ($request->foto && $request->foto !== 'null') {
            $pathFoto = $request->foto;
        }

        // 2. Deteksi Perubahan Promo
        $oldPromo = $fasilitas->is_promo;
        $inputPromo = $request->is_promo;
        $newPromo = false;
        if ($inputPromo !== null) {
             $newPromo = ($inputPromo == '1' || $inputPromo == 'true' || $inputPromo === true);
        } else {
             $newPromo = $oldPromo; // Tidak berubah
        }

        // 3. Update
        $fasilitas->update([
            'nama_fasilitas' => $request->nama_fasilitas ?? $fasilitas->nama_fasilitas,
            'deskripsi'      => $request->deskripsi ?? $fasilitas->deskripsi,
            'harga'          => $request->harga ?? $fasilitas->harga,
            'stok'           => $request->stok ?? $fasilitas->stok,
            'status'         => $request->status ?? $fasilitas->status,
            'foto'           => $pathFoto,
            'is_promo'       => $newPromo ? 1 : 0,
        ]);

        // 4. Notifikasi hanya jika berubah dari Tidak Promo -> Promo
        if ($newPromo && !$oldPromo) {
            Notifikasi::create([
                'judul'        => 'Diskon Spesial: ' . $fasilitas->nama_fasilitas,
                'pesan'        => 'Sekarang sedang promo! Cek detailnya Rp ' . number_format($fasilitas->harga),
                'tipe'         => 'promo',
                'user_id'      => null,
                'reservasi_id' => null
            ]);
        }

        return response()->json(['status' => 200, 'message' => 'Update Sukses', 'data' => $fasilitas], 200);
    }

    public function destroy($id)
    {
        $fasilitas = Fasilitas::find($id);
        if ($fasilitas) {
            $fasilitas->delete();
            return response()->json(['status' => 200, 'message' => 'Dihapus'], 200);
        }
        return response()->json(['status' => 404, 'message' => 'Gagal'], 404);
    }
}
