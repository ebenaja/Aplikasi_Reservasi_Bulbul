<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. ISI TABEL ROLES (Manual disini agar aman)
        // Pastikan menggunakan 'nama_role' bukan 'name'
        DB::table('roles')->insertOrIgnore([
            ['id' => 1, 'nama_role' => 'admin', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'nama_role' => 'user', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // 2. BUAT AKUN ADMIN
        User::create([
            'nama' => 'Admin Pantai',
            'email' => 'admin@bulbul.com',
            'password' => Hash::make('admin123'), // Password Admin
            'role_id' => 1, // 1 = Admin
        ]);

        // 3. BUAT AKUN USER (PENGUNJUNG)
        User::create([
            'nama' => 'Eben',
            'email' => 'eben@gmail.com',
            'password' => Hash::make('eben1106'), // Password User
            'role_id' => 2, // 2 = User
        ]);
    }
}
