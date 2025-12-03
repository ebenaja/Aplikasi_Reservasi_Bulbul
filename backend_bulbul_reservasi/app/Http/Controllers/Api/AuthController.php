<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // =================================================================
    // 1. REGISTER (DAFTAR AKUN BARU)
    // =================================================================
    public function register(Request $request)
    {
        // 1. Validasi
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255', // Input dari Flutter 'name'
            'email'    => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], 422);
        }

        // 2. Simpan ke Database
        $user = User::create([
            // KIRI: Nama Kolom di Database (nama)
            // KANAN: Nama Input dari Flutter (name)
            'nama'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role_id'  => 2, // Default: 2 = User (Pastikan di tabel roles id 2 itu User)
        ]);

        // 3. Buat Token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success'      => true,
            'message'      => 'Registrasi Berhasil',
            'data'         => $user,
            'access_token' => $token,
            'token_type'   => 'Bearer',
        ], 201);
    }

    // =================================================================
    // 2. LOGIN
    // =================================================================
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], 422);
        }

        // Cek Kredensial
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        // Ambil User beserta data Role-nya (JOIN TABLE)
        $user = User::with('role')->where('email', $request->email)->first();

        // Buat Token
        $token = $user->createToken('auth_token')->plainTextToken;

        // Ambil nama role dari relasi, jika null default ke 'user'
        $roleName = $user->role ? $user->role->nama_role : 'user';

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'id'    => $user->id,
                'name'  => $user->nama, // Kirim sebagai 'name' ke Flutter
                'email' => $user->email,
                'role'  => $user->role // Kirim objek role lengkap
            ],
            'access_token' => $token, // Token standar

            // FIELD TAMBAHAN AGAR FLUTTER LEBIH MUDAH BACA:
            'token' => $token,
            'user' => [
                'name' => $user->nama,
                'email' => $user->email,
                'role' => $roleName // Kirim string role ("admin"/"user")
            ]
        ], 200);
    }

    // =================================================================
    // 3. UPDATE PROFILE (Ganti Nama)
    // =================================================================
    public function updateProfile(Request $request)
    {
        $user = $request->user(); // Ambil user dari Token

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Update kolom 'nama'
        $user->update([
            'nama' => $request->name
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Nama profil berhasil diperbarui',
            'data' => $user
        ], 200);
    }

    // =================================================================
    // 4. CHANGE PASSWORD (Ganti Kata Sandi saat Login)
    // =================================================================
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'new_password'     => 'required|min:8|confirmed', // Butuh field 'new_password_confirmation'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Password baru tidak cocok atau kurang valid',
                'errors'  => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Cek password lama
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi lama salah'
            ], 400);
        }

        // Update password baru
        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diubah'
        ], 200);
    }

    // =================================================================
    // 5. LOGOUT
    // =================================================================
    public function logout()
    {
        if(auth()->user()) {
            auth()->user()->tokens()->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ], 200);
    }

    // =================================================================
    // 6. RESET PASSWORD (LUPA PASSWORD - TANPA LOGIN)
    // =================================================================
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'        => 'required|email|exists:users,email',
            'new_password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status'  => 404,
                'message' => 'Email tidak ditemukan atau password kurang valid.'
            ], 404);
        }

        $user = User::where('email', $request->email)->first();

        if ($user) {
            $user->password = Hash::make($request->new_password);
            $user->save();

            return response()->json([
                'status'  => 200,
                'message' => 'Password berhasil diubah! Silakan login kembali.'
            ], 200);
        }

        return response()->json([
            'status'  => 500,
            'message' => 'Terjadi kesalahan sistem.'
        ], 500);
    }
}
