<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FasilitasController;
use App\Http\Controllers\Api\ReservasiController;
use App\Http\Controllers\Api\UlasanController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\Api\AdminController;

/*
|--------------------------------------------------------------------------
| 1. PUBLIC ROUTES
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/fasilitas', [FasilitasController::class, 'index']);
Route::get('/ulasan-terbaru', [UlasanController::class, 'allReviews']);
Route::get('/ulasan/{fasilitas_id}', [UlasanController::class, 'index']);

/*
|--------------------------------------------------------------------------
| 2. PROTECTED ROUTES (Wajib Login)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // --- TAMBAHAN BARU DISINI ---
    Route::post('/update-profile', [AuthController::class, 'updateProfile']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    // ----------------------------

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Transaksi
    Route::post('/reservasi', [ReservasiController::class, 'store']);
    Route::get('/reservasi/history', [ReservasiController::class, 'history']);
    Route::post('/pembayaran', [PembayaranController::class, 'store']);

    // Ulasan
    Route::post('/ulasan', [UlasanController::class, 'store']);

    // Admin Routes
    Route::middleware('admin')->group(function () {
        Route::get('/admin/statistics', [AdminController::class, 'getStatistics']);
        Route::post('/fasilitas', [FasilitasController::class, 'store']);
        Route::put('/fasilitas/{id}', [FasilitasController::class, 'update']);
        Route::delete('/fasilitas/{id}', [FasilitasController::class, 'destroy']);
        Route::get('/admin/users', [AdminController::class, 'getAllUsers']);
        Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser']);
        Route::get('/admin/reservasi', [AdminController::class, 'getAllReservations']);
        Route::post('/admin/reservasi/{id}/status', [AdminController::class, 'updateReservasiStatus']);
        Route::get('/admin/ulasan', [AdminController::class, 'getAllUlasan']);
        Route::delete('/admin/ulasan/{id}', [AdminController::class, 'deleteUlasan']);
    });
});
