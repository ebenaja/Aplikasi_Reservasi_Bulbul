<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Public Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected Routes (Harus Login)
Route::middleware('auth:sanctum')->group(function () {

    // Logout user
    Route::post('/logout', [AuthController::class, 'logout']);

    // User profile normal
    Route::get('/profile', function (Request $request) {
        return $request->user();
    });

    // ============================
    //     ADMIN ONLY ROUTES
    // ============================
    Route::middleware('admin')->group(function () {

        Route::get('/admin/dashboard', function () {
            return response()->json([
                'success' => true,
                'message' => 'Halo admin, kamu berhasil akses dashboard!',
            ]);
        });

        // contoh CRUD admin (bisa tambah sendiri nanti)
        Route::get('/admin/users', function () {
            return \App\Models\User::all();
        });
    });
});
