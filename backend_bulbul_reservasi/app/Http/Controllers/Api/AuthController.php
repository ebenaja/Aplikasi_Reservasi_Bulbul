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
    // 1. REGISTER (KODE LAMA)
    public function register(Request $request)
    {
        // 1. Validasi
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255', // Input dari Flutter adalah 'name'
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // 2. Simpan ke Database
        $user = User::create([
            // KIRI: Nama Kolom di Database (nama)
            // KANAN: Nama Input dari Flutter (name)
            'nama' => $request->name,

            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role_id' => 2, // Default Role ID untuk User/Wisatawan
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'data' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    // 2. LOGIN (KODE LAMA)
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

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        $user = User::where('email', $request->email)->first();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data'    => [
                'id'    => $user->id,
                // Menggunakan 'nama' karena di register Anda pakai kolom 'nama'
                'name'  => $user->nama ?? $user->name,
                'email' => $user->email,
                'role'  => $user->role // Pastikan model User punya relasi/atribut role
            ],
            'access_token' => $token,
            'token_type'   => 'Bearer',
        ], 200);
    }


    // 3. UPDATE PROFILE (BARU - FLUTTER)
    public function updateProfile(Request $request)
    {
        $user = $request->user(); // Ambil user dari Token

        // Validasi input 'name' dari Flutter
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Update kolom 'nama' di database
        $user->update([
            'nama' => $request->name
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Nama profil berhasil diperbarui',
            'data' => $user
        ], 200);
    }


    // 4. CHANGE PASSWORD (BARU - FLUTTER)
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'new_password' => 'required|min:8|confirmed', // Butuh field 'new_password_confirmation' dari Flutter
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
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

    // 5. LOGOUT
    public function logout()
    {
        // Cek jika user login (punya token)
        if(auth()->user()) {
            auth()->user()->tokens()->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil, token terhapus'
        ]);
    }
}
