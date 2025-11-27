<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // 1. Cek apakah user sudah login
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized: Silakan login terlebih dahulu.'
            ], 401);
        }

        // 2. Cek apakah user adalah Admin
        // Asumsi: Di database, role_id 1 = Admin, role_id 2 = User
        // Sesuaikan angka '1' ini dengan ID Admin di tabel 'roles' Anda.
        if ($user->role_id != 1) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden: Akses ditolak. Anda bukan Admin.'
            ], 403);
        }

        return $next($request);
    }
}
