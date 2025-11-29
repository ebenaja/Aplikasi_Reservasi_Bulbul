<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Fasilitas;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class FasilitasController extends Controller
{
    // GET: Ambil Semua Data + Rata-rata Rating
    public function index()
    {
        // withAvg('nama_relasi', 'nama_kolom_yang_dirata2')
        // Ini akan menghasilkan field baru: "ulasan_avg_rating" di JSON response
        $data = Fasilitas::withAvg('ulasan', 'rating')->get();

        return response()->json([
            'status' => 200,
            'message' => 'Daftar Fasilitas',
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
            'is_promo'       => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi Gagal', 'errors' => $validator->errors()], 422);
        }

        // Upload Foto (Handle File atau String URL)
        $pathFoto = null;
        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('fasilitas', 'public');
            $pathFoto = asset('storage/' . $path);
        } else {
            $pathFoto = $request->foto; // Jika dikirim string path/url
        }

        $fasilitas = Fasilitas::create([
            'nama_fasilitas' => $request->nama_fasilitas,
            'deskripsi'      => $request->deskripsi,
            'harga'          => $request->harga,
            'stok'           => $request->stok,
            'status'         => $request->status ?? 'tersedia',
            'foto'           => $pathFoto,
            'is_promo'       => $request->is_promo ?? false,
        ]);

        return response()->json([
            'status' => 201,
            'message' => 'Fasilitas Berhasil Ditambahkan',
            'data' => $fasilitas
        ], 201);
    }

    // UPDATE DATA
    public function update(Request $request, $id)
    {
        $fasilitas = Fasilitas::find($id);
        if (!$fasilitas) {
            return response()->json(['status' => 404, 'message' => 'Data tidak ditemukan'], 404);
        }

        // Cek Foto Baru
        $pathFoto = $fasilitas->foto;
        if ($request->hasFile('foto')) {
            // Hapus foto lama jika perlu (opsional)
            // if($pathFoto) Storage::delete(...)

            $path = $request->file('foto')->store('fasilitas', 'public');
            $pathFoto = asset('storage/' . $path);
        } elseif ($request->foto) {
            $pathFoto = $request->foto; // Update string path jika ada
        }

        $fasilitas->update([
            'nama_fasilitas' => $request->nama_fasilitas ?? $fasilitas->nama_fasilitas,
            'deskripsi'      => $request->deskripsi ?? $fasilitas->deskripsi,
            'harga'          => $request->harga ?? $fasilitas->harga,
            'stok'           => $request->stok ?? $fasilitas->stok,
            'status'         => $request->status ?? $fasilitas->status,
            'foto'           => $pathFoto,
            'is_promo'       => $request->is_promo ?? $fasilitas->is_promo,
        ]);

        return response()->json([
            'status' => 200,
            'message' => 'Fasilitas Berhasil Diupdate',
            'data' => $fasilitas
        ], 200);
    }

    // DELETE: Hapus Data
    public function destroy($id)
    {
        $fasilitas = Fasilitas::find($id);
        if (!$fasilitas) {
            return response()->json(['status' => 404, 'message' => 'Data tidak ditemukan'], 404);
        }

        $fasilitas->delete();
        return response()->json([
            'status' => 200,
            'message' => 'Fasilitas Berhasil Dihapus'
        ], 200);
    }
}
