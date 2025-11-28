<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FasilitasController;
use App\Http\Controllers\Api\ReservasiController;
use App\Http\Controllers\Api\UlasanController;
use App\Http\Controllers\Api\AdminController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ====================================================
// 1. PUBLIC ROUTES (Bisa diakses siapa saja)
// ====================================================

// Auth
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Fasilitas (Read Only) - Agar User bisa lihat daftar tanpa login/sebagai user
Route::get('/fasilitas', [FasilitasController::class, 'index']);
Route::get('/ulasan/{fasilitas_id}', [UlasanController::class, 'index']);
// Jika nanti butuh detail per item: Route::get('/fasilitas/{id}', [FasilitasController::class, 'show']);


// ====================================================
// 2. PROTECTED ROUTES (Harus Login: User & Admin)
// ====================================================
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/reservasi/history', [ReservasiController::class, 'history']);
    Route::post('/reservasi', [ReservasiController::class, 'store']);
    Route::post('/ulasan', [UlasanController::class, 'store']);
    Route::get('/ulasan-terbaru', [UlasanController::class, 'allReviews']);
    Route::post('/pembayaran', [PembayaranController::class, 'store']);

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Cek Profile User yang sedang login
    Route::get('/user', function (Request $request) {
        return $request->user();
    });


    // ============================
    //    3. ADMIN ONLY ROUTES
    // ============================
    // Rute di bawah ini HANYA bisa diakses jika role user = admin
    // Pastikan middleware 'admin' sudah Anda buat dan daftarkan
    Route::middleware('admin')->group(function () {

        Route::get('/admin/statistics', [AdminController::class, 'getStatistics']);
        // CRUD Fasilitas (Create, Update, Delete)
        Route::post('/fasilitas', [FasilitasController::class, 'store']);
        Route::put('/fasilitas/{id}', [FasilitasController::class, 'update']);
        Route::delete('/fasilitas/{id}', [FasilitasController::class, 'destroy']);

         // DATA PENGGUNA
        Route::get('/admin/users', [AdminController::class, 'getAllUsers']);
        Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser']);

        // RESERVASI & PEMBAYARAN
        Route::get('/admin/reservasi', [AdminController::class, 'getAllReservations']);
        Route::post('/admin/reservasi/{id}/status', [AdminController::class, 'updateReservasiStatus']);

        // ULASAN
        Route::get('/admin/ulasan', [AdminController::class, 'getAllUlasan']);
        Route::delete('/admin/ulasan/{id}', [AdminController::class, 'deleteUlasan']);

        // Dashboard Data (Contoh)
        Route::get('/admin/dashboard', function () {
            return response()->json([
                'success' => true,
                'message' => 'Halo Admin, ini data rahasia dashboard!',
            ]);
        });

        // Manage Users (Contoh)
        Route::get('/admin/users', function () {
            return \App\Models\User::all();
        });
    });

});
